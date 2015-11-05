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
  
  self.title = @"SETTINGS";
  self.navigineManager = [NavigineManager sharedManager];
  self.pushSwitcher.onTintColor = kColorFromHex(0x4AADD4);
  self.pushSwitcher.tintColor = kColorFromHex(0xBDBDBD);
  [self addLeftButton];
  
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
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft){
    [self.slidingPanelController closePanel];
  }
  else{
    [self.slidingPanelController openLeftPanel];
  }
}

- (IBAction)pushSwitcherPressed:(id)sender {
  [self.navigineManager changePushNotificationAvialiability];
}

- (IBAction)usingDemoPressed:(id)sender {
//  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://docs.navigine.com/ud_ios_demo.html"]];
}
@end
