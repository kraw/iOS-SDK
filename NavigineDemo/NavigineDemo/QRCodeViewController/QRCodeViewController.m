//
//  MenuViewController.m
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "QRCodeViewController.h"


@interface QRCodeViewController()

@property (nonatomic, strong) UserHashHelper *userHashHelper;

@end

@implementation QRCodeViewController

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
  //  self.navigationController.navigationBar.backgroundColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = YES;
  
  [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                               forBarPosition:UIBarPositionAny
                                                   barMetrics:UIBarMetricsDefault];
  
  [self.navigationController.navigationBar setShadowImage:[UIImage new]];
  
  
//  [self addLeftButton];
  
  self.userHash.layer.cornerRadius = self.userHash.height/2.f;
  self.userHash.backgroundColor = kColorFromHex(0x44566B);
  
  self.userHashHelper = [UserHashHelper sharedInstance];
  if(self.userHashHelper.userHash != nil){
    NSIndexPath *index = [NSIndexPath indexPathForItem:1 inSection:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
  }

  self.inviteText.font = [UIFont fontWithName:@"Circe-Bold" size:18.0f];
  self.captureSession = [[AVCaptureSession alloc] init];
  AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  NSError *error = nil;
  AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
  if(videoInput)
    [self.captureSession addInput:videoInput];
  else{
    UIImageView *cameraImage = [[UIImageView alloc] initWithFrame:CGRectMake(72, 94, 176, 176)];
    cameraImage.backgroundColor = kColorFromHex(0x14263B);
    UILabel *cameraTitle = [UILabel new];
    cameraTitle.text = @"Camera";
    cameraTitle.font = [UIFont fontWithName:@"Circe-Regular" size:17.0f];
    cameraTitle.textColor = kColorFromHex(0x162D47);
    [cameraTitle sizeToFit];
    cameraTitle.centerX = cameraImage.width/2.;
    cameraTitle.centerY = cameraImage.height/2.;
    [cameraImage addSubview:cameraTitle];
    [self.view addSubview:cameraImage];
    return;
  }
  
  AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
  [self.captureSession addOutput:metadataOutput];
  [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
  [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]];
  
  AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
  previewLayer.frame = CGRectMake(72, 94, 176, 176);
  previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self.view.layer addSublayer:previewLayer];
}


-(void) viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [self.captureSession startRunning];
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
    [self.slidingPanelController closePanel];
  }
  else {
    [self.slidingPanelController openLeftPanel];
  }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
  for(AVMetadataObject *metadataObject in metadataObjects){
    AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
    if([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]){
      self.userHashHelper.userHash = readableObject.stringValue;
      [self.captureSession stopRunning];
      [self performSegueWithIdentifier:@"userhash" sender:nil];
    }
    else if ([metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code]){
      self.userHashHelper.userHash = readableObject.stringValue;
      [self.captureSession stopRunning];
    }
  }
}

@end
