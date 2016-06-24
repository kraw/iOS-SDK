//
//  TextView.m
//  NavigineDemo
//
//  Created by Администратор on 15/12/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "TextView.h"

@interface TextView(){
  NSTimer *refreshTimer;
}

@property (nonatomic,strong) NavigineManager *navigineManager;
@end


@implementation TextView: UIViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  refreshTimer = nil;
  self.title = @"DEBUG MODE";
  
  self.navigineManager = [NavigineManager sharedManager];
  self.navigineManager.dataDelegate = self;
//  self.navigineManager.delegate = self;
  [self addLeftButton];
  
  self.sv.contentSize = CGSizeMake(320, 520);
  
  [self.bleList setNumberOfLines:0];
  NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
  NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
  self.buildVersion.text = [NSString stringWithFormat:@"v.%@ b.%@",version,build];
  [self startTimer];
}


- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  _navigineManager.dataDelegate = self;
}

- (void)addLeftButton {
  UIImage *buttonImage = [UIImage imageNamed:@"btnMenu"];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  [leftButton addTarget:self action:@selector(menuPressed:)  forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
  
}

- (IBAction)menuPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
    [self.slidingPanelController closePanel];
  }
  else {
    [self.slidingPanelController openLeftPanel];
  }
}

- (void) startTimer{
  if (refreshTimer==nil) {
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval: .1
                                                    target: self
                                                  selector: @selector(onTimerTV)
                                                  userInfo: nil
                                                   repeats: YES];
  }
}



-(void)onTimerTV{
  NSArray *accelerometer = [self.navigineManager arrayWithAccelerometerData];
  NSArray *gyroscope = [self.navigineManager arrayWithGyroscopeData];
  NSArray *magnetometer = [self.navigineManager arrayWithMagnetometerData];
  self.acc.text  = accelerometer.lastObject;
  self.om.text   = gyroscope.lastObject;
  self.magn.text = magnetometer.lastObject;
  self.accLabel.text = [NSString stringWithFormat:@"Accelerometer(%zd)",accelerometer.count];
  self.magnetLabel.text = [NSString stringWithFormat:@"Magnetometer(%zd)",magnetometer.count];
  self.gyroLabel.text = [NSString stringWithFormat:@"Gyroscope(%zd)",gyroscope.count];
  
  self.txtResult.text = [NSString stringWithFormat:@"x: %3.3lf y: %3.3lf",[self.navigineManager getNavigationResults].X, [self.navigineManager getNavigationResults].Y];
  self.errCode.text = [NSString stringWithFormat:@"%zd Sublocation: %zd",[self.navigineManager getNavigationResults].ErrorCode, [self.navigineManager getNavigationResults].outSubLocation];
  
}

- (void) didRangeBeacons:(NSArray *)beacons{
  self.bleList.height = 8.f * beacons.count;
  self.bleCount.text = [NSString stringWithFormat:@"BLE devices (%zd):",beacons.count];
  self.bleList.text = @"";
  int i = 0;
  
  NSArray *sortedArray = [beacons sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSNumber *first = ((NSDictionary*)a)[@"rssi"];
    NSNumber *second = ((NSDictionary*)b)[@"rssi"];
    
    if (first.intValue < second.intValue) {
      return NSOrderedDescending;
    }
    else if (first.intValue > second.intValue) {
      return NSOrderedAscending;
    }
    // rssi is the same
    return NSOrderedSame;
  }];
  
  for(NSDictionary *b in sortedArray){
    NSNumber *major = b[@"major"];
    NSNumber *minor = b[@"minor"];
    NSString *uuid = b[@"uuid"];
    NSNumber *rssi = b[@"rssi"];
    NSNumber *proximity = b[@"proximity"];
    
    NSString *beaconProp=[NSString stringWithFormat:@"%03zd  %05d  %05d  %19@ %zd\n",rssi.longValue,major.intValue,minor.intValue,uuid,proximity.longValue];
    NSString *tmp = [[self.bleList.text stringByAppendingFormat:@"%02d)",i+1] stringByAppendingString:@" "];
    self.bleList.text = [tmp stringByAppendingString:beaconProp];
    i++;
  }
}

- (void) getLatitude:(double)latitude Longitude:(double)longitude{
  self.txtGPS.text = [NSString stringWithFormat:@"lat: %3.3f long: %3.3f",latitude,longitude];
}

@end
