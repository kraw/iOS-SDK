//
//  AppDelegate.m
//  NavigineDemo
//
//  Created by Администратор on 29/08/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigineSDK.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NavigineCore defaultCore] downloadContent:@"628B-9792-0789-C136"
                                       location:@"Navigine_Proletarsakya"
                                    forceReload:NO
                                   processBlock:^(NSInteger loadProcess) {
                                       NSLog(@"%zd",loadProcess);
                                   } successBlock:^{
                                       [[NavigineCore defaultCore] startNavigine];
                                       [[NavigineCore defaultCore] startRangePushes];
                                       [[NavigineCore defaultCore] startRangeVenues];
                                       NSData *imageData = [[NavigineCore defaultCore] dataForPNGImageAtIndex:0 error:nil];
                                       UIImage *image = [UIImage imageWithData:imageData];
                                       
                                       ViewController *vc = (ViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
                                       float scale = 1.f;
                                       if (image.size.width / image.size.height >
                                           vc.view.frame.size.width / vc.view.frame.size.height){
                                           scale = vc.view.frame.size.height / image.size.height;
                                       }
                                       else{
                                           scale = vc.view.frame.size.width / image.size.width;
                                       }
                                       vc.imageView.frame = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
                                       vc.imageView.image = image;
                                       vc.sv.contentSize = vc.imageView.frame.size;
                                   } failBlock:^(NSError *error) {
                                       NSLog(@"Error:%@",error);
                                   }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
