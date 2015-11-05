//
//  ConsoleView.m
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController (){
}
@property (nonatomic, strong) DebugHelper *debugHelper;
@property (nonatomic, strong) NavigineManager *navigineManager;
@end

@implementation LogViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  self.navigationController.navigationBar.translucent = NO;
  self.sv.contentSize = CGSizeMake(320, 471);
  
  self.debugHelper = [DebugHelper sharedInstance];
  self.navigineManager = [NavigineManager sharedManager];
  self.logFile.hidden = YES;
  self.btnSearch.hidden = NO;
  
  self.navigateThisLog.hidden = YES;
  self.removeThisLog.hidden = YES;
  self.line.hidden = YES;
}

- (void)viewDidUnload{
  [super viewDidUnload];
  
}

- (void)viewWillAppear:(BOOL)animated{
  if(self.debugHelper.navigateLogfile && ![self.debugHelper.navigateLogfile isEqualToString:@""]){
    self.logFile.text = self.debugHelper.navigateLogfile;
    self.logFile.hidden = NO;
    self.btnSearch.hidden = YES;
    
    self.navigateThisLog.hidden = NO;
    self.removeThisLog.hidden = NO;
    self.line.hidden = NO;
  }
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
}



- (IBAction)btnNavigate:(id)sender {
}

- (IBAction)btnRemove:(id)sender {
  self.logFile.hidden = YES;
  self.btnSearch.hidden = NO;
  
  self.navigateThisLog.hidden = YES;
  self.removeThisLog.hidden = YES;
  self.line.hidden = YES;
  NSError *error = nil;
  BOOL ok = NO;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [paths[0] stringByAppendingPathComponent:self.navigineManager.location.name];
  NSString *log = [path stringByAppendingPathComponent: self.debugHelper.navigateLogfile];
  
  if([[NSFileManager defaultManager] fileExistsAtPath:log]){
    ok = [[NSFileManager defaultManager] removeItemAtPath:log error:&error];
  }
  if(!ok)
    NSLog(@"Can't remove log file");
  if(error)
    NSLog(@"%@",[error localizedDescription]);
  self.debugHelper.navigateLogfile = @"";
}
@end
