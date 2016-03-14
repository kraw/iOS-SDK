//
//  ConsoleView.m
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController (){

}
@property (nonatomic, strong) NavigineManager *navigineManager;
@end

@implementation SettingsViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  
//  self.title = @"SETTINGS";
  self.navigineManager = [NavigineManager sharedManager];
  self.pushSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  self.pushSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  self.calibrateViewSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  self.calibrateViewSwitcher.tintColor = kColorFromHex(0xBDBDBD);
//  [self addLeftButton];
  
//  self.sv.contentSize = CGSizeMake(320, 457);
  self.sv.contentSize = CGSizeMake(320, 471);
  self.sv.backgroundColor = kColorFromHex(0xEAEAEA);
  self.txtNavigationFrequency.delegate = self;
  self.txtScanTimeOut.delegate = self;
  
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
  [self.txtNavigationFrequency resignFirstResponder];
  [self.txtScanTimeOut resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
}

- (IBAction)shouldDisplayCalibration:(id)sender {
  UISwitch *sw = (UISwitch *)sender;
  [self.navigineManager shouldDisplayCalibration:sw.on];
}


- (IBAction)pushSwitcherPressed:(id)sender {
  [self.navigineManager changePushNotificationAvialiability];
}

- (IBAction)usingDemoPressed:(id)sender {
}
@end
