//
//  ConsoleView.h
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineManager.h"


@interface SettingsViewController: UIViewController <UITextFieldDelegate, UIScrollViewDelegate>{
}

@property (weak, nonatomic) IBOutlet UITextField *txtScanTimeOut;

@property (weak, nonatomic) IBOutlet UITextField *txtNavigationFrequency;
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UISwitch *pushSwitcher;
@property (weak, nonatomic) IBOutlet UISwitch *calibrateViewSwitcher;

- (IBAction)pushSwitcherPressed:(id)sender;

- (IBAction)usingDemoPressed:(id)sender;
@end