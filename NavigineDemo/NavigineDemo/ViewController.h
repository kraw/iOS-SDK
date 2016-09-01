//
//  ViewController.h
//  NavigineDemo
//
//  Created by Администратор on 29/08/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineSDK.h"

@interface ViewController : UIViewController <NavigineCoreDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *sv;

@property (nonatomic, strong) UIImageView *current;
@end

