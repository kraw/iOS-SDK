//
//  LoginHelper.h
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

typedef NS_ENUM(NSInteger, LoadingError) {
  LoadingErrorInvalidRequest = 0,
  LoadingErrorInternetConnection,
  LoadingErrorInvalidCredentials,
  LoadingErrorInvalidContent,
  LoadingErrorInternalError
};

@protocol LoginHelperDelegate;

@interface LoginHelper : NSObject
@property (nonatomic, weak) id <LoginHelperDelegate> delegate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *passwd;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userHash;
@property (nonatomic ,strong) NSMutableArray *loadedLocations;
@property (nonatomic) BOOL userHashValid;

+ (LoginHelper *) sharedInstance;

- (id) init;
- (id) initWithBaseUserHash: (NSString *)userHash;
- (void) startDownloadProcess: (NSString *)location :(BOOL)forced;
- (void) saveLocations;
- (void) deleteLocations;
- (void) refreshLocationList;
@end

@protocol LoginHelperDelegate <NSObject>
@optional
- (void) changeDownloadingLocationListValue :(NSInteger)value;
- (void) errorWhileDownloadingLocationList :(LoadingError)error;
- (void) successfullDownloadingLocationList;
@end