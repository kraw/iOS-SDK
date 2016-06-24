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

// If debug mode enabled
@property (strong, nonatomic) UISwitch *mainArrowSwitcher;
@property (strong, nonatomic) UILabel *mainArrowTitle;

@property (strong, nonatomic) UISwitch *secondArrowSwitcher;
@property (strong, nonatomic) UILabel *secondArrowTitle;

@property (strong, nonatomic) UISwitch *stepCounterSwitcher;
@property (strong, nonatomic) UILabel *stepCounterTitle;

@property (strong, nonatomic) UIButton *reinitializeClientButton;

@property (strong, nonatomic) UISwitch *regularScanSwitcher;
@property (strong, nonatomic) UILabel *regularScanTitle;

@property (strong, nonatomic) UISwitch *fastScanSwitcher;
@property (strong, nonatomic) UILabel *fastScanTitle;

- (IBAction) pushSwitcherPressed:(id)sender;
- (IBAction) usingDemoPressed:(id)sender;
- (IBAction) shouldDisplayCalibration:(id)sender;

@end