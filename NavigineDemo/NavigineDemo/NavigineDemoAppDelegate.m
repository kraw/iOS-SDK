//
//  NavigineDemoAppDelegate.m
//  NavigineDemo
//
//  Created by Administrator on 7/14/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//
#include "NavigineDemoAppDelegate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MapViewController.h"
#import "SlideViewController.h"
#import "CustomTabBarViewController.h"
#import "MenuViewController.h"

@implementation NavigineDemoAppDelegate

+ (void)initialize
{
  if ([self class] == [NavigineDemoAppDelegate class]) {
    /* Replace API_KEY with your unique API key. Please, read official documentation how to obtain one:
     https://tech.yandex.com/metrica-mobile-sdk/doc/mobile-sdk-dg/tasks/ios-quickstart-docpage/
     */
    [YMMYandexMetrica activateWithApiKey:@"7f985a6f-4158-4633-987d-7bb0c8f2b82b"];
    //manual log setting for whole library
    [YMMYandexMetrica setLoggingEnabled:YES];
  }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  client = [RavenClient clientWithDSN:@"http://647192ffc27b4613a78f2dca2d77044d:9b5526d57b9849538509aa5104413675@sentry.navigine.com/9"];
  [RavenClient setSharedClient:client];
  // Bind default exception handler
  [client setupExceptionHandler];
  
  _navigineManager = [NavigineManager sharedManager];
  [_navigineManager loadSettings];
  
  NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
  if(url){
    NSError *error = nil;
    
    NSString *query = [url query];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in components) {
      NSArray *elts = [param componentsSeparatedByString:@"="];
      if([elts count] < 2) continue;
      [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    [_navigineManager stopNavigine];
    NSString *location = [params objectForKey:@"location"];
    NSString *userHash = [params objectForKey:@"userHash"];
    NSString *sublocationId = [params objectForKey:@"sublocationId"];
    NSString *kx = [params objectForKey:@"kx"];
    NSString *ky = [params objectForKey:@"ky"];
    int loaderId = [_navigineManager startLocationLoader:userHash :location :NO];
    int loadProcess = 0;
    while (loadProcess < 100) {
      loadProcess = [_navigineManager checkLocationLoader:loaderId];
      if(loadProcess > 100 || loadProcess < 0){
        [_navigineManager stopLocationLoader:loaderId];
        break;
      }
      
      if(loadProcess == 100){
        [_navigineManager stopLocationLoader: loaderId];
        [_navigineManager loadArchive:location error:&error];
        if(!error){
          [_navigineManager startNavigine];
          _navigineManager.superVenue = [Venue new];
          _navigineManager.superVenue.locationId = _navigineManager.location.id;
          _navigineManager.superVenue.sublocationId = [sublocationId integerValue];
          _navigineManager.superVenue.name = @"Переговорка";
          _navigineManager.superVenue.kx = [NSNumber numberWithDouble:[kx doubleValue]];
          _navigineManager.superVenue.ky = [NSNumber numberWithDouble:[ky doubleValue]];
          _navigineManager.loadFromURL = YES;
        }
      }
    }
  }

  [Fabric with:@[CrashlyticsKit]];
  
  NSDictionary *navbarTitleTextAttributes  = [NSDictionary dictionaryWithObjectsAndKeys:
                                              kColorFromHex(0xF9F9F9),NSForegroundColorAttributeName,
                                              [UIFont fontWithName:@"Circe-Bold" size:16.0f], NSFontAttributeName, nil];
  
  [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
  
  
  self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
  [application setStatusBarStyle:UIStatusBarStyleLightContent];
  
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
  NSError *error = nil;
  if(!_navigineManager.loadFromURL){
    NSString *query = [url query];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in components) {
      NSArray *elts = [param componentsSeparatedByString:@"="];
      if([elts count] < 2) continue;
      [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    _navigineManager = [NavigineManager sharedManager];
    [_navigineManager stopNavigine];
    NSString *location = [params objectForKey:@"location"];
    NSString *userHash = [params objectForKey:@"userHash"];
    NSString *sublocationId = [params objectForKey:@"sublocationId"];
    NSString *kx = [params objectForKey:@"kx"];
    NSString *ky = [params objectForKey:@"ky"];
    int loaderId = [_navigineManager startLocationLoader:userHash :location :NO];
    int loadProcess = 0;
    while (loadProcess < 100) {
      loadProcess = [_navigineManager checkLocationLoader:loaderId];
      if(loadProcess > 100 || loadProcess < 0){
        [_navigineManager stopLocationLoader:loaderId];
        break;
      }
      
      if(loadProcess == 100){
        [_navigineManager stopLocationLoader: loaderId];
        [_navigineManager loadArchive:location error:&error];
        if(!error){
          [_navigineManager startNavigine];
          [_navigineManager startRangePushes];
          [_navigineManager startRangeVenues];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"setLocation" object:nil userInfo:@{@"locationName":location}];
          _navigineManager.superVenue = [Venue new];
          _navigineManager.superVenue.locationId = _navigineManager.location.id;
          _navigineManager.superVenue.sublocationId = [sublocationId integerValue];
          _navigineManager.superVenue.name = @"Переговорка";
          _navigineManager.superVenue.kx = [NSNumber numberWithDouble:[kx doubleValue]];
          _navigineManager.superVenue.ky = [NSNumber numberWithDouble:[ky doubleValue]];
          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
          MenuViewController *menu = (MenuViewController *)[storyboard instantiateViewControllerWithIdentifier:@"menu"];
          [menu.slidingPanelController closePanel];
          [self.window makeKeyAndVisible];
          NSIndexPath *index = [NSIndexPath indexPathForItem:2 inSection:0];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
        }
        break;
      }
    }

  }
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  [_navigineManager saveSettings];
}

//-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
//
//}

@end
