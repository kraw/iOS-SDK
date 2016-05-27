//
//  MenuViewController.h
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineManager.h"

@interface MenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *menuArray;

@property (weak, nonatomic) IBOutlet UITableView *tv;

@end