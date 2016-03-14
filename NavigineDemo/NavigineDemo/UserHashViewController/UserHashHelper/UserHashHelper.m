//
//  LoaderHelper.m
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "UserHashHelper.h"
NSString *const kTitleLocationInfo = @"NLocationInfo";

@interface UserHashHelper(){
  int loaderId;
}

@property (nonatomic, strong) NavigineManager *navigineManager;

@end

@implementation UserHashHelper

+(UserHashHelper *) sharedInstance{
  static UserHashHelper * _sharedInstance = nil;
  
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[UserHashHelper alloc] init];
  });
  return _sharedInstance;
}

-(id)init{
  self = [super init];
  if(self){
    loaderId = 0;
    self.navigineManager = [NavigineManager sharedManager];
    self.userHashValid = YES;
    [self getUserHashFromFile];
    NSData *locationData = [[NSUserDefaults standardUserDefaults] dataForKey:kTitleLocationInfo];
    if (locationData) {
      self.loadedLocations = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    } else {
      self.loadedLocations = [NSMutableArray array];
    }
    [self.navigineManager setUserHash:self.userHash];
  }
  return self;
}

-(id)initWithBaseUserHash:(NSString *)userHash{
  self = [super init];
  if(self){
    self.loadedLocations = [NSMutableArray new];
    self.navigineManager = [NavigineManager sharedManager];
    self.userHash = userHash;
    [self saveUserHashToFile:userHash];
    [self.navigineManager setUserHash:self.userHash];
  }
  return self;
}

- (BOOL)parseLocationList{
  NSError *error = nil;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"locations"];
  NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error :&error];
  NSMutableArray *localLocations = [NSMutableArray new];
  if(error){
    NSLog(@"error in fileContent");
  }
  else{
    TBXML *sourceXML = [[TBXML alloc] initWithXMLString:fileContent error:&error];
    if(error || !sourceXML){
      NSLog(@"error in sourceXML %@",[error localizedDescription]);
      return NO;
    }
    TBXMLElement *dataElement = sourceXML.rootXMLElement;
    TBXMLElement *mapElement = [TBXML childElementNamed:@"maps" parentElement:dataElement error:&error];
    if(error || !mapElement){
      NSLog(@"error in maps element %@",[error localizedDescription]);
      return NO;
    }
    TBXMLElement *itemElement = [TBXML childElementNamed:@"item" parentElement:mapElement error:&error];
    if(error || !itemElement){
      NSLog(@"error in item element %@",[error localizedDescription]);
      return NO;
    }
    while (itemElement) {
      LocationInfo *newLocation = [LocationInfo new];
      TBXMLElement *titleElement = [TBXML childElementNamed:@"title" parentElement:itemElement error:&error];
      newLocation.location.name = [TBXML textForElement:titleElement];
      if(error){
        NSLog(@"error in title element %@",[error localizedDescription]);
      }
      TBXMLElement *versionElement = [TBXML childElementNamed:@"version" parentElement:itemElement error:&error];
      if(error){
        NSLog(@"error in title element %@",[error localizedDescription]);
      }
      newLocation.serverVersion = [[TBXML textForElement:versionElement] integerValue];
      NSInteger version;
      NSString *pathToDir = [paths[0] stringByAppendingPathComponent:newLocation.location.name];
      NSString *pathToZip = [[pathToDir stringByAppendingPathComponent:newLocation.location.name] stringByAppendingString:@".zip"];
      
      if ([[NSFileManager defaultManager] fileExistsAtPath: pathToZip ]){
        version = [self.navigineManager currentVersionAt:pathToZip error:&error];
        if(!error)
          newLocation.location.version = version;
      }
      [localLocations addObject:newLocation];
      itemElement = itemElement->nextSibling;
    }
  }

  for(LocationInfo *localLocation in localLocations){
    BOOL flag = NO;
    for(LocationInfo *loadedLocation in self.loadedLocations){
      if([loadedLocation.location.name isEqualToString:localLocation.location.name]){
        loadedLocation.serverVersion = localLocation.serverVersion;
        flag = YES;
        break;
      }
    }
    if(flag)
      continue;
    [self.loadedLocations addObject:localLocation];
  }
  [self saveLocations];
  return YES;
}

- (void) saveLocations{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: kTitleLocationInfo];
  if(self.loadedLocations && self.loadedLocations.count){
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.loadedLocations] forKey:kTitleLocationInfo];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) deleteLocations{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: kTitleLocationInfo];
  [self removeUserHashFromFile];
  self.userHash = nil;
  [self.loadedLocations removeAllObjects];
  self.navigineManager.location = nil;
}

-(void)startDownloadProcess:(NSString *)location :(BOOL)forced{
  if(![self checkInternetConnection]){
    if(self.delegate && [self.delegate respondsToSelector:@selector(errorWhileDownloadingLocationList:)]){
      [self.delegate errorWhileDownloadingLocationList:-1];
    }
  }
  else{
    __block int loadProcess = 0;
    [self.navigineManager setUserHash:self.userHash];
    loaderId = [self.navigineManager startLocationLoader:self.userHash :location];

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      loadProcess = 0;
      while (loadProcess < 100) {
        loadProcess = [self.navigineManager checkLocationLoader:loaderId];
        if(loadProcess == 255){
          [self.navigineManager stopLocationLoader:loaderId];
          [self performSelectorOnMainThread:@selector(errorWhileDownloadingLocationList) withObject:nil waitUntilDone:YES];
          break;
        }
        [self performSelectorOnMainThread:@selector(changeDownloadingLocationListValue:) withObject:[NSNumber numberWithInt: loadProcess] waitUntilDone:YES];
        
        if(loadProcess == 100){
          [self.navigineManager stopLocationLoader:loaderId];
          [self performSelectorOnMainThread:@selector(successfullDownloadingLocationList) withObject:nil waitUntilDone:YES];
          break;
        }
      }
    });
  }
}

- (void) errorWhileDownloadingLocationList{
  self.userHashValid = NO;
  [self removeUserHashFromFile];
  if(self.delegate && [self.delegate respondsToSelector:@selector(errorWhileDownloadingLocationList:)]){
    [self.delegate errorWhileDownloadingLocationList:-2];
  }
}

- (void) successfullDownloadingLocationList{
  [self saveUserHashToFile:self.userHash];
  [self parseLocationList];
  self.userHashValid = YES;
  if(self.delegate && [self.delegate respondsToSelector:@selector(successfullDownloadingLocationList)]){
    [self.delegate successfullDownloadingLocationList];
  }
}

- (void) changeDownloadingLocationListValue:(NSNumber*)loadProcess{
  if(self.delegate && [self.delegate respondsToSelector:@selector(changeDownloadingLocationListValue:)]){
    [self.delegate changeDownloadingLocationListValue:loadProcess.intValue];
  }
}

- (BOOL) checkInternetConnection{
  Reachability* internetReachability = [Reachability reachabilityForInternetConnection];
  NetworkStatus status = internetReachability.currentReachabilityStatus;
  switch (status) {
    case NotReachable:
      return NO;
      break;
    default:
      return YES;
      break;
  }
}

-(void) getUserHashFromFile{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *currentLevelKey = @"userHash";
  if ([preferences objectForKey:currentLevelKey]){
    //  Get current level
    self.userHash = [preferences objectForKey:currentLevelKey];
  }
}

- (void)saveUserHashToFile :(NSString *)userHash{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *currentLevelKey = @"userHash";
  [preferences setValue:userHash forKey:currentLevelKey];
  //  Save to disk
  const BOOL didSave = [preferences synchronize];
  if (!didSave){
    DLog(@"ERROR with saving User Hash");
  }
}

- (void)removeUserHashFromFile{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *currentLevelKey = @"userHash";
  [preferences removeObjectForKey:currentLevelKey];
  const BOOL didSave = [preferences synchronize];
  if (!didSave){
    DLog(@"ERROR with saving User Hash");
  }
}

@end
