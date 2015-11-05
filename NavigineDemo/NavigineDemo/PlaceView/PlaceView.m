//
//  PlaceView.m
//  SVO
//
//  Created by Valentine on 27.07.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "PlaceView.h"

NSString *type;
Venue *venues;

static PlaceView * sharedManager;


@interface PlaceView (){
  UIActivityIndicatorView *refreshControl;
}
@property (nonatomic, strong) MapHelper *mapHelper;

@end

@implementation PlaceView

+ (PlaceView *)sharedManager {
  
  if (nil != sharedManager) {
    return sharedManager;
  }
  
  static dispatch_once_t pred;        // Lock
  dispatch_once(&pred, ^{             // This code is called at most once per app
    sharedManager = [super allocWithZone:nil];
    
  });
  
  return sharedManager;
}

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
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  
  self.view.backgroundColor = kColorFromHex(0xEAEAEA);
  
  self.nameLabel.text = self.venues.name.uppercaseString;
  self.nameLabel.font = [UIFont fontWithName:@"Circe-Bold" size:20.0f];
  self.nameLabel.textColor = kColorFromHex(0x162D47);
  
  self.descriptionLabel.text = self.venues.descriptionEn;
  self.descriptionLabel.font = [UIFont fontWithName:@"Circe-Bold" size:13.0f];
  self.descriptionLabel.textColor = kColorFromHex(0x939393);
  [self.descriptionLabel sizeToFit];
  
  self.callBtn.titleLabel.font = [UIFont fontWithName:@"Circe-Bold" size:12.0f];
  self.callBtn.titleLabel.textColor = kColorFromHex(0x51575E);
  
  self.mapBtn.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  self.mapBtn.titleLabel.textColor = kColorFromHex(0x4AADD4);
  self.line.top  = self.descriptionLabel.bottom + 22.0f;
  
  self.phoneLabel.text = self.venues.phone;
  self.phoneLabel.font = [UIFont fontWithName:@"Circe-Bold" size:17.5f];
  self.phoneLabel.textColor = kColorFromHex(0x162D47);
  
  self.phoneLabel.top = self.line.bottom + 20.0f;
  self.line2.top      = self.phoneLabel.bottom + 20.0f;
  self.callBtn.centerY = self.phoneLabel.centerY;
  
  self.mapBtn.top = self.line2.bottom + 25.0f;
  self.mapBtn.titleLabel.textColor = kColorFromHex(0x4AADD4);
  [[self.mapBtn layer] setBorderWidth:0.f];
  
  self.btnBack.layer.cornerRadius = self.btnBack.height/2.f;
  self.btnBack.clipsToBounds = YES;
  
  refreshControl = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [self.image addSubview:refreshControl];
  refreshControl.center = self.image.center;
  [refreshControl startAnimating];
  
  self.mapHelper = [MapHelper sharedInstance];
  self.mapHelper.venueDelegate = self;
  type = nil;
  
  if(self.venues.image){
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.image setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.venues.image]] placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                 
                                 refreshControl.hidden = YES;
                                 self.image.image = image;
                                 self.image.alpha = 0.0f;
                                 
                                 [UIView animateWithDuration:0.5 animations:^{
                                   self.image.alpha = 1;
                                 }];
                                 
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 [self.navigationController setNavigationBarHidden:NO animated:YES];
                                 self.image.hidden = YES;
                                 self.btnBack.hidden = YES;
                                 refreshControl.hidden = YES;
                                 self.nameLabel.top = 20.f;
                                 self.line0.top = self.nameLabel.bottom + 20.f;
                                 self.descriptionLabel.top = self.line0.bottom + 20.f;
                                 self.line.top  = self.descriptionLabel.bottom + 22.0f;
                                 self.phoneLabel.top = self.line.bottom + 20.0f;
                                 self.line2.top      = self.phoneLabel.bottom + 20.0f;
                                 self.callBtn.centerY = self.phoneLabel.centerY;
                                 self.mapBtn.top = self.line2.bottom + 25.0f;
                               }];
  }
  else{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.image.hidden = YES;
    self.btnBack.hidden = YES;
    refreshControl.hidden = YES;
    self.nameLabel.top = 20.f;
    self.line0.top = self.nameLabel.bottom + 20.f;
    self.descriptionLabel.top = self.line0.bottom + 20.f;
    self.line.top  = self.descriptionLabel.bottom + 22.0f;
    self.phoneLabel.top = self.line.bottom + 20.0f;
    self.line2.top      = self.phoneLabel.bottom + 20.0f;
    self.callBtn.centerY = self.phoneLabel.centerY;
    self.mapBtn.top = self.line2.bottom + 25.0f;
  }
  
  [self addBackButton];
  
}


- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
//  [self.navigationController setNavigationBarHidden:YES animated:animated];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
  
}


- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:animated];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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

- (Venue *)routeToPlace {
  return venues;
}

- (NSString *)showType {
  return type;
}


- (void)scrollViewDidScroll:(UIScrollView *)scroll {
  CGFloat y = scroll.contentOffset.y;
  
  if(y<0) {
    y = y*(-1);
    self.image.frame = CGRectMake(0, 0 - y, self.image.width, 160.0f + y);
  }
}

- (IBAction)backPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)callPressed:(id)sender {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",self.venues.phone]];
  [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)routePressed:(id)sender {
  
}

- (IBAction)showPressed:(id)sender {
  type = @"show";
  venues = self.venues;
  [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)makRoutePressed:(id)sender {
  type = @"route";
  venues = self.venues;
  [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)convertViewToImage {
  UIGraphicsBeginImageContext(self.navigationController.view.bounds.size);
  [self.navigationController.view drawViewHierarchyInRect:self.navigationController.view.bounds afterScreenUpdates:YES];
  UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image2;
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

@end
