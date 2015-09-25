//
//  MainViewController.h
//  bt5
//
//  Created by Администратор on 07/11/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KontaktSDK.h"

@interface MainViewController : UIViewController<CLLocationManagerDelegate, KTKBluetoothManagerDelegate, CBCentralManagerDelegate>{
  dispatch_source_t newTimer;
  UIImage *pushImage;
  NSString *pushTitle;
  NSString *pushContent;
  
  NSMutableString *consoleText;
  bool ready;
  BOOL _BLEThreadBusy;
  NSMutableArray *readyBeacons;
  NSInteger lockedBeacons;
  NSInteger notAuthorisedBeacons;
  NSInteger beaconsWithIncorrectPassword;
  NSInteger notDiscoverededBeacons;
  NSInteger notConnectedBeacons;
  NSInteger beaconsWithIncorrectMajorOrMinor;
  
  __block BOOL btnStartPressed;
  NSInteger beaconsVisibleForPrepare;
  KTKClient *client;
  KTKBeaconManager *beaconManager;
  KTKLocationManager *locationManager;
  KTKBeaconDevice *beacon;
  KTKError *ktkError;
  
  NSMutableArray *visibleBeacons;
  
  NSString* PathToNavSVGFile;
  CLLocationManager *_locationManager1;
  CLBeaconRegion    *_region1;
  CBCentralManager *_centralManager;
  NSInteger doneBeacons;
  
}

@property (weak, nonatomic) IBOutlet UILabel *txtVisibleBLE;
@property (weak, nonatomic) IBOutlet UILabel *prepared;

- (IBAction)backPressed:(id)sender;
- (IBAction)start:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *txtConsole;
@property (copy, nonatomic) NSString *txPower;
@property (copy, nonatomic) NSString *advertisingInterval;

@property (nonatomic,strong) NSString *login;
@property (nonatomic,strong) NSString *passwd;

@end
