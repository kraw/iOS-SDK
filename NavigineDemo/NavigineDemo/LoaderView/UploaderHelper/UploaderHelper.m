//
//  UploaderHelper.m
//  Navigine
//
//  Created by Администратор on 04/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "UploaderHelper.h"

@interface UploaderHelper(){
  NSLock *uploaderLock;
}
@property(nonatomic,strong) NSMutableArray *uploaderArray;
@property (nonatomic, strong) NavigineManager *navigineManager;
@property (nonatomic, strong) LocationInfo *currentLocation;
@property (nonatomic, strong) NSTimer *uploaderTimer;
@end

@implementation UploaderHelper

+(UploaderHelper *) sharedInstance{
  static UploaderHelper * _sharedInstance = nil;
  
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[UploaderHelper alloc] init];
  });
  return _sharedInstance;
}

-(id) init{
  self = [super init];
  if(self){
    self.uploaderTimer = nil;
    uploaderLock = [NSLock new];
    self.uploaderArray = [NSMutableArray new];
    self.navigineManager = [NavigineManager sharedManager];
    self.userHash = self.navigineManager.userHash;
  }
  return self;
}

- (void) startUploadCurrentLocation{
//  LocationInfo *currentLocation = [[LocationInfo alloc] init];
//  currentLocation.location = self.navigineManager.location;
  if(![self checkInternetConnection]){
    if(self.uploaderDelegate && [self.uploaderDelegate respondsToSelector:@selector(errorWhileUploading::)]){
      [self.uploaderDelegate errorWhileUploading:-1 :_currentLocation];
    }
  }
  else{
    __block int loadProcess = 0;
    [self.navigineManager stopNavigine];
    NSInteger uploaderId = [self.navigineManager startLocationUploader:self.userHash :self.navigineManager.location.name];
    Uploader *uploader = [[Uploader alloc] initWithLocation:_currentLocation andUploaderId:uploaderId];
    [uploaderLock lock];
    [self.uploaderArray addObject:uploader];
    [uploaderLock unlock];
    if(self.uploaderTimer == nil){
      self.uploaderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10
                                                          target:self
                                                        selector:@selector(uploaderRoutine:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
  }
}

- (void) startUploadProcess: (LocationInfo *)location{
  if(![self checkInternetConnection]){
    if(self.uploaderDelegate && [self.uploaderDelegate respondsToSelector:@selector(errorWhileUploading::)]){
      [self.uploaderDelegate errorWhileUploading:-1 :location];
    }
  }
  else{
    __block int loadProcess = 0;
    NSInteger uploaderId = [self.navigineManager startLocationUploader:self.navigineManager.userHash :location.location.name];
    Uploader *uploader = [[Uploader alloc] initWithLocation:location andUploaderId:uploaderId];
    [uploaderLock lock];
    [self.uploaderArray addObject:uploader];
    [uploaderLock unlock];
    if(self.uploaderTimer == nil){
      self.uploaderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10
                                                          target:self
                                                        selector:@selector(uploaderRoutine:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
  }
}

- (void) stopUploadProcess: (LocationInfo *)location{
  [uploaderLock lock];
  for (Uploader *uploader in self.uploaderArray) {
    if([uploader.location.location.name isEqualToString:location.location.name]){
      [self.navigineManager stopLocationLoader: uploader.uploaderId];
      [self.uploaderArray removeObject:uploader];
      break;
    }
  }
  [uploaderLock unlock];
}

- (void)uploaderRoutine :(NSTimer *)timer{
  [uploaderLock lock];
  for (Uploader *uploader in self.uploaderArray) {
    NSInteger loadProcess = [self.navigineManager checkLocationUploader: uploader.uploaderId];
    if(loadProcess < 0){
      [self.navigineManager stopLocationUploader:uploader.uploaderId];
      [self errorWhileUploading:uploader.location];
      [self.uploaderArray removeObject:uploader];
      if(self.uploaderArray.count == 0){
        [self.uploaderTimer invalidate];
        self.uploaderArray = nil;
      }
      break;
    }
    uploader.location.loadingProcess = loadProcess;
    [self changeUploadingValue:uploader.location];
    
    if(loadProcess == 100){
      [self.navigineManager stopLocationLoader: uploader.uploaderId];
      [self successfullUploading:uploader.location];
      [self.uploaderArray removeObject:uploader];
      if(self.uploaderArray.count == 0){
        [self.uploaderTimer invalidate];
        self.uploaderTimer = nil;
      }
      break;
    }
  }
  [uploaderLock unlock];
}

- (void)selectLocation :(LocationInfo *)location error:(NSError *__autoreleasing *)error{
  _currentLocation = location;
}

- (void) errorWhileUploading: (LocationInfo *)tmpLocation{
  if(self.uploaderDelegate && [self.uploaderDelegate respondsToSelector:@selector(errorWhileUploading::)]){
    [self.uploaderDelegate errorWhileUploading:-2 :tmpLocation];
  }
}

- (void) successfullUploading :(LocationInfo *)tmpLocation{
  if(self.uploaderDelegate && [self.uploaderDelegate respondsToSelector:@selector(successfullUploading:)]){
    [self.uploaderDelegate successfullUploading :tmpLocation];
  }
}

- (void) changeUploadingValue:(LocationInfo *)tmpLocation{
  if(self.uploaderDelegate && [self.uploaderDelegate respondsToSelector:@selector(changeUploadingValue:)]){
    [self.uploaderDelegate changeUploadingValue:tmpLocation];
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

@end
