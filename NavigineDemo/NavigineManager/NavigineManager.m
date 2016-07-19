//
//  NaviganeManager.m
//  Navitech
//
//  Created by Valentine on 17.04.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "NavigineManager.h"

#define kSTRICT_MODE false

@interface NavigineManager(Protected)

- (NSArray *) _arrayWithAccelerometerData;
- (NSArray *) _arrayWithGyroscopeData;
- (NSArray *) _arrayWithMagnetometerData;

- (int)_startLocationUploader :(NSString *)userHash :(NSString*)location :(BOOL) forced;
- (int)_checkLocationUploader :(int)loaderId;
- (void)_stopLocationUploader :(int) loaderId;

/**
 *  This methods used to send WScanMessage to server.
 *  Now we don't use this function
 */
- (int) _getConnectionStatusWriteSocket;
- (int) _getConnectionStatusReadSocket;
- (void) _setServer: (const char*) serverIP andPort: (int) writePort;
- (int) _setConnectionStatus: (int) i;
- (void) _launchNavigineSocketThreads: (const char*)serverIP : (int)serverWritePort;
- (int) _sendPacket;

/**
 *  Function is used to get current version of archive
 *
 *  @param path  archive location
 *  @param error error if archive is invalid
 *
 *  @return current version or 0 if error
 */
- (NSString *) _currentVersionAt: (NSString *)path
                           error: (NSError * __autoreleasing *)error;
- (void) _setUserHash :(NSString *)userHash;

/**
 *  Function is used for begin saving data to log file
 *
 *  @return full path to log file
 */
- (NSString *) _startSaveLogToFile;

/**
 *  Function is used to add check point to log file
 *
 *  @param checkPoint name of check point
 */
- (void) _addCheckPointToLogFile: (NSString *)checkPoint;

// Function is used to stop save data to log file
- (void) _stopSaveLogToFile;

/**
 *  Function is used to remove all log files inside current location directory
 *
 *  @param error error if can't remove logs
 */
- (void) _removeAllLogs:(NSError **)error;

/**
 *  Function is used to remove log file from location directory
 *
 *  @param log   full path to log file
 *  @param error error if can't remove log
 */
- (void) _removeLog:(NSString *)log error:(NSError **)error;

/**
 *  Function is used to begin navigation by log file
 *
 *  @param log   full path to log file
 *  @param error error if log file does not exist or invalid
 *
 *  @return number of WScanMessage inside log file
 */
- (NSUInteger)_startNavigateByLog :(NSString *)log with: (NSError **)error;

// Function is used to stop naviation by log file
- (void)_stopNavigeteByLog;

// Function is used to enable/disable scan beacons using CLLocationManager
- (void) _regularScanEnabled: (BOOL)enabled;

// Function is used to enable/disable scan beacons usinc CBCentralManager
- (void) _fastScanEnabled: (BOOL)enabled;

// Function is used for changing frequency of sensors update
- (void) _changeSensorsFrequencyTo:(double) frequency;

/**
 *  Function is used for changing base server
 *
 *  @param server base server
 */
- (void)_changeBaseServerTo:(NSString *) server;
/**
 *  Displaying calibration view
 */
- (void)_shouldDisplayCalibration: (BOOL)displaying;

/**
 *  Return beacons which added on map
 */
- (NSArray *)_beaconsList;

- (void) _startMeasureNearestBeacon:(NCBeacon *)beacon;
- (void) _stopMeasureNearestBeacon;
- (void) _removeMeasuredBeacon:(NCBeacon *)beacon;
- (void) _saveBeaconsXML;

/**
 *  Functions is used for debug PDR
 */
- (void) _navigateEnablePdr: (int)subLocId :(double)x :(double)y;
- (void) _navigateDisablePdr;
@end

@implementation NavigineManager

static NSString *_userHash = nil;

+ (instancetype)sharedManager {
  static NavigineManager *_navigineManager = nil;
  
  if (nil != _navigineManager) {
    return _navigineManager;
  }
  
  static dispatch_once_t pred;        // Lock
  dispatch_once(&pred, ^{
      _navigineManager = [[NavigineManager alloc] init];// This code is called at most once per app
  });
  return _navigineManager;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init{
  [self getServerFromSettings];
  if (self = [super initWithServer:self.server]) {
//    [self downloadContent:@"081d-7236-5625-7c6q"
//                 location:@"SVO Airport"
//              forceReload:NO
//             processBlock:^(NSInteger loadProcess) {
//             } successBlock:^() {
//               [self startNavigine];
//               [self startRangePushes];
//               [self startRangeVenues];
//             } failBlock:^(NSError *error) {
//               if(error){
//                 NSLog(@"FAIL: %@",error);
//               }
//             }];
    self.loadFromURL = NO;
    _debugModeEnable = NO;
    _mainArrowHidden = YES;
    _stepCounterHidden = YES;
    _secondArrowHidden = YES;
    self.superUsers = @[@"532FF36A-A009-4F22-8FC0-7CAF6514835F",  //iPhone 6 plus
                        @"EFEB9593-C1BE-464B-98A8-C15D2E8C2E5E",  //iPhone 5
                        @"6E2BB5B4-0691-41B2-B1CF-301C2C0F7A2A"]; //iPhone 4s
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    _su = [self.superUsers indexOfObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]] == NSNotFound ? NO : YES;
    super.delegate = self;
    super.btStateDelegate = self;
    _pushEnable = NO;
    [self loadSettings];
  }
  return self;
}

- (void)sendPushWithText:(NSString *)string andUserInfo:(NSDictionary *)userInfo {
  UIApplicationState state = [[UIApplication sharedApplication] applicationState];
  if (state == UIApplicationStateBackground || state == UIApplicationStateInactive){
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = string;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = userInfo;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
  }
}

- (int) checkLocationLoader :(NSInteger) loaderId{
  return [super checkLocationLoader: (int)loaderId];
}

- (void) stopLocationLoader :(NSInteger) loaderId {
  [super stopLocationLoader:(int)loaderId];
}

- (void) startNavigine{
  @try {
    [super startNavigine];
  }
  @catch (NSException *exception) {
    DLog(@"Exception caught: reason: %@",exception.description);
  }
}

- (int) startLocationLoader :(NSString *)userID :(NSString *)location{
  return [super startLocationLoader :userID :location :YES];
}

- (int) startLocationUploader :(NSString *)userHash :(NSString*)location{
  return [self _startLocationUploader:userHash :location :YES];
}

- (int) startLocationLoader :(NSString *)userID :(NSString *)location :(BOOL)forced{
  return [super startLocationLoader:userID :location :forced];
}

- (int) checkLocationUploader :(int)id{
  return [self _checkLocationUploader:id];
}

- (void) stopLocationUploader :(int)id{
  return [self _stopLocationUploader:id];
}

- (CGSize) sizeForImageAtIndex:(NSInteger)index error:(NSError * __autoreleasing *)error{
  CGSize imageSize = [super sizeForImageAtIndex:index error:error];
  if(*error)
    return CGSizeZero;
  self.DEFAULT_WIDTH = imageSize.width;
  self.DEFAULT_HEIGHT = imageSize.height;
  return imageSize;
}

- (CGSize) sizeForImageAtId:(NSInteger)id error:(NSError * __autoreleasing *)error{
  CGSize imageSize = [super sizeForImageAtId:id error:error];
  if(*error)
    return CGSizeZero;
  self.DEFAULT_WIDTH = imageSize.width;
  self.DEFAULT_HEIGHT = imageSize.height;
  return imageSize;
}

-(void) setUserHash: (NSString *)userHash{
  if(_userHash != userHash){
    _userHash = userHash;
    [self _setUserHash:userHash];
    self.userHash = userHash;
  }
}

- (void) loadArchive:(NSString *)location error:(NSError *__autoreleasing *)error{
  [super loadArchive:location error:error];
}

#pragma mark - NavigineCoreDelegate methods

- (void)didRangePushWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image{
  if(!_pushEnable) return;
  UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
  PopTextViewController *ptvc =  [st instantiateViewControllerWithIdentifier:@"ptview"];
  ptvc.pushTitle = title;
  ptvc.pushContent = content;
  ptvc.pushImage = image;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ptvc];
  nav.navigationBarHidden = YES;
  UIViewController *vc = [[UIApplication sharedApplication] keyWindow].rootViewController;
  [vc presentViewController:nav animated:YES completion:nil];
  [self sendPushWithText:title andUserInfo:nil];
}

- (void) didRangeVenues:(NSArray *)venues :(NSArray *)categories{
  self.venues = [NSMutableArray arrayWithArray:venues];
}

- (void) didRangeBeacons:(NSArray *)beacons{
  if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(didRangeBeacons:)])
    [self.dataDelegate didRangeBeacons:beacons];
}

- (void) getLatitude: (double)latitude Longitude:(double)longitude{
  if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(getLatitude:Longitude:)])
    [self.dataDelegate getLatitude:latitude Longitude:longitude];
}

- (void) navigationResultsInBackground :(NavigationResults) navigationResults{
}

- (void) updateSteps:(NSNumber *)numberOfSteps with:(NSNumber *)distance{
  if(self.stepsDelegate && [self.stepsDelegate respondsToSelector:@selector(updateSteps:with:)])
    [self.stepsDelegate updateSteps:numberOfSteps with:distance];
}

- (void) yawCalculatedByIos:(double)yaw{
  if (self.stepsDelegate && [self.stepsDelegate respondsToSelector:@selector(yawCalculatedByIos:)])
    [self.stepsDelegate yawCalculatedByIos:yaw];
}

- (void) beaconFounded:(NCBeacon *)ncBeacon error:(NSError**)error{
  if (self.beaconMeasureDelegate && [self.beaconMeasureDelegate respondsToSelector:@selector(beaconFounded: error:)])
    [self.beaconMeasureDelegate beaconFounded:ncBeacon error:error];
}

- (void) measuringBeaconWithProcess:(NSInteger)process{
  if (self.beaconMeasureDelegate && [self.beaconMeasureDelegate respondsToSelector:@selector(measuringBeaconWithProcess: )])
    [self.beaconMeasureDelegate measuringBeaconWithProcess:process];
}

- (void) didEnterZoneWithId:(NSInteger)id{
  return;
}

- (void) didExitZoneWithId:(NSInteger)id{
  return;
}

#pragma mark - NCBluetoothStateDelegate methods

-(void) didChangeBluetoothState:(NCBluetoothState)state{
  UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
  UIViewController *vc = [[UIApplication sharedApplication] keyWindow].rootViewController;
  if(state == NCBluetoothStatePoweredOff){
    BTOffView *btoffview =  [st instantiateViewControllerWithIdentifier:@"btoff"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:btoffview];
    nav.navigationBarHidden = YES;
    [vc presentViewController:nav animated:YES completion:nil];
  }
  else{
    BTOffView *btoffview =  [st instantiateViewControllerWithIdentifier:@"btoff"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:btoffview];
    nav.navigationBarHidden = YES;
    [vc dismissViewControllerAnimated: YES completion:nil];
    
    if(state != NCBluetoothStateLocationAuthorizedAlways &&
       state != NCBluetoothStateLocationAuthorizedWhenInUse){
        GEOOffView *geooffview =  [st instantiateViewControllerWithIdentifier:@"geooff"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:geooffview];
        nav.navigationBarHidden = YES;
        [vc presentViewController:nav animated:YES completion:nil];
    }
    else{
        GEOOffView *geooffview =  [st instantiateViewControllerWithIdentifier:@"geooff"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:geooffview];
        nav.navigationBarHidden = YES;
        [vc dismissViewControllerAnimated: YES completion:nil];
    }
  }
}

#pragma mark - hidden methods of NavigineCore

- (NSArray *) arrayWithAccelerometerData{
  return [self _arrayWithAccelerometerData];
}

- (NSArray *) arrayWithGyroscopeData{
  return [self _arrayWithGyroscopeData];
}

- (NSArray *) arrayWithMagnetometerData{
  return [self _arrayWithMagnetometerData];
}

- (NSString *) currentVersionAt:(NSString *)path error:(NSError * __autoreleasing *)error{
  return [self _currentVersionAt:path error:error];
}

- (NSString *) startSaveLogToFile{
  return [self _startSaveLogToFile];
}

- (void) addCheckPointToLogFile: (NSString *)checkPoint{
  return [self _addCheckPointToLogFile:checkPoint];
}

- (void) stopSaveLogToFile{
  return [self _stopSaveLogToFile];
}

- (void) removeAllLogs:(NSError * __autoreleasing *)error{
  return [self _removeAllLogs: error];
}

- (void) removeLog:(NSString *)log error:(NSError * __autoreleasing *)error{
  return [self _removeLog:log error:error];
}

- (NSUInteger) startNavigateByLog :(NSString *)log with: (NSError * __autoreleasing *)error{
  return [self _startNavigateByLog:log with:error];
}

- (void) stopNavigeteByLog{
  return [self _stopNavigeteByLog];
}

- (void) regularScanEnabled: (BOOL)enabled{
  [self _regularScanEnabled:enabled];
}

- (void) fastScanEnabled: (BOOL)enabled{
  [self _fastScanEnabled:enabled];
}

- (void) startMQueue:(NSError * __autoreleasing *)error{
  [self startSendingPostRequests:error];
}

- (void) stopMQueue{
  [self stopSendingPostRequests];
}

- (void)changeBaseServerTo:(NSString *) server{
  self.server = server;
//  [self saveSereverToFile];
  [self _changeBaseServerTo:server];
}

- (void) shouldDisplayCalibration: (BOOL)displaying{
  [self _shouldDisplayCalibration:displaying];
}

- (void) startMeasureNearestBeacon:(NCBeacon *)beacon{
  [self _startMeasureNearestBeacon:beacon];
}

- (void) stopMeasureNearestBeacon{
  [self _stopMeasureNearestBeacon];
}

- (void) removeMeasuredBeacon:(NCBeacon *)beacon{
  return [self _removeMeasuredBeacon:beacon];
}

- (void) saveBeaconsXML{
  return [self _saveBeaconsXML];
}

- (void) navigateEnablePdr: (int)subLocId :(double)x :(double)y{
  return [self _navigateEnablePdr:subLocId :x :y];
}

- (void) navigateDisablePdr{
  return [self _navigateDisablePdr];
}

#pragma mark - save & load settings from NSUserDefaults

- (void)saveSettings{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *isPushEnable = @"isPushEnable";
  NSString *isDebugModeEnable = @"isDebugModeEnable";
  NSString *isMainArrowHidden = @"isMainArrowHidden";
  NSString *isSecondArrowHidden = @"isSecondArrowHidden";
  NSString *isStepCounterHidden = @"stepCounterHidden";
  NSString *server = @"server";
  [preferences setValue:[NSNumber numberWithBool:_pushEnable] forKey:isPushEnable];
  [preferences setValue:[NSNumber numberWithBool:_debugModeEnable] forKey:isDebugModeEnable];
  [preferences setValue:[NSNumber numberWithBool:_mainArrowHidden] forKey:isMainArrowHidden];
  [preferences setValue:[NSNumber numberWithBool:_secondArrowHidden] forKey:isSecondArrowHidden];
  [preferences setValue:[NSNumber numberWithBool:_stepCounterHidden] forKey:isStepCounterHidden];
  [preferences setValue:_server forKey:server];
  //  Save to disk
  BOOL didSave = [preferences synchronize];
  if (!didSave){
    DLog(@"ERROR while saving Application settings");
  }
}

- (void)loadSettings{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *isPushEnable = @"isPushEnable";
  NSString *isDebugModeEnable = @"isDebugModeEnable";
  NSString *isMainArrowHidden = @"isMainArrowHidden";
  NSString *isSecondArrowHidden = @"isSecondArrowHidden";
  NSString *isStepCounterHidden = @"stepCounterHidden";
  NSString *server = @"server";
  if ([preferences objectForKey:isPushEnable]){
    NSNumber *enable = [preferences objectForKey:isPushEnable];
    _pushEnable = enable.boolValue;
  }
  if ([preferences objectForKey:isDebugModeEnable]){
    NSNumber *enable = [preferences objectForKey:isDebugModeEnable];
    _debugModeEnable = enable.boolValue;
  }
  if ([preferences objectForKey:isMainArrowHidden]){
    NSNumber *enable = [preferences objectForKey:isMainArrowHidden];
    _mainArrowHidden = enable.boolValue;
  }
  if ([preferences objectForKey:isSecondArrowHidden]){
    NSNumber *enable = [preferences objectForKey:isSecondArrowHidden];
    _secondArrowHidden = enable.boolValue;
  }
  if ([preferences objectForKey:isStepCounterHidden]){
    NSNumber *enable = [preferences objectForKey:isStepCounterHidden];
    _stepCounterHidden = enable.boolValue;
  }
  if ([preferences objectForKey:server]){
    _server = [preferences objectForKey:server];
  }
  else{
    _server = @"https://api.navigine.com";
  }
}

- (void) getServerFromSettings{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *currentLevelKey = @"server";
  NSString *server = [NSString string];
  if ([preferences objectForKey:currentLevelKey]){
    //  Get current level
    server = [preferences objectForKey:currentLevelKey];
  }
  else{
    server = @"https://api.navigine.com";
  }
  self.server = server;
}

@end
