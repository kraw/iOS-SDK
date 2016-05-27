//
//  DetailLoaderView.m
//  NavigineDemo
//
//  Created by Администратор on 13/01/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "DetailLoaderView.h"

@interface DetailLoaderView(){
  NSInteger index;
}
@property (nonatomic, strong) DetailLoaderViewHelper *detailLoaderViewHelper;

@property (nonatomic, strong) NSArray *webViewArray;
//@property (nonatomic, strong) UIWebView *contentView;
@end;

@implementation DetailLoaderView

-(void)viewDidLoad{
  [super viewDidLoad];
  index = 0;
  
  self.title = self.location.name;
  self.sv.delegate = self;
  self.sv.scrollEnabled = YES;
  self.sv.backgroundColor = kColorFromHex(0xE8E8E8);
  self.sv.contentSize = CGSizeMake(self.location.subLocations.count * 320 + 1, 192);
  
  [self addBackButton];
  [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"btnBack"]];
  [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"btnBack"]];
  
  self.detailLoaderViewHelper = [[DetailLoaderViewHelper alloc] initWithLocation:self.location];
  self.detailLoaderViewHelper.delegate = self;
  [self.detailLoaderViewHelper getMapFromZip];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0.f);
  NSInteger newindex = floor(self.sv.contentOffset.x / self.view.width + 0.5f);
    
  if(index != newindex){
    index = newindex;
    if (index > self.location.subLocations.count - 1) return;
    Sublocation *sublocation = self.location.subLocations[index];
    self.name.text = sublocation.name;
    self.size.text = [NSString stringWithFormat:@"%.2lfx%.2lf",sublocation.width,sublocation.height];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
  NSInteger newindex = floor(self.sv.contentOffset.x / self.view.width + 0.5f);
  [self centerImageAtIndex:newindex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate{
  if (!decelerate) {
    NSInteger newindex = floor(self.sv.contentOffset.x / self.view.width + 0.5f);
    [self centerImageAtIndex:newindex];
  }
}

- (void) didRangeImages:(NSArray *)images{
  self.webViewArray = images;
  UIWebView *view = nil;
  for(int i = 0; i < self.webViewArray.count; i++){
    view = self.webViewArray[i];
    [self.sv addSubview:view];
    CGFloat xCenter = (320.f - view.width)/2.f;
    view.origin = CGPointMake(0.f, 20.f);
    view.centerX = 320.f * i + 160.f;
    view.hidden = NO;
  }
  Sublocation *sublocation = self.location.subLocations[0];
  NSString *modified = @"";
  if (self.location.modified)
    modified = @"+";
  self.version.text = [NSString stringWithFormat:@"%zd%@", self.location.version,modified];
  self.name.text = sublocation.name;
  self.size.text = [NSString stringWithFormat:@"%.2lfx%.2lf",sublocation.width,sublocation.height];
}

-(void) centerImageAtIndex: (NSInteger)newindex{
  self.sv.contentOffset = CGPointMake(320.f * newindex, 0.f);
}

@end