//
//  CustomTabBarViewController.m
//  SVO
//
//  Created by Valentine on 03.07.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "NavigineManager.h"
#import "MapHelper.h"
#import "LoaderHelper.h"
#import "DebugHelper.h"
#import "PlayLogHelper.h"


@interface CustomTabBarViewController (){
  MapHelper       *mapHelper;
  NavigineManager *navigineManager;
  LoaderHelper    *loaderHelper;
  DebugHelper     *debugHelper;
  PlayLogHelper   *playLogHelper;
}

@end

@implementation CustomTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = kColorFromHex(0x162D47);
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(menuItemPressed:)
                                               name:@"menuItemPressed"
                                             object:nil];
  
  self.hidesBottomBarWhenPushed  = YES;
  self.tabBar.hidden             = YES;
  
  navigineManager = [NavigineManager sharedManager];
  mapHelper       = [MapHelper      sharedInstance];
  loaderHelper    = [LoaderHelper   sharedInstance];
  debugHelper     = [DebugHelper    sharedInstance];
  playLogHelper   = [PlayLogHelper  sharedInstance];
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)menuItemPressed:(NSNotification *)notification {
  
  NSDictionary *index = notification.userInfo;
  NSIndexPath *path = index[@"index"];

  if(!navigineManager.location){
    if (path.row == 2 || path.row == 3 || path.row == 4){
      path = [NSIndexPath indexPathForItem:6 inSection:0];
    }
  }
  [self setSelectedIndex:path.row];
  
//
  [self.slidingPanelController closePanel];
  
}

@end
