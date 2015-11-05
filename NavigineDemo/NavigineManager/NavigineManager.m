//
//  NaviganeManager.m
//  Navitech
//
//  Created by Valentine on 17.04.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "NavigineManager.h"
#import "NavigineSDK.h"

#define kSTRICT_MODE false

UILocalNotification* localNotification;

@interface NavigineManager(Protected)
@property (nonatomic, strong) Location *_location;

- (NSString*) _getAccelerometer;
- (NSString*) _getGyroscope;
- (NSString*) _getMagnetometer;
- (NSString*) _getOrientation;

- (int) _getConnectionStatusWriteSocket;
- (int) _getConnectionStatusReadSocket;
- (void) _setServer: (const char*) serverIP  andPort: (int) writePort;
- (int) _setConnectionStatus: (int) i;
- (void) _launchNavigineSocketThreads: (const char*)serverIP : (int)serverWritePort;
- (int) _sendPacket;

- (int) _getCurrentVersion :(NSInteger *)currentVersion at :(NSString *)zipPath;
- (void) get_location:(Location *)Location;
- (void) _saveUserHash :(NSString *)userHash;
- (void) _setUserHash:(NSString *)userHash;

- (NSString *) _startSaveLogToFile;
- (void) _stopSaveLogToFile;

- (void) _removeAllLogs:(NSError **)error;
- (void) _removeLog:(NSString *)log error:(NSError **)error;

- (NSUInteger)_startNavigateByLog :(NSString *)log with: (NSError **)error;
- (void)_stopNavigeteByLog;
- (void) _regularScanEnabled: (BOOL)enabled;
- (void) _fastScanEnabled: (BOOL)enabled;

- (void) _changeSensorsFrequencyTo:(double) frequency;

- (void)_startMQueue;
- (void)_stopMQueue;
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
  if (self = [super init]) {
//    [self downloadContent:@"B2d5-efcb-0e91-3608"
//                 location:@"Kotelniki"
//              forceReload:YES
//             processBlock:^(NSInteger loadProcess) {
//               NSLog(@"%zd",loadProcess);
//             } successBlock:^{
//               NSLog(@"Success!");
//             } failBlock:^(NSError *error) {
//               if(error)
//                 NSLog(@"%@",error);
//             }];
    super.delegate = self;
    super.btStateDelegate = self;
    locationId = 0;
    pushEnable = NO;
    
    localNotification = [[UILocalNotification alloc] init];
    localNotification.userInfo = nil;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
  }
  return self;
}//init

- (BOOL)isNavigineFine {
  if([self getNavigationResults].ErrorCode != 0 && !DEBUG_MODE) {
    return NO;
  }
  return YES;
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
  return  [super startLocationLoader :userID :location :YES];
}

//modyfy in nex release!!!!!
- (NSInteger) currentVersion:(NSError * __autoreleasing *)error{
  NSInteger currentVersion = [super currentVersion:error];
  if(*error){
    return -1;
  }
  self.currentVersion = currentVersion;
  return currentVersion;
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

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
  return self;
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
  self.location = self._location;
}

- (void) changePushNotificationAvialiability{
  if(pushEnable) pushEnable = NO;
  else pushEnable = YES;
}

#pragma mark - NavigineCoreDelegate methods


- (void)didRangePushWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image{
  if(!pushEnable) return;
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

- (void) navigationResultsInBackground :(NavigationResults) navigationResults{
  NavigationResults backGroundNavResults = navigationResults;
  localNotification.alertBody = [NSString stringWithFormat:@"x=%lf y=%lf error = %zd",backGroundNavResults.X,backGroundNavResults.Y, backGroundNavResults.ErrorCode];
  //[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void) updateSteps:(NSNumber *)numberOfSteps with:(NSNumber *)distance{
  if(self.stepsDelegate && [self.stepsDelegate respondsToSelector:@selector(updateSteps:with:)])
    [self.stepsDelegate updateSteps:numberOfSteps with:distance];
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
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"bluethoothChange" object:nil userInfo:@{@"state":[NSNumber numberWithInt:state]}];
}

#pragma mark - hidden methods of NavigineCore

- (NSString*) getAccelerometer{
  return [self _getAccelerometer];
}

- (NSString*) getGyroscope{
  return [self _getGyroscope];
}

- (NSString*) getMagnetometer{
  return [self _getMagnetometer];
}

- (NSString*) getOrientation{
  return [self _getOrientation];
}

- (int) getConnectionStatusWriteSocket{
  return [self _getConnectionStatusWriteSocket];
}

- (int) getConnectionStatusReadSocket{
  return [self _getConnectionStatusReadSocket];
}

- (void) setServer :(const char*)serverIP andPort :(int)writePort{
  return [self _setServer:serverIP andPort:writePort];
}

- (int) setConnectionStatus :(int)i{
  return [self _setConnectionStatus:i];
}

- (void) launchNavigineSocketThreads :(const char*) serverIP :(int)serverWritePort{
  return [self _launchNavigineSocketThreads:serverIP :serverWritePort];
}

- (int) sendPacket{
  return [self _sendPacket];
}

- (int) getCurrentVersion :(NSInteger *)currentVersion at :(NSString *)zipPath{
  return [self _getCurrentVersion:currentVersion at:zipPath];
}

- (NSString *) startSaveLogToFile{
  return [self _startSaveLogToFile];
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

- (void) startMQueue{
  [self _startMQueue];
}

- (void) stopMQueue{
  [self _stopMQueue];
}
@end
