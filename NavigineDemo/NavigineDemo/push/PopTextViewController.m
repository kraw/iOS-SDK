//
//  PopTextViewController.m
//  SVO
//
//  Created by Valentine on 03.07.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "PopTextViewController.h"

@interface PopTextViewController (){
  UIActivityIndicatorView *refreshControl;
}

@end

@implementation PopTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  self.titleLabel.text = self.pushTitle;
  self.textLabel.text  = self.pushContent;
  refreshControl = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [self.image addSubview:refreshControl];
  refreshControl.center = self.image.center;
  [refreshControl startAnimating];
  self.image.backgroundColor = kClearColor;
  [self.image setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_pushImage]]
                placeholderImage:nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                           refreshControl.hidden = YES;
                           self.image.image = image;
                           self.image.alpha = 0;
                           [UIView animateWithDuration:1.0 animations:^{
                             self.image.alpha = 1;
                           }];
                           
                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                           refreshControl.hidden = YES;
                           self.image.frame = CGRectMake(0, 0, 320.f, 160.f);
                           self.image.image = [UIImage imageNamed:@"elmPushNoPicture"];
                           self.titleLabel.top = self.image.bottom + 21;
                           self.textLabel.top = self.titleLabel.bottom + 8;
                         }];
  
  self.titleLabel.font = [UIFont fontWithName:@"Circe-Bold" size:17.0f];
  self.titleLabel.textColor = kColorFromHex(0xFAFAFA);
  self.titleLabel.text = self.titleLabel.text.uppercaseString;
  
  self.textLabel.font = [UIFont fontWithName:@"Circe-Bold" size:13.0f];
  self.textLabel.textColor = kColorFromHex(0xFAFAFA);
  [self.textLabel sizeToFit];
  self.textLabel.textAlignment = NSTextAlignmentCenter;
  
  self.textLabel.centerX = self.view.centerX;
//  self.btnConfirm.bottom = self.view.bottom;
  
  self.btnConfirm.layer.cornerRadius = self.btnConfirm.height/2.f;
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
  
  CGFloat y = scroll.contentOffset.y;
  
  if(y<0) {
    y=y*(-1);
    self.image.frame = CGRectMake(0, 0-y, self.image.width, 205+y);
  }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)backPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
@end
