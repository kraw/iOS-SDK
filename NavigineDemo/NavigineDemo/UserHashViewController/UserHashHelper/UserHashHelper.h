//
//  LoaderHelper.h
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavigineManager.h"
#import "LocationInfo.h"
#import "Reachability.h"
#import "TBXML.h"

@protocol UserHashHelperDelegate;

@interface UserHashHelper : NSObject
@property (nonatomic, weak) id <UserHashHelperDelegate> delegate;
@property (nonatomic, strong) NSString *userHash;
@property (nonatomic ,strong) NSMutableArray *loadedLocations;
@property (nonatomic) BOOL userHashValid;

+ (UserHashHelper *) sharedInstance;

- (id) init;
- (id) initWithBaseUserHash: (NSString *)userHash;
- (void) startDownloadProcess: (NSString *)location :(BOOL)forced;
- (void) saveLocations;
- (void) deleteLocations;
@end

@protocol UserHashHelperDelegate <NSObject>
@optional
- (void) changeDownloadingLocationListValue :(NSInteger)value;
- (void) errorWhileDownloadingLocationList :(NSInteger)error;
- (void) successfullDownloadingLocationList;
@end