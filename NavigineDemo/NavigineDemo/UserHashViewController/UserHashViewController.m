//
//  MenuViewController.m
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "UserHashViewController.h"


@interface UserHashViewController (){
  UIBarButtonItem *activityBarItem;
}

@property (nonatomic, strong) UserHashHelper *userHashHelper;

@end

@implementation UserHashViewController

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
  
  self.title = @"USER HASH";
  
  CGRect frame = self.txtFieldUserHash.frame;
  frame.size.height = 44;
  self.txtFieldUserHash.layer.cornerRadius = self.txtFieldUserHash.height/2.f;
  self.txtFieldUserHash.frame = frame;
  self.txtFieldUserHash.backgroundColor = kColorFromHex(0x44566B);
  self.txtFieldUserHash.keyboardAppearance = UIKeyboardAppearanceAlert;
  
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
  
  self.userHashHelper = [UserHashHelper sharedInstance];
}

- (void) viewDidAppear:(BOOL)animated{
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

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard :(UITapGestureRecognizer *)gesture {
  [self.txtFieldUserHash resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}


- (IBAction)btnCancelPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];

}

- (void) successfullDownloadingLocationList{
  [self.navigationItem setRightBarButtonItems:nil animated:NO];
  self.btnDone.alpha = 1.f;
  NSIndexPath *index = [NSIndexPath indexPathForItem:1 inSection:0];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
}

- (void) changeDownloadingLocationListValue:(NSInteger)value{
  
}

- (void) errorWhileDownloadingLocationList:(NSInteger)error{
  [self.navigationItem setRightBarButtonItems:nil animated:NO];
  if(error == -1)
    [self showStatusBarMessage:@"    Cannot connect to server. Check your internet connection." withColor:kColorFromHex(0xD36666) hideAfter:5];
  [self viewDidAppear:NO];
}


- (void)addRefreshControl{
  UIActivityIndicatorView *refreshControl = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:refreshControl];
  [refreshControl startAnimating];
}

- (IBAction)btnDonePressed:(id)sender {
  [self.txtFieldUserHash resignFirstResponder];
  self.userHashHelper.userHash = self.txtFieldUserHash.text;
  self.btnDone.alpha = 0.7f;
  [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:activityBarItem,nil] animated:NO];
  [self.userHashHelper startDownloadProcess:@"" :NO];
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
