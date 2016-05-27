//
//  ConsoleView.h
//  Navigine
//
//  Created by Pavel Tychinin on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineManager.h"

@interface SettingsViewController: UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtScanTimeOut;
@property (weak, nonatomic) IBOutlet UITextField *txtNavigationFrequency;
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UISwitch *pushSwitcher;
@property (weak, nonatomic) IBOutlet UISwitch *calibrateViewSwitcher;
@property (weak, nonatomic) IBOutlet UISwitch *regularScanSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *regularScanTitle;
@property (weak, nonatomic) IBOutlet UISwitch *fastScanSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *fastScanTitle;

- (IBAction) pushSwitcherPressed:(id)sender;
- (IBAction) usingDemoPressed:(id)sender;
- (IBAction) shouldDisplayCalibration:(id)sender;
- (IBAction) regularScanSwitcherPressed:(id)sender;
- (IBAction) fastScanSwitcherPressed:(id)sender;
@end