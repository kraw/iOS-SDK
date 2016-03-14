//
//  UserHashViewController.h
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginHelper.h"
#import "NavigineManager.h"

@interface LoginViewController: UIViewController <UITextFieldDelegate, LoginHelperDelegate>{
}

@property (weak, nonatomic) IBOutlet UITextField *txtFieldUserHash;

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswd;

@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *invalidUserHash;


- (IBAction)btnCancelPressed:(id)sender;
- (IBAction)btnDonePressed:(id)sender;

@end
