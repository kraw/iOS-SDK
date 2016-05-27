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
#import "NCBeacon.h"
#import <time.h>

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
#define kColorFromHex(color)[UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0]

@protocol NavigineManagerDelegate;
@protocol NavigineManagerStepsDelegate;
@protocol NavigineManagerMeasureBeaconDelegate;


@interface NavigineManager : NavigineCore <NavigineCoreDelegate, NCBluetoothStateDelegate>{
    BOOL pushEnable;
}
@property (nonatomic, assign) BOOL debugModeEnable;
@property (nonatomic, assign) BOOL loadFromURL;
@property (nonatomic, strong) Venue *superVenue;
@property (nonatomic, strong) NSArray *superUsers;
@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, assign) BOOL su;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, assign) BOOL modified;
@property (nonatomic, weak) NSObject <NavigineManagerDelegate> *dataDelegate;
@property (nonatomic, weak) NSObject <NavigineManagerStepsDelegate> *stepsDelegate;
@property (nonatomic, weak) NSObject <NavigineManagerMeasureBeaconDelegate> *beaconMeasureDelegate;
//@property (nonatomic, strong) Location *location;

@property (nonatomic, strong) NSString *userHash;
@property (nonatomic, strong) NSMutableArray *venues;

@property double DEFAULT_WIDTH;
@property double DEFAULT_HEIGHT;

- (NSArray *) arrayWithAccelerometerData;
- (NSArray *) arrayWithGyroscopeData;
- (NSArray *) arrayWithMagnetometerData;

+ (id) sharedManager;
- (void) startNavigine;

- (void) loadArchive:(NSString *)location error:(NSError **)error;

- (int) checkLocationLoader :(NSInteger) loaderId;
- (void) stopLocationLoader :(NSInteger) loaderId;
- (int) startLocationLoader :(NSString *)userID :(NSString *)location;

- (int) startLocationUploader :(NSString *)userHash :(NSString*)location;
- (int) checkLocationUploader :(NSInteger)id;
- (void) stopLocationUploader :(NSInteger)id;
- (int) startLocationLoader :(NSString *)userID :(NSString *) location :(BOOL)forced;

- (CGSize) sizeForImageAtIndex:(NSInteger)index error:(NSError **)error;
- (CGSize) sizeForImageAtId:(NSInteger)id error:(NSError **)error;
- (NSString *) currentVersionAt:(NSString *)path error:(NSError **)error;

- (NSString *) startSaveLogToFile;
- (void) addCheckPointToLogFile: (NSString *)checkPoint;
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

- (void) startMeasureNearestBeacon:(NCBeacon *)beacon;
- (void) stopMeasureNearestBeacon;
- (void) saveBeaconsXML;
- (void) removeMeasuredBeacon:(NCBeacon *)beacon;

- (void) navigateEnablePdr :(int)subLocId :(double)x :(double)y;
- (void) navigateDisablePdr;
@end

@protocol NavigineManagerDelegate <NSObject>
- (void) didRangeBeacons: (NSArray *)beacons;
- (void) getLatitude: (double)latitude Longitude:(double)longitude;
@end

@protocol NavigineManagerStepsDelegate <NSObject>
- (void) updateSteps: (NSNumber *)numberOfSteps with:(NSNumber *)distance;
- (void) yawCalculatedByIos: (double)yaw;
@end

@protocol NavigineManagerMeasureBeaconDelegate <NSObject>
- (void) beaconFounded:(NCBeacon *)ncBeacon error:(NSError **)error;
- (void) measuringBeaconWithProcess:(NSInteger)process;
@end
