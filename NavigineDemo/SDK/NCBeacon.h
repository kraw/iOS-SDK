//
//  NCBeacon.h
//  NavigineSDK
//
//  Created by Администратор on 01/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
  NCBeaconOld = 0,
  NCBeaconNew,
  NCBeaconMod,
  NCBeaconDel,
} NCBeaconStatus;

@interface NCBeacon : NSObject
@property (nonatomic, assign) int id;
@property (nonatomic, assign) int locationId;
@property (nonatomic, assign) int subLocationId;
@property (nonatomic, assign) int major;
@property (nonatomic, assign) int minor;
@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) NCBeaconStatus status;
@property (nonatomic, assign) double kX;
@property (nonatomic, assign) double kY;

- (id) initWithBeacon: (NCBeacon*) beacon;
@end
