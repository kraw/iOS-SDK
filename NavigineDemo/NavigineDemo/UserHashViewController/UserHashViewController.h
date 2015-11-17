//
//  UserHashViewController.h
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserHashHelper.h"

@interface UserHashViewController: UIViewController <UITextFieldDelegate, UserHashHelperDelegate>{
}

@property (weak, nonatomic) IBOutlet UITextField *txtFieldUserHash;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *invalidUserHash;
- (IBAction)btnCancelPressed:(id)sender;
- (IBAction)btnDonePressed:(id)sender;

@end
