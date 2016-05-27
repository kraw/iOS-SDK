//
//  ConsoleView.m
//  Navigine
//
//  Created by Pavel Tychinin on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController (){
  NSTimer *enableDebugModeTimer;
  NSInteger counter;
}
@property (nonatomic, strong) NavigineManager *navigineManager;
@end

@implementation SettingsViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  
  counter = 0;
  enableDebugModeTimer = nil;
  _navigineManager = [NavigineManager sharedManager];
  
  _pushSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _pushSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  
  _calibrateViewSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _calibrateViewSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  
  _fastScanSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _fastScanSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  
  _regularScanSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _regularScanSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  
  _sv.contentSize = self.view.frame.size;
  _sv.backgroundColor = kColorFromHex(0xEAEAEA);
  _txtNavigationFrequency.delegate = self;
  _txtScanTimeOut.delegate = self;
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(dismissKeyboard:)];
  [self.view addGestureRecognizer:tap];
}

- (void)viewDidUnload{
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  if(_navigineManager.debugModeEnable){
    _regularScanSwitcher.hidden = NO;
    _regularScanTitle.hidden = NO;
    
    _fastScanSwitcher.hidden = NO;
    _fastScanTitle.hidden = NO;
  }
  else{
    _regularScanSwitcher.hidden = YES;
    _regularScanTitle.hidden = YES;
    
    _fastScanSwitcher.hidden = YES;
    _fastScanTitle.hidden = YES;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [self dismissKeyboard:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}

- (void)dismissKeyboard :(UITapGestureRecognizer *)gesture {
  [_txtNavigationFrequency resignFirstResponder];
  [_txtScanTimeOut resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
}

- (IBAction)shouldDisplayCalibration:(id)sender {
  UISwitch *sw = (UISwitch *)sender;
  [_navigineManager shouldDisplayCalibration:sw.on];
  counter++;
  if (counter == 4){
    _navigineManager.debugModeEnable = _navigineManager.debugModeEnable ? NO : YES;
    if(_navigineManager.debugModeEnable){
      _regularScanSwitcher.hidden = NO;
      _regularScanTitle.hidden = NO;
      
      _fastScanSwitcher.hidden = NO;
      _fastScanTitle.hidden = NO;
    }
    else{
      _regularScanSwitcher.hidden = YES;
      _regularScanTitle.hidden = YES;
      
      _fastScanSwitcher.hidden = YES;
      _fastScanTitle.hidden = YES;
    }
    [self invalidate:enableDebugModeTimer];
  }
  if (!enableDebugModeTimer){
    enableDebugModeTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                             target:self
                                           selector:@selector(invalidate:)
                                           userInfo:nil
                                            repeats:NO];
  }
}





-(void)invalidate:(NSTimer *)timer{
  [enableDebugModeTimer invalidate];
  enableDebugModeTimer = nil;
  counter = 0;
}

- (IBAction)fastScanSwitcherPressed:(id)sender {
  [_navigineManager fastScanEnabled:_fastScanSwitcher.on];
}

- (IBAction)regularScanSwitcherPressed:(id)sender {
  [_navigineManager regularScanEnabled:_regularScanSwitcher.on];
}

- (IBAction)pushSwitcherPressed:(id)sender {
  [_navigineManager changePushNotificationAvialiability];
}

- (IBAction)usingDemoPressed:(id)sender {
}
@end
