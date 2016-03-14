//
//  LoaderHelper.m
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "LoaderHelper.h"
#import "Loader.h"

@interface LoaderHelper(){
  NSLock *loaderLock;
  NSLock *loadArchiveLock;
}
@property(nonatomic,strong) NSMutableArray *loaderArray;

@property (nonatomic, strong) NavigineManager *navigineManager;
@property (nonatomic, strong) LoginHelper *userHashHelper;
@property (nonatomic, strong) NSTimer *loaderTimer;

@end

@implementation LoaderHelper

+(LoaderHelper *) sharedInstance{
  static LoaderHelper * _sharedInstance = nil;
  
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[LoaderHelper alloc] init];
  });
  return _sharedInstance;
}

-(id)init{
  self = [super init];
  if(self){
    loaderLock = [NSLock new];
    loadArchiveLock = [NSLock new];
    self.loadedLocations = [NSMutableArray new];
    self.loaderArray = [NSMutableArray new];
    self.loaderTimer = nil;
    self.navigineManager = [NavigineManager sharedManager];
    self.userHashHelper = [LoginHelper sharedInstance];
    self.userHash = self.userHashHelper.userHash;
    self.loadedLocations = self.userHashHelper.loadedLocations;
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
    [self.navigineManager setUserHash:self.userHash];
  }
  return self;
}

-(void)startDownloadProcess:(LocationInfo *)location :(BOOL)forced{
  self.userHash = self.userHashHelper.userHash;
  if(![self checkInternetConnection]){
    if(self.loaderDelegate && [self.loaderDelegate respondsToSelector:@selector(errorWhileDownloading::)]){
      [self.loaderDelegate errorWhileDownloading:-1 :location];
    }
  }
  else{
    __block int loadProcess = 0;
    [self.navigineManager setUserHash:self.userHash];
    NSInteger loaderId = [self.navigineManager startLocationLoader:self.userHash :location.location.name];
    Loader *loader = [[Loader alloc] initWithLocation:location andLoaderId:loaderId];
    [loaderLock lock];
    [self.loaderArray addObject:loader];
    [loaderLock unlock];
//    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if(self.loaderTimer == nil){
      self.loaderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10
                                       target:self
                                     selector:@selector(loaderRoutine:)
                                     userInfo:nil
                                      repeats:YES];
    }
//      loadProcess = 0;
//      while (loadProcess < 100) {
//        loadProcess = [self.navigineManager checkLocationLoader];
//        if(loadProcess == 255){
//          [self.navigineManager stopLocationLoader];
//          [self performSelectorOnMainThread:@selector(errorWhileDownloading :) withObject:location waitUntilDone:YES];
//          break;
//        }
//        
//        location.loadingProcess = loadProcess;
//        [self performSelectorOnMainThread:@selector(changeDownloadingValue:) withObject:location waitUntilDone:YES];
//        
//        if(loadProcess == 100){
//          [self.navigineManager stopLocationLoader];
//          [self performSelectorOnMainThread:@selector(successfullDownloading :) withObject:location waitUntilDone:YES];
//          break;
//        }
//      }
//    });
  }
}

- (void) stopDownloadProcess: (LocationInfo *)location{
  [loaderLock lock];
  for (Loader *loader in self.loaderArray) {
    if([loader.location.location.name isEqualToString:location.location.name]){
      [self.navigineManager stopLocationLoader: loader.loaderId];
      [self.loaderArray removeObject:loader];
      break;
    }
  }
  [loaderLock unlock];
}

-(void) loaderRoutine:(NSTimer *)timer{
  [loaderLock lock];
  for (Loader *loader in self.loaderArray) {
    NSInteger loadProcess = [self.navigineManager checkLocationLoader: loader.loaderId];
    if(loadProcess == 255){
      [self.navigineManager stopLocationLoader: loader.loaderId];
      [self errorWhileDownloading:loader.location];
      [self.loaderArray removeObject:loader];
      if(self.loaderArray.count == 0){
        [self.loaderTimer invalidate];
        self.loaderTimer = nil;
      }
      break;
    }
    loader.location.loadingProcess = loadProcess;
    [self changeDownloadingValue:loader.location];
    
    if(loadProcess == 100){
      [self.navigineManager stopLocationLoader: loader.loaderId];
      [self successfullDownloading:loader.location];
      [self.loaderArray removeObject:loader];
      if(self.loaderArray.count == 0){
        [self.loaderTimer invalidate];
        self.loaderTimer = nil;
      }
      break;
    }
  }
  [loaderLock unlock];
}

- (void) errorWhileDownloading: (LocationInfo *)tmpLocation{
  if(self.loaderDelegate && [self.loaderDelegate respondsToSelector:@selector(errorWhileDownloading::)]){
    [self.loaderDelegate errorWhileDownloading:-2 :tmpLocation];
  }
}

- (void) successfullDownloading :(LocationInfo *)tmpLocation{
  if(self.loaderDelegate && [self.loaderDelegate respondsToSelector:@selector(successfullDownloading:)]){
    [self.loaderDelegate successfullDownloading :tmpLocation];
  }
}

- (void) changeDownloadingValue:(LocationInfo *)tmpLocation{
    if(self.loaderDelegate && [self.loaderDelegate respondsToSelector:@selector(changeDownloadingValue:)]){
      [self.loaderDelegate changeDownloadingValue:tmpLocation];
    }
}

- (void) startNavigine{
  [self.navigineManager startNavigine];
}

- (void) stopNavigine{
  [self.navigineManager stopNavigine];
}

- (void) startRangePushes{
  [self.navigineManager startRangePushes];
}

- (void) startRangeVenues{
  [self.navigineManager startRangeVenues];
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

- (void)selectLocation :(LocationInfo *)location error:(NSError *__autoreleasing *)error{
  
  [loadArchiveLock lock];
  [self.navigineManager stopNavigine];
  [self loadArchive:location error:error];
  [loadArchiveLock unlock];
  
  if(*error) return;
  for(LocationInfo *tmpLocation in self.loadedLocations){
    tmpLocation.isSet = NO;
  }
  location.isDownloaded = YES;
  location.isSet = YES;
  location.loadingProcess = 0;
  [self.navigineManager.venues removeAllObjects];
  self.userHashHelper.loadedLocations = self.loadedLocations;
  [self.userHashHelper saveLocations];
  [self startNavigine];
  [self startRangePushes];
  [self startRangeVenues];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"setLocation" object:nil userInfo:@{@"locationName":location.location.name}];
}

-(void) deleteLocation :(NSString *)location{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSArray *directoryList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:paths[0] error:nil];
  
  for(NSString *directory in directoryList){
    if([directory isEqualToString:location]){
      [[NSFileManager defaultManager] removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:directory] error:nil];
      break;
    }
  }
  
  for(LocationInfo *locationForDelete in self.loadedLocations){
    if([locationForDelete.location.name isEqualToString:location]){
      [self.loadedLocations removeObject:locationForDelete];
      break;
    }
  }
  
  self.userHashHelper.loadedLocations = self.loadedLocations;
  
  [self.userHashHelper saveLocations];
  if([self.navigineManager.location.name isEqualToString:location])
    self.navigineManager.location = nil;
}

- (void) loadArchive:(LocationInfo *)location error:(NSError *__autoreleasing *)error{
  self.navigineManager.userHash = self.userHash;
  [self.navigineManager loadArchive:location.location.name error:error];
  if(!*error){
    location.location.version = self.navigineManager.location.version;
    location.location = [[Location alloc] initWithLocation:self.navigineManager.location];
  }
  else{
    self.navigineManager.location = nil;
  }
}

-(void) deleteAllLocations{
  [self.loadedLocations removeAllObjects];
  [self.userHashHelper deleteLocations];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSArray *directoryList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:paths[0] error:nil];
  for(NSString *directory in directoryList){
    if ([[NSFileManager defaultManager] fileExistsAtPath: [paths objectAtIndex:0] ]){
      [[NSFileManager defaultManager] removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:directory] error:nil];
    }
  }
}

- (void) refreshLocationList{
  self.loadedLocations = self.userHashHelper.loadedLocations;
}

- (void)reloadLocationList{
  self.userHashHelper.delegate = self;
  [self.userHashHelper startDownloadProcess:@"" :NO];
}


#pragma mark UserHashDelegateMethods

-(void) errorWhileDownloadingLocationList:(NSInteger)error{
  self.userHashHelper.delegate = nil;
  if(self.loaderDelegate && [self.loaderDelegate respondsToSelector:@selector(locationListUpdateError:)]){
    [self.loaderDelegate locationListUpdateError:error];
  }
}

-(void) successfullDownloadingLocationList{
  [self refreshLocationList];
  self.userHashHelper.delegate = nil;
  if(self.loaderDelegate && [self.loaderDelegate respondsToSelector:@selector(locationListUpdateSuccessful)]){
    [self.loaderDelegate locationListUpdateSuccessful];
  }
}


@end
