//
//  MainViewController.m
//  bt5
//
//  Created by Администратор on 07/11/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "UIAlertView+Blocks.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  doneBeacons = 0;
  beaconsVisibleForPrepare = 0;
  btnStartPressed = NO;
  consoleText = [NSMutableString new];
  // Do any additional setup after loading the view, typically from a nib.
  client = [KTKClient new];
  //Navigine API Key
  [client setApiKey:_login];
  //[client setApiKey:@"opdimQjzQiujuUZAbqzwVcwlsaOtdELE"];
  //Integris API Key
  //[client setApiKey:@"soQRCiaWDWcYIXxOFZkWxBNbrgDVfNbZ"];
  //atrium qPcTKyOEkSUPeKcUFpIhOyhYzdmpjvtk
  visibleBeacons = [[NSMutableArray alloc] init];
  readyBeacons = [[NSMutableArray alloc] init];
  lockedBeacons = 0;
  notAuthorisedBeacons = 0;
  beaconsWithIncorrectPassword = 0;
  notDiscoverededBeacons = 0;
  notConnectedBeacons = 0;
  
  
  beaconManager = [KTKBeaconManager new];
  beaconManager.delegate = self;
  [beaconManager startFindingDevices];
  
  _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  _locationManager1 = [[CLLocationManager alloc] init];
  
  _locationManager1.delegate = self;
  
  // Kontakt.io
  NSUUID *sUUID1 = [[NSUUID alloc] initWithUUIDString:@"F7826DA6-4FA2-4E98-8024-BC5B71E0893E"];
  _region1 = [[CLBeaconRegion alloc] initWithProximityUUID:sUUID1 identifier:@"Navigine1"];
  
  _region1.notifyOnEntry = YES;
  _region1.notifyEntryStateOnDisplay = true;
  _region1.notifyOnExit = YES;
  
  // launch app when display is turned on and inside region
  // region.notifyEntryStateOnDisplay = YES;
  
  if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]){
    if ([_locationManager1 respondsToSelector:@selector(requestAlwaysAuthorization)]){
      [_locationManager1 requestAlwaysAuthorization];
    }
    [_locationManager1 startMonitoringForRegion:_region1];
    [_locationManager1 startRangingBeaconsInRegion:_region1];
  }
  
  if([CLLocationManager locationServicesEnabled]){
    [_locationManager1 startUpdatingLocation];
  }
  
  [NSTimer scheduledTimerWithTimeInterval:1.0f
                                   target:self
                                 selector:@selector(ChangeContent:)
                                 userInfo:nil
                                  repeats:YES];
  [consoleText appendString:[NSString stringWithFormat:@"txPower = %zd advertisingInterval = %zd\n",[self.txPower intValue],[self.advertisingInterval intValue]]];
  self.txtConsole.text = consoleText;
  
  
}

- (void)ChangeContent:(NSTimer *)timer {
  NSString *done =[[NSString alloc] initWithFormat:@"%zd/%zd",[readyBeacons count],beaconsVisibleForPrepare];
  _prepared.text = done;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didChangeDevices:(NSSet *)devices {
  // Do something with devices.
  beaconsVisibleForPrepare = devices.count;
  if(btnStartPressed){
    [beaconManager stopFindingDevices];
    dispatch_async(dispatch_get_main_queue(), ^{
      [consoleText appendString:@"Starting settings...\n"];
    });
    self.txtConsole.text = consoleText;
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSArray *beaconsDev = [devices allObjects];
      for(id obj in beaconsDev){
        if(btnStartPressed == NO) return;
        beacon = (KTKBeaconDevice *)obj;
        if([readyBeacons indexOfObject:beacon] != NSNotFound) continue;

        NSLog(@"beacon name %@ id %@",beacon.name,beacon.uniqueID);
        dispatch_async(dispatch_get_main_queue(), ^{
          [consoleText appendFormat:@"Beacon name %@ id %@\n",beacon.name,beacon.uniqueID];
          self.txtConsole.text = consoleText;
        });
        
        if(beacon.locked == YES){
          dispatch_async(dispatch_get_main_queue(), ^{
            [consoleText appendFormat:@"ERROR: beacon %@ locked!\n",beacon.uniqueID];
            lockedBeacons ++;
            self.txtConsole.text = consoleText;
          });
          continue;
        }
        
        NSString *password = [[NSString alloc] init];
        NSString *masterPassword = [[NSString alloc] init];
        [client getPassword:&password andMasterPassword:&masterPassword forBeaconWithUniqueID:[obj uniqueID]];
        
        NSLog(@"password: %@",password);
        NSError *error = nil;
        
        KTKCharacteristicDescriptor *major;
        KTKCharacteristicDescriptor *minor;
        KTKCharacteristicDescriptor *name;
        KTKCharacteristicDescriptor *power;
        KTKCharacteristicDescriptor *interval;
        
        error = [beacon setPassword:password];
        if(error){
          dispatch_async(dispatch_get_main_queue(), ^{
            [consoleText appendFormat:@"Incorrect Password for beacon %@\n",beacon.uniqueID];
            beaconsWithIncorrectPassword ++;
            self.txtConsole.text = consoleText;
          });
          continue;
        }
        error = error ?: [beacon connect];
        if(error){
          dispatch_async(dispatch_get_main_queue(), ^{
            [consoleText appendFormat:@"ERROR: Can't connect to beacon %@\n",beacon.uniqueID];
            notConnectedBeacons ++;
            self.txtConsole.text = consoleText;
          });
          continue;
        }
        error = error ?: [beacon discover];
        if(error){
          dispatch_async(dispatch_get_main_queue(), ^{
            [consoleText appendFormat:@"ERROR: Can't discover beacon %@\n",beacon.uniqueID];
            notDiscoverededBeacons ++;
            self.txtConsole.text = consoleText;
          });
          continue;
        }
        error = error ?: [beacon authorize];
        if(error){
          dispatch_async(dispatch_get_main_queue(), ^{
            [consoleText appendFormat:@"ERROR: Can't authorize beacon %@\n",beacon.uniqueID];
            notAuthorisedBeacons ++;
            self.txtConsole.text = consoleText;
          });
          continue;
        }
        if(!error){
          major = [beacon characteristicDescriptorWithType:kKTKCharacteristicDescriptorTypeMajor];
          minor = [beacon characteristicDescriptorWithType:kKTKCharacteristicDescriptorTypeMinor];
          name = [beacon characteristicDescriptorWithType:kKTKCharacteristicDescriptorTypeModelName];
          power = [beacon characteristicDescriptorWithType:kKTKCharacteristicDescriptorTypeTxPowerLevel];
          interval = [beacon characteristicDescriptorWithType:kKTKCharacteristicDescriptorTypeAdvertisingInterval];
          
          error = [beacon readValueForCharacteristicWithDescriptor:major];
          if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
              [consoleText appendFormat:@"ERROR: Can't get major at beacon %@\n",beacon.uniqueID];
              beaconsWithIncorrectPassword ++;
              self.txtConsole.text = consoleText;
            });
            continue;
          }
          error = [beacon readValueForCharacteristicWithDescriptor:minor];
          if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
              [consoleText appendFormat:@"ERROR: Can't get minor at beacon %@\n",beacon.uniqueID];
              beaconsWithIncorrectMajorOrMinor ++;
              self.txtConsole.text = consoleText;
            });
            continue;
          }
          
          if (!error) {
            NSString *newPower = self.txPower;
            NSString *newInterval = self.advertisingInterval;
            
            NSString *majorValue = [beacon stringForCharacteristicWithDescriptor:major];
            NSString *minorValue = [beacon stringForCharacteristicWithDescriptor:minor];
            
            NSString *stringValue = [[NSString alloc] initWithFormat:@"K-%@-%@",majorValue,minorValue];
//            error = [beacon writeString:stringValue forCharacteristicWithDescriptor:name];
            error = [beacon writeString:newInterval forCharacteristicWithDescriptor:interval];
            error = [beacon writeString:newPower forCharacteristicWithDescriptor:power];
            doneBeacons++;
            dispatch_async(dispatch_get_main_queue(), ^{
              [consoleText appendFormat:@"Beacon %@ done!\n",beacon.uniqueID];
              [readyBeacons addObject:beacon];
              self.txtConsole.text = consoleText;
            });
          }
        }
        error = error ?: [beacon disconnect];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        [consoleText appendFormat:@"All visible beacons are prepared!\n---------------\nСonfigured beacons:%zd\nLocked beacons:%zd\nBeacons with incorrect password:%zd\nNot discovered beacons:%zd\nNot connected beacons:%zd\nNot authorised beacons:%zd\nBeacons with incorrect major or minor:%zd\n",readyBeacons.count,lockedBeacons,beaconsWithIncorrectPassword,notDiscoverededBeacons,notConnectedBeacons, notAuthorisedBeacons,beaconsWithIncorrectMajorOrMinor];
        self.txtConsole.text = consoleText;
        
      });
      btnStartPressed = NO;
      [beaconManager reloadDevices];
      [beaconManager startFindingDevices];
    });
    [self.startButton setTitle:@"START" forState:UIControlStateNormal];
  }
  else{
    [beaconManager reloadDevices];
  }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  NSString * state = nil;
  
  switch ([_centralManager state])
  {
    case CBCentralManagerStateUnsupported:
      state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
      [UIAlertView showWithTitle:@"Error" message:state cancelButtonTitle:@"OK"];
      break;
    case CBCentralManagerStateUnauthorized:
      state = @"The app is not authorized to use Bluetooth Low Energy.";
      [UIAlertView showWithTitle:@"Error" message:state cancelButtonTitle:@"OK"];
      break;
    case CBCentralManagerStatePoweredOff:
      state = @"Для работы навигации необходимо включить в настройках Bluetooth";
      [UIAlertView showWithTitle:@"Внимание" message:state cancelButtonTitle:@"OK"];
      break;
      
  }
  
  /*
   if (central.state != CBCentralManagerStatePoweredOn) {
   return;
   }
   
   if (central.state == CBCentralManagerStatePoweredOn) {
   [central scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
   
   NSLog(@"Scanning started");
   }*/
}


/*
 - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
 
 NSInteger index = [visibleBeacons indexOfObject:peripheral.name];
 
 if(index < 0 || index >= [visibleBeacons count]){
 [visibleBeacons addObject:peripheral.name];
 NSLog(@"visible beacons:%lu",(unsigned long)[visibleBeacons count]);
 }
 //[central connectPeripheral:peripheral options:nil];
 if([peripheral.name characterAtIndex:0] == 'K'){
 if([peripheral.name characterAtIndex:1] == '-'){
 int i;
 int major = 0;
 for(i = 2; [peripheral.name characterAtIndex:i] != '-'; i++){
 major *= 10;
 major += ([peripheral.name characterAtIndex:i] - 48);
 if (i >= peripheral.name.length) return;
 }
 int k = ++i;
 int minor = 0;
 for(i = k; i < peripheral.name.length; i++){
 minor *= 10;
 minor += ([peripheral.name characterAtIndex:i] - 48);
 if (i >= peripheral.name.length) return;
 }
 NSLog(@"%@",advertisementData);
 
 
 [_centralManager connectPeripheral:peripheral options:nil];
 
 NSString *beaconID = [NSString stringWithFormat:@"(%05d,%05d,%@)\0",major, minor, @"F7826DA6-4FA2-4E98-8024-BC5B71E0893E"];
 //NSLog(@"\n\n\n%@",beaconID);
 }
 else{
 NSLog(@"%@",peripheral.name);
 //text.text = peripheral.name;
 }
 }
 
 //NSLog(@"\n\n\n%@\n\n\n",peripheral.name);
 // тут приходят данные по одному маячку (ВАЖНО: может приходить не только маячек, т.к мы сканируем BT)
 // как мы видим, тут пожно получить RSSI, и в peripheral есть peripheral.identifier.UUIDString, а так же peripheral.name
 }
 */

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
  NSString *cnt = [[NSString alloc] initWithFormat:@"%zd",[beacons count]];
  _txtVisibleBLE.text = cnt;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void) cleanBeacons{
  lockedBeacons = 0;
  notAuthorisedBeacons = 0;
  beaconsWithIncorrectPassword = 0;
  notDiscoverededBeacons = 0;
  notConnectedBeacons = 0;
  beaconsWithIncorrectMajorOrMinor = 0;
}

- (IBAction)start:(id)sender {
  UIButton *button = (UIButton *)sender;
  if([button.titleLabel.text isEqualToString:@"START"]){
    [button setTitle:@"PAUSE" forState:UIControlStateNormal];
    [beaconManager startFindingDevices];
    [self cleanBeacons];
    btnStartPressed = YES;
  }
  if([button.titleLabel.text isEqualToString:@"PAUSE"]){
    [button setTitle:@"CONTINUE" forState:UIControlStateNormal];
    [beaconManager startFindingDevices];
    btnStartPressed = NO;
  }
  if([button.titleLabel.text isEqualToString:@"CONTINUE"]){
    [button setTitle:@"PAUSE" forState:UIControlStateNormal];
    btnStartPressed = YES;
  }
}

- (IBAction)backPressed:(id)sender {
  [consoleText setString:@""];
  [self cleanBeacons];
  [readyBeacons removeAllObjects];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
