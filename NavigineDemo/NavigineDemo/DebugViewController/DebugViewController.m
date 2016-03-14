//
//  ConsoleView.m
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController (){
  NSTimer *refreshTimer;
  NSString *lastLogFile;
  __block UIWindow *statusWindow;
  UILabel *label;
}
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NavigineManager *navigineManager;
@property (nonatomic, strong) LoaderHelper *loaderHelper;
@end

@implementation DebugViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  refreshTimer = nil;
  lastLogFile = @"";
  
  self.navigationController.navigationBar.translucent = NO;
  self.sv.contentSize = CGSizeMake(320, 471);
  self.swith.onTintColor = kColorFromHex(0x4AADD4);
  self.swith.tintColor = kColorFromHex(0xBDBDBD);
  self.ipAddress.delegate = self;
  self.ipAddress.keyboardAppearance = UIKeyboardAppearanceAlert;
  self.ipAddress.returnKeyType = UIReturnKeyDone;
  self.frequency.delegate = self;
  self.frequency.keyboardAppearance = UIKeyboardAppearanceAlert;
  self.frequency.returnKeyType = UIReturnKeyDone;
  
  self.navigineManager = [NavigineManager sharedManager];
  self.loaderHelper = [LoaderHelper sharedInstance];
  self.cleanFrequency.hidden = YES;
  self.cleanIpAddress.hidden = YES;
  
  statusWindow = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
  statusWindow.windowLevel = UIWindowLevelStatusBar + 1;
  label = [[UILabel alloc] initWithFrame:statusWindow.bounds];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(dismissKeyboard:)];
  [self.view addGestureRecognizer:tap];
  
  [self.frequency addTarget:self
                action:@selector(textFieldDidChange:)
      forControlEvents:UIControlEventEditingChanged];
  
  [self.ipAddress addTarget:self
                action:@selector(textFieldDidChange:)
      forControlEvents:UIControlEventEditingChanged];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
  self.sv.origin = CGPointZero;
}

- (void)viewDidUnload{
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [self getServerFromFile];
  self.ipAddress.text = self.server;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [self dismissKeyboard: nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void)dismissKeyboard :(UITapGestureRecognizer *)gesture {
  [self.frequency resignFirstResponder];
  [self.ipAddress resignFirstResponder];
  self.saveLogToFile.hidden = NO;
  self.deletePreviousLog.hidden = NO;
  self.line.hidden = NO;
}

- (IBAction)switchPressed:(id)sender {
  NSError *error = nil;
  if (self.swith.on){
    [self.navigineManager startMQueue:&error];
  }
  else
    [self.navigineManager stopMQueue];
  if(error)
    self.swith.on = NO;
}

- (IBAction)btnCleanIpAddress:(id)sender {
  self.ipAddress.text = @"";
  self.cleanIpAddress.hidden = YES;
}

- (IBAction)btnCleanFrequency:(id)sender {
  self.frequency.text = @"";
  self.cleanFrequency.hidden = YES;
}

- (IBAction)btnSaveLogToFile:(id)sender {
  UIButton *btn = (UIButton *)sender;
  if([self.saveLogToFile.titleLabel.text isEqualToString:@"Record log file"]){
    lastLogFile = [self.navigineManager startSaveLogToFile];
    [self.saveLogToFile setTitle:@"Stop record log file" forState:UIControlStateNormal];
    [self.saveLogToFile setTitle:@"Stop record log file" forState:UIControlStateHighlighted];

    if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
      [self.slidingPanelController closePanel];
    }
    else {
      [self showStatusBarMessage:@"        Recording log file" withColor:kColorFromHex(0x14263B)];
      [self.slidingPanelController openLeftPanelWithCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationModePressed"
                                                            object:nil
                                                          userInfo:nil];

      }];
    }
  }
  else{
    [self.navigineManager stopSaveLogToFile];
    [self.saveLogToFile setTitle:@"Record log file" forState:UIControlStateNormal];
    [self.saveLogToFile setTitle:@"Record log file" forState:UIControlStateHighlighted];
    [self hideStatusBar];
  }
}

- (IBAction)btnDeletePreviousLog:(id)sender {
  NSError *error = nil;
  BOOL ok = YES;
  if([[NSFileManager defaultManager] fileExistsAtPath:lastLogFile]){
    ok = [[NSFileManager defaultManager] removeItemAtPath:lastLogFile error:&error];
  }
  if(!ok)
    NSLog(@"Can't remove log file");
  if(error)
    NSLog(@"%@",[error localizedDescription]);
}

- (void)startDataSending{
  [self.navigineManager setServer:[self.ipAddress.text UTF8String] andPort:SERVER_DEFAULT_OUTPUT_PORT];
  [self.navigineManager setConnectionStatus:CONNECTION_STATUS_CONNECTED];
  [self.navigineManager launchNavigineSocketThreads :[self.ipAddress.text UTF8String]: SERVER_DEFAULT_OUTPUT_PORT];
}

- (void)stopDataSending{
  [self.navigineManager setConnectionStatus:CONNECTION_STATUS_DISCONNECTED];
  [refreshTimer invalidate];
  refreshTimer = nil;
}

- (void) startTimer{
  if (refreshTimer==nil) {
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:[self.frequency.text integerValue]
                                                    target:self
                                                  selector:@selector(timerTick:)
                                                  userInfo:nil
                                                   repeats:YES];
  }
}

- (void)timerTick: (NSTimer *)timer{
//  int iConnectionStatusWriteSocket = [self.navigineManager getConnectionStatusWriteSocket];
//  if (iConnectionStatusWriteSocket == CONNECTION_STATUS_DISCONNECTED)
////    self.connectionStatusLabel.text = @"Disconnected";
//  if (iConnectionStatusWriteSocket == CONNECTION_STATUS_CONNECTING)
////    self.connectionStatusLabel.text = @"Connecting..";
//  if (iConnectionStatusWriteSocket == CONNECTION_STATUS_CONNECTED)
////    self.connectionStatusLabel.text = @"Connected";
//  
//  int iConnectionStatusReadSocket = [self.navigineManager getConnectionStatusReadSocket];
//  
//  if (iConnectionStatusReadSocket == CONNECTION_STATUS_DISCONNECTED)
//    self.connectionStatusReadSocketLabel.text = @"Disconnected";
//  if (iConnectionStatusReadSocket == CONNECTION_STATUS_CONNECTING)
//    self.connectionStatusReadSocketLabel.text = @"Connecting..";
//  if (iConnectionStatusReadSocket == CONNECTION_STATUS_CONNECTED)
//    self.connectionStatusReadSocketLabel.text = @"Connected";
//  
  [self.navigineManager sendPacket];
  
}

- (void)textFieldDidChange:(UITextField *)textField{
  if(textField.text.length == 0){
    self.cleanFrequency.hidden = YES;
    self.cleanIpAddress.hidden = YES;
    return;
  }
  if(textField == self.ipAddress){
    self.cleanIpAddress.hidden = NO;
  }
  else{
    self.cleanFrequency.hidden = NO;
  }
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
  NSDictionary *userInfo = aNotification.userInfo;
  //
  // Get keyboard size.
  NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
  CGRect keyboardBeginFrame = [self.view convertRect:beginFrameValue.CGRectValue fromView:nil];
  
  NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
  CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
  //
  // Get keyboard animation.
  NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration = durationValue.doubleValue;
  
  NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
  UIViewAnimationCurve animationCurve = curveValue.intValue;
  //
  // Create animation.
  void (^animations)() = ^() {
    self.sv.origin = CGPointMake(0.f, -81.f);
  };
  //
  // Begin animation.
  [UIView animateWithDuration:animationDuration
                        delay:0.0
                      options:(animationCurve << 16)
                   animations:animations
                   completion:^(BOOL finished) {
                   }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification {
  NSDictionary *userInfo = aNotification.userInfo;
  //
  // Get keyboard size.
  NSValue *beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
  CGRect keyboardBeginFrame = [self.view convertRect:beginFrameValue.CGRectValue fromView:nil];
  
  NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
  CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
  //
  // Get keyboard animation.
  NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration = durationValue.doubleValue;
  
  NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
  UIViewAnimationCurve animationCurve = curveValue.intValue;
  //
  // Create animation.
  void (^animations)() = ^() {
    self.sv.origin = CGPointMake(0.f, 0.f);
  };
  //
  // Begin animation.
  [UIView animateWithDuration:animationDuration
                        delay:0.0
                      options:(animationCurve << 16)
                   animations:animations
                   completion:^(BOOL finished) {
                   }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
  self.saveLogToFile.hidden = YES;
  self.deletePreviousLog.hidden = YES;
  self.line.hidden = YES;
  
  textField.right = self.cleanIpAddress.left;
  if(textField.text.length == 0){
    self.cleanFrequency.hidden = YES;
    self.cleanIpAddress.hidden = YES;
    return YES;
  }
  if(textField == self.ipAddress){
    self.cleanIpAddress.hidden = NO;
  }
  else{
    self.cleanFrequency.hidden = NO;
  }
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
  textField.right = 296.f;
  if(textField == self.ipAddress){
    self.cleanIpAddress.hidden = YES;
  }
  else{
    self.cleanFrequency.hidden = YES;
  }
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  self.saveLogToFile.hidden = NO;
  self.deletePreviousLog.hidden = NO;
  self.line.hidden = NO;
  [textField resignFirstResponder];
  textField.right = 296.f;
  if(textField == self.ipAddress){
    self.cleanIpAddress.hidden = YES;
    if (![self.server isEqualToString:textField.text]){
      [UIAlertView showWithTitle:@"Are you really want to change server?"
                         message:@"You will be logged out"
               cancelButtonTitle:@"Cancel"
               otherButtonTitles:[NSArray arrayWithObject:@"Yes"]
               andTextFieldStyle:UIAlertViewStyleDefault
                andTextFieldText:nil
                        tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          switch (buttonIndex) {
                            case 0:
                              self.ipAddress.text = self.server;
                              break;
                            case 1:
                              self.server = textField.text;
                              [self saveSereverToFile];
                              [self.navigineManager changeBaseServerTo:textField.text];
                              [self.loaderHelper stopNavigine];
                              [self.loaderHelper deleteAllLocations];
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed"
                                                                                  object:nil
                                                                                userInfo:@{@"index": [NSIndexPath indexPathForItem:0 inSection:0]}];
                              break;
                            default:
                              break;
                          }
                        }];
    }
  }
  else{
    self.cleanFrequency.hidden = YES;
  }
  return YES;
}

- (void)showStatusBarMessage:(NSString *)message withColor:(UIColor *)color{
  label.textAlignment = NSTextAlignmentLeft;
  label.backgroundColor = color;
  label.textColor = kColorFromHex(0xF9F9F9);
  label.font  = [UIFont fontWithName:@"Circe-Bold" size:11.0f];
  label.text = message;
  
  UIImageView *redPoint = [[UIImageView alloc] initWithFrame:CGRectMake(6.f, 6.f, 8.f, 8.f)];
  redPoint.backgroundColor = kColorFromHex(0xD34242);
  redPoint.layer.cornerRadius = redPoint.height/2.f;
  [label addSubview:redPoint];
  [statusWindow addSubview:label];
  [statusWindow makeKeyAndVisible];
  label.bottom = statusWindow.top;
  [UIView animateWithDuration:0.7 animations:^{
    label.bottom = statusWindow.bottom;
  }completion:^(BOOL finished){
  }];
}

- (void) hideStatusBar{
  [UIView animateWithDuration:0.5 animations:^{
    label.bottom = statusWindow.top;
  }completion:^(BOOL finished){
    [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
  }];
}

- (void) getServerFromFile{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *currentLevelKey = @"server";
  if ([preferences objectForKey:currentLevelKey]){
    //  Get current level
    self.server = [preferences objectForKey:currentLevelKey];
  }
  else{
    self.server = @"https://api.navigine.com";
  }
  self.navigineManager.server = self.server;
}

- (void)saveSereverToFile{
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  NSString *currentLevelKey = @"server";
  [preferences setValue:self.server forKey:currentLevelKey];
  //  Save to disk
  BOOL didSave = [preferences synchronize];
  if (!didSave){
    DLog(@"ERROR with saving User Hash");
  }
}
@end
