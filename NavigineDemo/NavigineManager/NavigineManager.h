//
//  NaviganeManager.h
//  Navitech
//
//  Created by Valentine on 17.04.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NavigineSDK.h"
#import "Location.h"
#import "PopTextViewController.h"
#import "BTOffView.h"
#import "GEOOffView.h"


#define DEBUG_MODE NO
#define kColorFromHex(color)[UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0]

#define CONNECTION_STATUS_DISCONNECTED 0
#define CONNECTION_STATUS_CONNECTING   1
#define CONNECTION_STATUS_CONNECTED    2
#define SERVER_DEFAULT_INPUT_PORT      27016
#define SERVER_DEFAULT_OUTPUT_PORT     27015

@protocol NavigineManagerDelegate;
@protocol NavigineManagerStepsDelegate;


@interface NavigineManager : NavigineCore <NavigineCoreDelegate, NCBluetoothStateDelegate>{
    NSInteger locationId;
    BOOL pushEnable;
}
@property (nonatomic, strong) NSArray *superUsers;
@property (nonatomic, assign) BOOL su;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, weak) NSObject <NavigineManagerDelegate> *dataDelegate;
@property (nonatomic, weak) NSObject <NavigineManagerStepsDelegate> *stepsDelegate;

//@property (nonatomic, strong,readonly) Location *location;

@property (nonatomic, strong) NSString *userHash;
@property (nonatomic, assign) NSInteger currentVersion;
@property (nonatomic, strong) NSMutableArray *venues;

@property double DEFAULT_WIDTH;
@property double DEFAULT_HEIGHT;

- (NSArray *) arrayWithAccelerometerData;
- (NSArray *) arrayWithGyroscopeData;
- (NSArray *) arrayWithMagnetometerData;

+ (id) sharedManager;
- (void) startNavigine;

- (void) loadArchive:(NSString *)location error:(NSError **)error;
- (BOOL)isNavigineFine;
- (int) checkLocationLoader :(NSInteger) loaderId;
- (void) stopLocationLoader :(NSInteger) loaderId;
- (int) startLocationLoader :(NSString *)userID :(NSString *)location;

- (CGSize) sizeForImageAtIndex:(NSInteger)index error:(NSError **)error;
- (CGSize) sizeForImageAtId:(NSInteger)id error:(NSError **)error;
- (NSInteger) currentVersion:(NSError **)error;
- (NSInteger) currentVersionAt:(NSString *)path error:(NSError **)error;

- (int) getConnectionStatusWriteSocket;
- (int) getConnectionStatusReadSocket;
- (void) setServer: (const char*) serverIP  andPort: (int) writePort;
- (int) setConnectionStatus: (int) i;
- (void) launchNavigineSocketThreads: (const char*)serverIP : (int)serverWritePort;
- (int) sendPacket;

- (NSString *) startSaveLogToFile;
- (void) stopSaveLogToFile;
- (void) removeAllLogs:(NSError **)error;
- (void) removeLog:(NSString *)log error:(NSError **)error;
- (NSUInteger) startNavigateByLog :(NSString *)log with: (NSError **)error;
- (void) stopNavigeteByLog;
- (void) regularScanEnabled: (BOOL)enabled;
- (void) fastScanEnabled: (BOOL)enabled;

- (void) startMQueue:(NSError **)error;
- (void) stopMQueue;
- (void) changeBaseServerTo:(NSString *) server;
- (void) shouldDisplayCalibration: (BOOL)displaying;
- (void) changePushNotificationAvialiability;
@end

@protocol NavigineManagerDelegate <NSObject>
- (void) didRangeBeacons: (NSArray *)beacons;
- (void) getLatitude: (double)latitude Longitude:(double)longitude;
@end

@protocol NavigineManagerStepsDelegate <NSObject>
- (void) updateSteps: (NSNumber *)numberOfSteps with:(NSNumber *)distance;
- (void) yawCalculatedByIos: (double)yaw;
@end