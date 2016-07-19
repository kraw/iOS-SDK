//
//  MenuViewController.m
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController (){
  UIBarButtonItem *activityBarItem;
}
@property (nonatomic, assign) BOOL processing;
@property (nonatomic, strong) LoginHelper *userHashHelper;
@property (nonatomic, strong) NavigineManager *navigineManager;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = YES;
  
  self.title = @"WELCOME";
  
  CGRect frame = self.txtFieldUserHash.frame;
  frame.size.height = 44;
  [self addLeftButton];
  self.txtFieldUserHash.delegate = self;
  self.txtFieldUserHash.layer.cornerRadius = self.txtFieldUserHash.height/2.f;
  self.txtFieldUserHash.frame = frame;
  self.txtFieldUserHash.backgroundColor = kColorFromHex(0x44566B);
  self.txtFieldUserHash.keyboardAppearance = UIKeyboardAppearanceAlert;
  
  self.txtEmail.delegate = self;
  self.txtEmail.layer.cornerRadius = self.txtEmail.height/2.f;
//  self.txtEmail.frame = frame;
  self.txtEmail.backgroundColor = kColorFromHex(0x44566B);
  self.txtEmail.keyboardAppearance = UIKeyboardAppearanceAlert;
  
  self.txtPasswd.delegate = self;
  self.txtPasswd.layer.cornerRadius = self.txtPasswd.height/2.f;
//  self.txtPasswd.frame = frame;
  self.txtPasswd.backgroundColor = kColorFromHex(0x44566B);
  self.txtPasswd.keyboardAppearance = UIKeyboardAppearanceAlert;
  
  self.navigationItem.hidesBackButton = YES;
  [self addRefreshControl];
  
  self.btnDone.layer.cornerRadius = self.btnDone.height/2.f;
  self.btnDone.backgroundColor = kColorFromHex(0x4AADD4);
  
  self.btnCancel.layer.cornerRadius = self.btnCancel.height/2.f;
  self.btnCancel.backgroundColor = kColorFromHex(0xD36666);
  
  self.invalidUserHash.hidden = YES;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(dismissKeyboard:)];
  [self.view addGestureRecognizer:tap];
  
  self.userHashHelper = [LoginHelper sharedInstance];
  self.navigineManager = [NavigineManager sharedManager];

  if(self.userHashHelper.userHash != nil){
    if(!self.userHashHelper.loadedLocations.count)
      [self performSegueWithIdentifier:@"noMapSegue" sender:self];
    else{
      NSIndexPath *index = [NSIndexPath indexPathForItem:1 inSection:0];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
    }
  }
}

-(void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  if(!self.navigineManager.su)
    self.btnCancel.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated{
  self.processing = NO;
  self.userHashHelper.delegate = self;
  self.txtFieldUserHash.backgroundColor = kColorFromHex(0x44566B);
  self.invalidUserHash.hidden = YES;
  self.btnDone.alpha = 1.f;
  if(self.userHashHelper.userHash != nil){
    self.txtFieldUserHash.text = self.userHashHelper.userHash;
  }
  else{
    self.userHashHelper.userHash = self.txtFieldUserHash.text;
  }
  if(!self.userHashHelper.userHashValid){
    self.invalidUserHash.hidden = NO;
    self.txtFieldUserHash.backgroundColor = kColorFromHex(0x624453);
  }
  [super viewDidAppear:animated];
}

- (void)addLeftButton {
  UIImage *buttonImage = [UIImage imageNamed:@""];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
  
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard :(UITapGestureRecognizer *)gesture {
  [self.txtEmail resignFirstResponder];
  [self.txtPasswd resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
  if (textField == self.txtEmail && [self.txtEmail.text isEqual:@"e-mail"]){
    [textField setPlaceholder:@"e-mail"];
    self.txtEmail.text = @"";
  }
  if (textField == self.txtPasswd && [self.txtPasswd.text isEqual:@"password"]){
    [textField setSecureTextEntry:YES];
    [textField setPlaceholder:@"password"];
    self.txtPasswd.text = @"";
  }
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
  if (textField == self.txtEmail && [self.txtEmail.text isEqual:@""]){
    self.txtEmail.text = @"e-mail";
  }
  if (textField == self.txtPasswd && [self.txtPasswd.text isEqual:@""]){
    [textField setSecureTextEntry:NO];
    self.txtPasswd.text = @"password";
  }
}

- (IBAction)publicUserPressed:(id)sender {
  if(self.processing == NO){
    [self.navigineManager changeBaseServerTo:@"https://api.navigine.com"];
    self.userHashHelper.userHash = @"0000-0000-0000-0000";
    self.btnDone.alpha = 0.7f;
    self.processing = YES;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:activityBarItem,nil] animated:NO];
    [self.userHashHelper startDownloadProcess:@"" :NO];
  }
}

- (IBAction)btnCancelPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) successfullDownloadingLocationList{
  [self.navigationItem setRightBarButtonItems:nil animated:NO];
  self.btnDone.alpha = 1.f;
  self.processing = NO;
  if(!self.userHashHelper.loadedLocations.count)
    [self performSegueWithIdentifier:@"noMapSegue" sender:self];
  else{
    NSIndexPath *index = [NSIndexPath indexPathForItem:1 inSection:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
  }
}

- (void) changeDownloadingLocationListValue:(NSInteger)value{
  
}

- (void) errorWhileDownloadingLocationList:(LoadingError)error{
  [self.navigationItem setRightBarButtonItems:nil animated:NO];
  NSString *errorString = @"    Internal error. Please contact technical support.";
  if(error == LoadingErrorInternetConnection){
    errorString = @"    Cannot connect to server. Check your internet connection.";
  }
  else if (error == LoadingErrorInvalidCredentials){
    errorString = @"    Cannot connect to server. Invalid e-mail or password.";
  }
  [self showStatusBarMessage:errorString
                   withColor:kColorFromHex(0xD36666)
                   hideAfter:5];
  [self viewDidAppear:NO];
}


- (void)addRefreshControl{
  UIActivityIndicatorView *refreshControl = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:refreshControl];
  [refreshControl startAnimating];
}

- (IBAction)btnDonePressed:(id)sender {
  if(self.processing == NO){
    [self.txtFieldUserHash resignFirstResponder];
    if([self.txtEmail.text isEqual:@""] || [self.txtPasswd.text isEqual:@""] || [self.txtEmail.text isEqual:@"e-mail"]){
      self.userHashHelper.userHashValid = NO;
      [self viewDidAppear:NO];
      return;
    }
    self.userHashHelper.email = self.txtEmail.text;
    self.userHashHelper.passwd = self.txtPasswd.text;
    self.userHashHelper.userHash = self.txtFieldUserHash.text;
    self.btnDone.alpha = 0.7f;
    self.processing = YES;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:activityBarItem,nil] animated:NO];
    [self.userHashHelper startDownloadProcess:@"" :NO];
  }
}

-(void)showStatusBarMessage:(NSString *)message withColor:(UIColor *)color hideAfter:(NSTimeInterval)delay{
  __block UIWindow *statusWindow = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
  statusWindow.windowLevel = UIWindowLevelStatusBar + 1;
  UILabel *label = [[UILabel alloc] initWithFrame:statusWindow.bounds];
  label.textAlignment = NSTextAlignmentLeft;
  label.backgroundColor = color;
  label.textColor = kColorFromHex(0xF9F9F9);
  label.font  = [UIFont fontWithName:@"Circe-Bold" size:11.0f];
  label.text = message;
  [statusWindow addSubview:label];
  [statusWindow makeKeyAndVisible];
  label.bottom = statusWindow.top;
  [UIView animateWithDuration:0.7 animations:^{
    label.bottom = statusWindow.bottom;
  }completion:^(BOOL finished){
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [UIView animateWithDuration:0.5 animations:^{
        label.bottom = statusWindow.top;
      }completion:^(BOOL finished){
        statusWindow = nil;
        [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
      }];
    });
  }];
}


@end
