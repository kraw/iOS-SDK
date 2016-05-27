//
//  NavigineDemoAppDelegate.h
//  NavigineDemo
//
//  Created by Administrator on 7/14/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineManager.h"
#import "RavenClient.h"

RavenClient *client;

@interface NavigineDemoAppDelegate : UIResponder <UIApplicationDelegate>{
}
@property (strong, nonatomic) UIWindow *window;
  @property (nonatomic, strong) NavigineManager *navigineManager;
@end

