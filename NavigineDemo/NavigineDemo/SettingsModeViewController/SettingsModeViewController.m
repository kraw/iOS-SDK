//
//  ConsoleView.m
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "SettingsModeViewController.h"


@interface SettingsModeViewController (){
}
@end

@implementation SettingsModeViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = kWhiteColor;
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  
  [self addLeftButton];
  self.title = @"SETTINGS MODE";
  
  [self setupTabBar];
  
}

- (IBAction)FrequencyChanged:(id)sender{
}

- (void) setupTabBar{
  UIEdgeInsets edge;
  edge.top = 7;
  edge.left = 0;
  edge.bottom = -7;
  edge.right = 0;
  
  [[self tabBar] setTintColor:kColorFromHex(0x4AADD4)];
  
  self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
  UITabBarItem *debugTabBarItem = [[self.tabBar items] objectAtIndex:0];
  [debugTabBarItem setImage:[UIImage imageNamed:@"btnDebugMode"]];
  [debugTabBarItem setTitle:nil];
  debugTabBarItem.imageInsets = edge;
  
  UITabBarItem *logTabBarItem = [[self.tabBar items] objectAtIndex:1];
  [logTabBarItem setImage:[UIImage imageNamed:@"btnLogMode"]];
  [logTabBarItem setTitle:nil];
  logTabBarItem.imageInsets = edge;
  
  UITabBarItem *consoleTabBarItem = [[self.tabBar items] objectAtIndex:2];
  [consoleTabBarItem setImage:[UIImage imageNamed:@"btnConsole"]];
  [consoleTabBarItem setTitle:nil];
  consoleTabBarItem.imageInsets = edge;
  
  self.tabBar.itemSpacing = 40.f;
  self.tabBar.itemWidth = 52.f;
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

- (void)viewDidUnload{
  [super viewDidUnload];
  
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}


- (IBAction)menuPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
    [self.slidingPanelController closePanel];
  }
  else {
    [self.slidingPanelController openLeftPanel];
  }
}

@end
