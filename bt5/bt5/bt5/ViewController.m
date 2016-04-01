//
//  ViewController.m
//  bt5
//
//  Created by Администратор on 07.10.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "ViewController.h"
#import "MainViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
  tapPress.delaysTouchesBegan   = NO;
  [self.view addGestureRecognizer:tapPress];
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
  
  NSString *currentLevelKey = @"userLogin";
  
  if ([preferences objectForKey:currentLevelKey]){
    //  Get current level
    self.txtUserLogin.text = [preferences objectForKey:currentLevelKey];
  }
  // Do any additional setup after loading the view, typically from a nib.
  return;
}

- (IBAction)singIn:(id)sender {
  
}

- (void)tapPress:(UITapGestureRecognizer *)gesture {
  [self.txtAdvertisingInterval resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  
  if([segue.identifier isEqualToString:@"logIn"]) {
    //NSLog(@"pop %@",_action.title);
    MainViewController * pop = [segue destinationViewController];
    pop.txPower = self.txtTxPower.text;
    pop.advertisingInterval = self.txtAdvertisingInterval.text;
    pop.login = _txtUserLogin.text;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    NSString *currentLevelKey = @"userLogin";
    [preferences setValue:_txtUserLogin.text forKey:currentLevelKey];
    
    //  Save to disk
    const BOOL didSave = [preferences synchronize];
    
    if (!didSave){
      NSLog(@"ERROR with saving User Hash");
    }
  }
}
@end
