//
//  ManualView.m
//  Navigine
//
//  Created by Администратор on 16/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "ManualView.h"
@interface ManualView(){
  UIWebView *manualView;
}
@end
@implementation ManualView

-(void)viewDidLoad{
  [super viewDidLoad];
  
  self.title = @"MANUAL";
  //URL Requst Object
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.navigine.com/iosManual/docs-ios/index.html"]];
//  Load the request in the UIWebView.
  [self.manual loadRequest:requestObj];
  
  [self addBackButton];
}

-(void) addBackButton{
  UIImage *buttonImage = [UIImage imageNamed:@"btnBack"];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  [leftButton addTarget:self action:@selector(backPressed:)  forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
}

-(IBAction)backPressed:(id)sender{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
