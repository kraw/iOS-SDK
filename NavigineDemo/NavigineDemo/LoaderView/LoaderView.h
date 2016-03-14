//
//  LoaderView.h
//  NavigineDemo
//
//  Created by Администратор on 13/01/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "NavigineManager.h"
#import "LocationTableViewCell.h"
#import "CustomTabBarViewController.h"
#import "MenuTableViewCell.h"
#import "Location.h"
#import "DetailLoaderView.h"
#import "LocationInfo.h"
#import "LoaderHelper.h"
#import "QRCodeViewController.h"
#import "SWTableViewCell.h"
//#import "NoLocationView.h"
#import "JGActionSheet.h"

@interface LoaderView : UITableViewController <UITextFieldDelegate, JGActionSheetDelegate, LoaderHelperDelegate,UIActionSheetDelegate,SWTableViewCellDelegate>{
}

- (void)setLocation :(LocationInfo *)locationForSet;
- (IBAction)btnMapInfo:(id)sender;
- (IBAction)btnDownloadMapPressed:(id)sender;

@end