//
//  NoLocationView.m
//  Navigine
//
//  Created by Администратор on 07/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "NoLocationView.h"

@implementation NoLocationView

-(void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                               forBarPosition:UIBarPositionAny
                                                   barMetrics:UIBarMetricsDefault];
  
  [self.navigationController.navigationBar setShadowImage:[UIImage new]];
  self.btnChooseMap.layer.cornerRadius = self.btnChooseMap.height/2.f;
  
  [self addLeftButton];
  self.text.font = [UIFont fontWithName:@"Circe-Bold" size:17.0f];
}

-(void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.view.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                               forBarPosition:UIBarPositionAny
                                                   barMetrics:UIBarMetricsDefault];
  
  [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


- (IBAction)btnChooseMapPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft){
    [self.slidingPanelController closePanel];
  }
  else{
    [self.slidingPanelController openLeftPanelWithCompletion:^{
      [[NSNotificationCenter defaultCenter] postNotificationName:@"locationManagementPressed"
                                                          object:nil
                                                        userInfo:nil];
    }];
  }

}

- (void)addLeftButton {
  UIImage *buttonImage = [UIImage imageNamed:@"btnMenu"];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  [leftButton addTarget:self action:@selector(menuPressed:)  forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
  
}

- (IBAction)menuPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft){
    [self.slidingPanelController closePanel];
  }
  else{
    [self.slidingPanelController openLeftPanel];
  }
}
@end
