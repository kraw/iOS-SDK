//
//  ConsoleView.h
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "NavigineManager.h"


@interface DebugViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>{
}

@property (weak, nonatomic) IBOutlet UISwitch *swith;
@property (weak, nonatomic) IBOutlet UILabel *connectToServer;
@property (weak, nonatomic) IBOutlet UITextField *ipAddress;
@property (weak, nonatomic) IBOutlet UIButton *cleanIpAddress;
@property (weak, nonatomic) IBOutlet UIButton *cleanFrequency;
@property (weak, nonatomic) IBOutlet UITextField *frequency;
@property (weak, nonatomic) IBOutlet UIButton *saveLogToFile;
@property (weak, nonatomic) IBOutlet UIButton *deletePreviousLog;
@property (weak, nonatomic) IBOutlet UIImageView *line;


@property (weak, nonatomic) IBOutlet UIScrollView *sv;
- (IBAction)switchPressed:(id)sender;
- (IBAction)btnCleanIpAddress:(id)sender;
- (IBAction)btnCleanFrequency:(id)sender;
- (IBAction)btnSaveLogToFile:(id)sender;
- (IBAction)btnDeletePreviousLog:(id)sender;

@end