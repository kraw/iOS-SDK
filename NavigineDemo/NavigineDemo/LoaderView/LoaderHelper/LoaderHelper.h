//
//  LoaderHelper.h
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginHelper.h"

@protocol LoaderHelperDelegate;

@interface LoaderHelper : NSObject<LoginHelperDelegate>
@property (nonatomic, weak) id <LoaderHelperDelegate> loaderDelegate;
@property (nonatomic, strong) NSString *userHash;
@property (nonatomic ,strong) NSMutableArray *loadedLocations;

+ (LoaderHelper *) sharedInstance;

- (id) init;
- (id) initWithBaseUserHash: (NSString *)userHash;
- (void) startDownloadProcess: (LocationInfo *)location :(BOOL)forced;
- (void) stopDownloadProcess: (LocationInfo *)location;
- (void) startNavigine;
- (void) stopNavigine;
- (void) startRangePushes;
- (void) startRangeVenues;
- (void) selectLocation :(LocationInfo *)location error:(NSError *__autoreleasing *)error;
- (void) deleteLocation :(NSString *)locationForDelete;
- (void) deleteAllLocations;
- (void) refreshLocationList;
- (void) reloadLocationList;
@end

@protocol LoaderHelperDelegate <NSObject>
@optional
- (void) changeDownloadingValue :(LocationInfo *)value;
- (void) errorWhileDownloading :(NSInteger)error :(LocationInfo *)location;
- (void) successfullDownloading :(LocationInfo *)location;
- (void) locationListUpdateSuccessful;
- (void) locationListUpdateError:(NSInteger)error;
@end