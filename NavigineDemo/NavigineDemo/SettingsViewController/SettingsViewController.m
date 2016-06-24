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
  _pushSwitcher.on = _navigineManager.pushEnable;
  
  _calibrateViewSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _calibrateViewSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  
  // Main arrow
  _mainArrowSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(244, 435, 49, 31)];
  _mainArrowSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _mainArrowSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  _mainArrowSwitcher.hidden = !_navigineManager.debugModeEnable;
  _mainArrowSwitcher.on = !_navigineManager.mainArrowHidden;
  [_mainArrowSwitcher addTarget:self
                         action:@selector(mainArrowSwitcherPressed:)
               forControlEvents:UIControlEventValueChanged];
  [_sv addSubview:_mainArrowSwitcher];
  
  _mainArrowTitle = [[UILabel alloc] init];
  _mainArrowTitle.text = @"Main arrow";
  _mainArrowTitle.textColor = kColorFromHex(0x162D47);
  _mainArrowTitle.font = [UIFont fontWithName:@"Circe-Bold" size:16.f];
  [_mainArrowTitle sizeToFit];
  _mainArrowTitle.origin = CGPointMake(20, 441);
  _mainArrowTitle.hidden = !_navigineManager.debugModeEnable;
  [_sv addSubview:_mainArrowTitle];
  
  // Second arrow
  _secondArrowSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(244, 475, 49, 31)];
  _secondArrowSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _secondArrowSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  _secondArrowSwitcher.hidden = !_navigineManager.debugModeEnable;
  _secondArrowSwitcher.on = !_navigineManager.secondArrowHidden;
  [_secondArrowSwitcher addTarget:self
                           action:@selector(secondArrowSwitcherPressed:)
                 forControlEvents:UIControlEventValueChanged];
  [_sv addSubview:_secondArrowSwitcher];
  
  _secondArrowTitle = [[UILabel alloc] init];
  _secondArrowTitle.text = @"Second arrow";
  _secondArrowTitle.textColor = kColorFromHex(0x162D47);
  _secondArrowTitle.font = [UIFont fontWithName:@"Circe-Bold" size:16.f];
  [_secondArrowTitle sizeToFit];
  _secondArrowTitle.origin = CGPointMake(20, 481);
  _secondArrowTitle.hidden = !_navigineManager.debugModeEnable;
  [_sv addSubview:_secondArrowTitle];
  
  // Step counter
  _stepCounterSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(244, 515, 49, 31)];
  _stepCounterSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _stepCounterSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  _stepCounterSwitcher.hidden = !_navigineManager.debugModeEnable;
  _stepCounterSwitcher.on = !_navigineManager.stepCounterHidden;
  [_stepCounterSwitcher addTarget:self
                           action:@selector(stepCounterSwitcherPressed:)
                 forControlEvents:UIControlEventValueChanged];
  [_sv addSubview:_stepCounterSwitcher];
  
  _stepCounterTitle = [[UILabel alloc] init];
  _stepCounterTitle.text = @"Step counter";
  _stepCounterTitle.textColor = kColorFromHex(0x162D47);
  _stepCounterTitle.font = [UIFont fontWithName:@"Circe-Bold" size:16.f];
  [_stepCounterTitle sizeToFit];
  _stepCounterTitle.origin = CGPointMake(20, 521);
  _stepCounterTitle.hidden = !_navigineManager.debugModeEnable;
  [_sv addSubview:_stepCounterTitle];
  
  // Reinitialize client
  _reinitializeClientButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_reinitializeClientButton setTitle:@"Reinitialize client" forState:UIControlStateNormal];
  [_reinitializeClientButton setTitleColor:kColorFromHex(0x162D47) forState:UIControlStateNormal];
  [_reinitializeClientButton setTitleColor:kColorFromHex(0xFAFAFA) forState:UIControlStateHighlighted];
  _reinitializeClientButton.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  [_reinitializeClientButton sizeToFit];
  _reinitializeClientButton.origin = CGPointMake(20, 556);
  _reinitializeClientButton.hidden = !_navigineManager.debugModeEnable;
  [_reinitializeClientButton addTarget:self
                                action:@selector(reinitializeClientButtonPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
  [_sv addSubview:_reinitializeClientButton];
  
  // Regular scan
  _regularScanSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(244, 595, 49, 31)];
  _regularScanSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _regularScanSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  _regularScanSwitcher.hidden = !_navigineManager.debugModeEnable;
  _regularScanSwitcher.on = YES;
  [_regularScanSwitcher addTarget:self
                           action:@selector(regularScanSwitcherPressed:)
                 forControlEvents:UIControlEventValueChanged];
  [_sv addSubview:_regularScanSwitcher];
  
  _regularScanTitle = [[UILabel alloc] init];
  _regularScanTitle.text = @"Regular scan enabled";
  _regularScanTitle.textColor = kColorFromHex(0x162D47);
  _regularScanTitle.font = [UIFont fontWithName:@"Circe-Bold" size:16.f];
  [_regularScanTitle sizeToFit];
  _regularScanTitle.origin = CGPointMake(20, 601);
  _regularScanTitle.hidden = !_navigineManager.debugModeEnable;
  [_sv addSubview:_regularScanTitle];
  
  // Fast scan
  _fastScanSwitcher = [[UISwitch alloc] initWithFrame:CGRectMake(244, 635, 49, 31)];
  _fastScanSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  _fastScanSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  _fastScanSwitcher.hidden = !_navigineManager.debugModeEnable;
  _fastScanSwitcher.on = NO;
  [_fastScanSwitcher addTarget:self
                           action:@selector(fastScanSwitcherPressed:)
              forControlEvents:UIControlEventValueChanged];
  [_sv addSubview:_fastScanSwitcher];
  
  _fastScanTitle = [[UILabel alloc] init];
  _fastScanTitle.text = @"Fast scan enabled";
  _fastScanTitle.textColor = kColorFromHex(0x162D47);
  _fastScanTitle.font = [UIFont fontWithName:@"Circe-Bold" size:16.f];
  [_fastScanTitle sizeToFit];
  _fastScanTitle.origin = CGPointMake(20, 641);
  _fastScanTitle.hidden = !_navigineManager.debugModeEnable;
  [_sv addSubview:_fastScanTitle];
  
  _sv.contentSize = self.view.size;
  _sv.backgroundColor = kColorFromHex(0xEAEAEA);
  _txtNavigationFrequency.delegate = self;
  _txtScanTimeOut.delegate = self;
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(dismissKeyboard:)];
  [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  
  if(_navigineManager.debugModeEnable){
    _mainArrowSwitcher.hidden = NO;
    _mainArrowTitle.hidden = NO;
    
    _secondArrowSwitcher.hidden = NO;
    _secondArrowTitle.hidden = NO;
    
    _stepCounterSwitcher.hidden = NO;
    _stepCounterTitle.hidden = NO;
    
    _reinitializeClientButton.hidden = NO;
    
    _regularScanSwitcher.hidden = NO;
    _regularScanTitle.hidden = NO;
    
    _fastScanSwitcher.hidden = NO;
    _fastScanTitle.hidden = NO;
    
    _sv.contentSize = CGSizeMake(self.view.width, 690);
  }
  else{
    _mainArrowSwitcher.hidden = YES;
    _mainArrowTitle.hidden = YES;
    
    _secondArrowSwitcher.hidden = YES;
    _secondArrowTitle.hidden = YES;
    
    _stepCounterSwitcher.hidden = YES;
    _stepCounterTitle.hidden = YES;
    
    _reinitializeClientButton.hidden = YES;
    
    _regularScanSwitcher.hidden = YES;
    _regularScanTitle.hidden = YES;
    
    _fastScanSwitcher.hidden = YES;
    _fastScanTitle.hidden = YES;
    
    _sv.contentSize = self.view.size;
  }
}

- (void) viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [_navigineManager saveSettings];
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

- (IBAction)shouldDisplayCalibration:(id)sender {
  [_navigineManager shouldDisplayCalibration:_calibrateViewSwitcher.on];
  counter++;
  if (counter == 4){
    _navigineManager.debugModeEnable = _navigineManager.debugModeEnable ? NO : YES;
    if(_navigineManager.debugModeEnable){
      _mainArrowSwitcher.hidden = NO;
      _mainArrowTitle.hidden = NO;
      
      _secondArrowSwitcher.hidden = NO;
      _secondArrowTitle.hidden = NO;
      
      _stepCounterSwitcher.hidden = NO;
      _stepCounterTitle.hidden = NO;
      
      _reinitializeClientButton.hidden = NO;
      
      _regularScanSwitcher.hidden = NO;
      _regularScanTitle.hidden = NO;
      
      _fastScanSwitcher.hidden = NO;
      _fastScanTitle.hidden = NO;
      
      _sv.contentSize = CGSizeMake(self.view.width, 690);
    }
    else{
      _mainArrowSwitcher.hidden = YES;
      _mainArrowTitle.hidden = YES;
      
      _secondArrowSwitcher.hidden = YES;
      _secondArrowTitle.hidden = YES;
      
      _stepCounterSwitcher.hidden = YES;
      _stepCounterTitle.hidden = YES;
      
      _reinitializeClientButton.hidden = YES;
      
      _regularScanSwitcher.hidden = YES;
      _regularScanTitle.hidden = YES;
      
      _fastScanSwitcher.hidden = YES;
      _fastScanTitle.hidden = YES;
      
      _sv.contentSize = self.view.size;
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

- (void) mainArrowSwitcherPressed:(id)sender{
  _navigineManager.mainArrowHidden = !_mainArrowSwitcher.on;
}

- (void) secondArrowSwitcherPressed:(id)sender{
  _navigineManager.secondArrowHidden = !_secondArrowSwitcher.on;
}

- (void) stepCounterSwitcherPressed:(id)sender{
  _navigineManager.stepCounterHidden = !_stepCounterSwitcher.on;
}

- (void) reinitializeClientButtonPressed:(id)dender{
  NSError *error = nil;
  NSString *locationName = _navigineManager.location.name;
  [_navigineManager stopNavigine];
  [_navigineManager loadArchive:locationName error:&error];
  if (error){
    [UIAlertView showWithTitle:[NSString stringWithFormat:@"Invalid archive: %@.zip",locationName] message:nil cancelButtonTitle:@"OK"];
  }
  else{
    [_navigineManager startNavigine];
  }
}

- (void)regularScanSwitcherPressed:(id)sender {
  [_navigineManager regularScanEnabled:_regularScanSwitcher.on];
}

- (void)fastScanSwitcherPressed:(id)sender {
  [_navigineManager fastScanEnabled:_fastScanSwitcher.on];
}

- (IBAction)pushSwitcherPressed:(id)sender {
  _navigineManager.pushEnable = _pushSwitcher.on;
}

- (IBAction)usingDemoPressed:(id)sender {
}
@end
