//  MapView
//  NavigineDemo
//
//  Created by Administrator on 7/14/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MeasuringView.h"
#import "NavigineSDK.h"
#import "NavigineManager.h"

@interface MeasuringView(){
  int sublocationId;
  NSString *locationName;
  CGFloat zoomScale;
  CGFloat lineWith;
  
  NSMutableArray *beacons;
  
  //view that contains Beacons and Beacons names than shouldn't zoom
  UIView *viewWithNoZoom;
  
  Beacon *beacon;
  CGPoint originOffset;
  CGPoint translatedPoint;
  NSString *measureBeaconTitle;
  
  UITextField *x_textView;
  UITextField *y_textView;
  UITextField *name_textView;
  CGPoint addingBeaconPoint;
  
  UIView *helpView;
  
  CAShapeLayer   *processLayer;
  UIBezierPath   *processPath;
  UILabel        *progressLabel;
  
  BOOL isDrawingPath;
  BOOL isPositionChangedFromLastAdding;
  NSMutableArray *points;
  NSMutableArray *lines;
  UIBezierPath *currentPath;
  CAShapeLayer *currentLayer;
  
  UIView *startPointTitle;
  UIView *finishPointTitle;
  
  NSInteger measuringCheckPointNumber;
  NSInteger timeFromStartMeasurement;
  
  NSString *logFileName;
}

@property (nonatomic, strong) MapHelper *mapHelper;
@property (nonatomic, strong) NavigineManager *navigineManager;
@property (nonatomic, strong) UploaderHelper  *uploaderHelper;
@property (nonatomic, strong) LoaderHelper *loaderHelper;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) PolyLineLayout *polyLineLayout;
@property (nonatomic, strong) NSTimer *polyLineTimer;
@end

@implementation MeasuringView

- (void)viewDidLoad{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  self.view.backgroundColor = kColorFromHex(0xEAEAEA);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  
  self.sv.backgroundColor = kColorFromHex(0xEAEAEA);
  CustomTabBarViewController *slide = (CustomTabBarViewController *)self.tabBarController;
  slide.tabBar.hidden = YES;
  self.title = @"MEASURING MODE";
  
  [self addLeftButton];
  [self addRightButton];
  [self addHelpView];
  
  self.navigineManager = [NavigineManager sharedManager];
  self.navigineManager.beaconMeasureDelegate = self;
  self.navigineManager.dataDelegate = self;
  
  self.loaderHelper = [LoaderHelper sharedInstance];
  self.uploaderHelper = [UploaderHelper sharedInstance];
  
  viewWithNoZoom = [[UIView alloc] init];
  
  self.mapHelper = [MapHelper sharedInstance];
  self.mapHelper.delegate = self;
  self.mapHelper.venueDelegate = nil;
  
  self.zoomInBtn.layer.cornerRadius = self.zoomInBtn.height/2.f;
  self.zoomOutBtn.layer.cornerRadius = self.zoomOutBtn.height/2.f;
  
  self.btnDownFloor.transform = CGAffineTransformMakeRotation(M_PI);
  self.btnDownFloor.hidden = NO;
  
  self.btnUpFloor.hidden = NO;

  zoomScale = 1.0f;
  lineWith = 2.0f;
  beacons = [[NSMutableArray alloc] init];
  locationName = @"";
  measureBeaconTitle = [NSString string];
  addingBeaconPoint = CGPointZero;
  
  processPath = [[UIBezierPath alloc] init];
  [processPath moveToPoint:CGPointMake(0, 15.f)];
  processLayer = [CAShapeLayer layer];
  processLayer.path            = [processPath CGPath];
  processLayer.strokeColor     = [kColorFromHex(0x4AADD4) CGColor];
  processLayer.lineWidth       = 30.f;
  processLayer.lineJoin        = kCALineJoinRound;
  processLayer.fillColor       = [[UIColor clearColor] CGColor];
  
  points = [[NSMutableArray alloc] init];
  lines = [[NSMutableArray alloc] init];
  
  [self.sv addSubview:self.contentView];
  
  UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handlePanGesture:)];
  [self.sv addGestureRecognizer:gestureRecognizer];
  
  UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(scale:)];
  [pinchRecognizer setDelegate:self];
  [_sv addGestureRecognizer:pinchRecognizer];
  
//  [self.progressBar.layer addSublayer:processLayer];
  progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.progressBar.width, self.progressBar.height)];
  progressLabel.textAlignment = NSTextAlignmentCenter;
  progressLabel.textColor = kColorFromHex(0xfafafa);
  [self.progressBar addSubview:progressLabel];
  self.progressBar.backgroundColor = kColorFromHex(0xD3D3D3);
  self.progressBar.bottom = 0.f;
  CGFloat bottom = self.view.bottom;
  _viewAddBeacon.bottom = bottom - 61;
  
  _polyLineLayout = [[PolyLineLayout alloc] init];
  _polyLineLayout.hidden = YES;
  [_polyLineLayout.addPointButton addTarget:self
                                     action:@selector(addPointButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
  [_polyLineLayout.finishButton addTarget:self
                                   action:@selector(finishButtonClicked:)
                         forControlEvents:UIControlEventTouchUpInside];
  [_polyLineLayout.startMeasuringButton addTarget:self
                                           action:@selector(startMeasuringButtonClicked:)
                                 forControlEvents:UIControlEventTouchUpInside];
  [_polyLineLayout.checkPointButton addTarget:self
                                       action:@selector(checkPointButtonClicked:)
                             forControlEvents:UIControlEventTouchUpInside];
  [_polyLineLayout.closeButton addTarget:self
                                  action:@selector(closeButtonClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_polyLineLayout];
  
  isDrawingPath = NO;
  isPositionChangedFromLastAdding = NO;
  measuringCheckPointNumber = 0;
  timeFromStartMeasurement = 0;
  logFileName = NULL;
  self.sv.scrollEnabled = NO;
  _sv.minimumZoomScale = 0.5f;
  _sv.maximumZoomScale = 5.0f;
  zoomScale = 1.0f;
  self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)scale:(UIPinchGestureRecognizer*)gestureRecognizer{
  if ([gestureRecognizer numberOfTouches] < 2)
    return;
  
  float scale = gestureRecognizer.scale - 1;
  [gestureRecognizer setScale:1];
  CGPoint origin = _sv.bounds.origin ;
  CGPoint firstCenter = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
  CGPoint center = CGPointMake(firstCenter.x/self.contentView.bounds.size.width,(1.f - firstCenter.y/self.contentView.bounds.size.height));
  [_sv setZoomScale:zoomScale + scale animated:NO];
  CGFloat newOriginX = firstCenter.x * _sv.zoomScale - _sv.bounds.size.width/2.;
  CGFloat newOriginY = firstCenter.y * _sv.zoomScale - _sv.bounds.size.height/2.;
  _sv.bounds = CGRectMake(newOriginX, newOriginY, _sv.bounds.size.width, _sv.bounds.size.height);
  zoomScale = _sv.zoomScale;
  lineWith = 2.f / _sv.zoomScale;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer{
  return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer{
  CGPoint translation = [gestureRecognizer translationInView:self.sv];
  CGRect bounds = self.sv.bounds;
  
  // Translate the view's bounds, but do not permit values that would violate contentSize
  CGFloat newBoundsOriginX = bounds.origin.x - translation.x;
  CGFloat minBoundsOriginX = -bounds.size.width/2.;
  CGFloat maxBoundsOriginX = self.contentView.width - bounds.size.width/2.;
  bounds.origin.x = fmax(minBoundsOriginX, fmin(newBoundsOriginX, maxBoundsOriginX));
  
  CGFloat newBoundsOriginY = bounds.origin.y - translation.y;
  CGFloat minBoundsOriginY = -bounds.size.height/2.;
  CGFloat maxBoundsOriginY = self.contentView.height - bounds.size.height/2.;
  bounds.origin.y = fmax(minBoundsOriginY, fmin(newBoundsOriginY, maxBoundsOriginY));
  
  self.sv.bounds = bounds;
  [gestureRecognizer setTranslation:CGPointZero inView:self.sv];
  lineWith = 2.f / _sv.zoomScale;
  if(isDrawingPath){
    isPositionChangedFromLastAdding = YES;
    [currentLayer removeFromSuperlayer];
    currentLayer = nil;
    
    [currentPath removeAllPoints];
    currentLayer = [[CAShapeLayer alloc] init];
    
    CGPoint firstCenter = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
    UIImageView *lastPoint = [points lastObject];
    [currentPath moveToPoint:CGPointMake(lastPoint.centerX / _sv.zoomScale, lastPoint.centerY / _sv.zoomScale)];
    [currentPath addLineToPoint:CGPointMake(firstCenter.x, firstCenter.y)];
    
    currentLayer.hidden = NO;
    currentLayer.path            = [currentPath CGPath];
    currentLayer.strokeColor     = [kColorFromHex(0x4AADD4) CGColor];
    currentLayer.lineWidth       = lineWith;
    currentLayer.lineJoin        = kCALineJoinRound;
    currentLayer.fillColor       = [[UIColor clearColor] CGColor];
    
    [_contentView.layer addSublayer:currentLayer];
    
    for (CAShapeLayer *line in lines)
      line.lineWidth = lineWith;
  }
}

- (void)tapPress:(UITapGestureRecognizer *)gesture {
  [self.navigineManager stopMeasureNearestBeacon];
  helpView.hidden = YES;
  [UIView animateWithDuration:0.5f animations:^{
    self.progressBar.bottom = -30.f;
  }];
  [processLayer removeFromSuperlayer];
  [progressLabel removeFromSuperview];
  measureBeaconTitle = [NSString string];
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
  CGRect zoomRect;
  
  // The zoom rect is in the content view's coordinates.
  // At a zoom scale of 1.0, it would be the size of the
  // imageScrollView's bounds.
  // As the zoom scale decreases, so more content is visible,
  // the size of the rect grows.
  zoomRect.size.height = scrollView.frame.size.height / scale;
  zoomRect.size.width  = scrollView.frame.size.width  / scale;
  
  // choose an origin so as to get the right center.
  zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
  zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
  
  return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.contentView;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
}

- (void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
  for (Beacon* onebeacon in beacons){
    [onebeacon resizeBeaconWithZoom:scrollView.zoomScale];
  }
  for(MeasurePoint *point in points){
    [point resizeMeasurePointWithZoom:scrollView.zoomScale];
  }
  for (CAShapeLayer *line in lines){
    line.lineWidth = 2.f / scrollView.zoomScale;
  }
  viewWithNoZoom.frame = self.contentView.frame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  for (Beacon* onebeacon in beacons){
    [onebeacon resizeBeaconWithZoom:scrollView.zoomScale];
  }
  for(MeasurePoint *point in points){
    [point resizeMeasurePointWithZoom:scrollView.zoomScale];
  }
  for (CAShapeLayer *line in lines){
    line.lineWidth = 2.f / scrollView.zoomScale;
  }
  viewWithNoZoom.frame = self.contentView.frame;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
  viewWithNoZoom.frame = self.contentView.frame;
}

- (void)addLeftButton {
  UIImage *buttonImage = [UIImage imageNamed:@"btnMenu"];
  self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  self.leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
  [self.leftButton addTarget:self action:@selector(menuPressed:)  forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
  
}

- (void)addRightButton {
  UIImage *buttonImage = [UIImage imageNamed:@"btnUpload"];
  UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
  [aButton addTarget:self action:@selector(uploadLocation:) forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
}

- (void) uploadLocation: (id)sender{
  if(self.navigineManager.modified){
    [self.uploaderHelper startUploadCurrentLocation];
    UIImage *buttonImage = [UIImage imageNamed:@"btnUpload"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    [aButton addTarget:self action:@selector(uploadLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer setWidth:-17];

    UIActivityIndicatorView *refreshControl = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshControl.hidden = YES;
    UIBarButtonItem *activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:refreshControl];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,activityBarItem,nil] animated:YES];
    [refreshControl startAnimating];
  }
  else
    [self showStatusBarMessage:@"  Version is not modified" withColor:kColorFromHex(0xD36666) hideAfter:5];
}

- (void)zoomToPoint:(CGPoint)zoomPoint withScale:(CGFloat)scale animated: (BOOL)animated{
  //Normalize current content size back to content scale of 1.0f
  CGSize contentSize;
  contentSize.width  = (_sv.contentSize.width / _sv.zoomScale);
  contentSize.height = (_sv.contentSize.height / _sv.zoomScale);
  
  //translate the zoom point to relative to the content rect
  //  zoomPoint.x = (zoomPoint.x / _sv.bounds.size.width) * contentSize.width;
  //  zoomPoint.y = (zoomPoint.y / _sv.bounds.size.height) * contentSize.height;
  
  //derive the size of the region to zoom to
  CGSize zoomSize;
  zoomSize.width  = _sv.bounds.size.width / scale;
  zoomSize.height = _sv.bounds.size.height / scale;
  
  //offset the zoom rect so the actual zoom point is in the middle of the rectangle
  CGRect zoomRect;
  zoomRect.origin.x    = zoomPoint.x - zoomSize.width / 2.0f;
  zoomRect.origin.y    = zoomPoint.y - zoomSize.height / 2.0f;
  zoomRect.size.width  = zoomSize.width;
  zoomRect.size.height = zoomSize.height;
  
  [_sv zoomToRect:zoomRect animated: YES];
  
}

- (void)centerScrollViewContents {
  CGSize boundsSize = _sv.bounds.size;
  CGRect contentsFrame = self.contentView.frame;
  
  if (contentsFrame.size.width < boundsSize.width) {
    contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
  } else {
    contentsFrame.origin.x = 0.0f;
  }
  
  if (contentsFrame.size.height < boundsSize.height) {
    contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
  } else {
    contentsFrame.origin.y = 0.0f;
  }
  self.contentView.frame = contentsFrame;
  viewWithNoZoom.frame = self.contentView.frame;
}

-(void)beaconClicked :(id)sender{
  beacon = (Beacon *)sender;
  CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
  
  // Add some custom content to the alert view
  [alertView setContainerView:[self createInfoViewWithBeacon:beacon.beacon]];
  
  // Modify the parameters
  [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Delete", @"Cancel", nil]];
  [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
    switch (buttonIndex) {
      case 0:
        [self.navigineManager removeMeasuredBeacon:beacon.beacon];
        [self.navigineManager saveBeaconsXML];
        self.navigineManager.modified = YES;
        [beacon removeFromSuperview];
        [beacons removeObject:beacon];
        break;
        
      default:
        break;
    }
    [alertView close];
  }];
  
  [alertView setUseMotionEffects:true];
  
  // And launch the dialog
  [alertView show];
}

-(void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  self.mapHelper.navigationType = NavigationTypeRegular;
  [self.navigineManager stopNavigine];
  [self.navigineManager loadArchive:locationName error:nil];
  [self.navigineManager startNavigine];

  for(Beacon *ncBeacon in beacons)
    [ncBeacon removeFromSuperview];
  [beacons removeAllObjects];
  self.uploaderHelper.uploaderDelegate = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName: @"setLocation"
                                                      object: nil
                                                    userInfo: @{@"locationName":locationName}];
}

- (void) viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  _sv.pinchGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _sv.pinchGestureRecognizer.enabled = NO;
  _uploaderHelper.uploaderDelegate = self;
  _navigineManager.dataDelegate = self;
  
  locationName = _navigineManager.location.name;
  _mapHelper = [MapHelper sharedInstance];
  _mapHelper.delegate = self;
  if (_mapHelper.sublocId.count == 1){
    _btnDownFloor.hidden = YES;
    _btnUpFloor.hidden = YES;
    _txtFloor.hidden = YES;
  }
  else{
    _btnDownFloor.hidden = NO;
    _btnDownFloor.alpha = 1.f;
    _btnUpFloor.hidden = NO;
    _btnUpFloor.alpha = 1.f;
    _txtFloor.hidden = NO;
  }
  [self changeFloorTo:_mapHelper.floor];
}

- (IBAction)menuPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
    [self.slidingPanelController closePanel];
  }
  else {
    [self.slidingPanelController openLeftPanel];
  }
}

- (IBAction)startMeasurePolyLine:(id)sender {
  UIButton *btn = (UIButton *)sender;
  [_polyLineTimer invalidate];
  if(btn.selected){
    for (UIImageView *point in points){
      [point removeFromSuperview];
    }
    [points removeAllObjects];
    
    for (CAShapeLayer *line in lines){
      [line removeFromSuperlayer];
    }
    [lines removeAllObjects];
    
    [startPointTitle removeFromSuperview];
    [finishPointTitle removeFromSuperview];
    [btn setSelected:NO];
    currentPath = nil;
    [currentLayer removeFromSuperlayer];
    currentLayer = nil;
     _polyLineLayout.hidden = YES;
    isDrawingPath = NO;
    isPositionChangedFromLastAdding = NO;
  }
  else{
    [btn setSelected:YES];
    MeasurePoint *startPoint = [[MeasurePoint alloc] initWithState:MeasurePointStart];
    startPoint.center = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x) / _sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y) / _sv.zoomScale);
    startPoint.originalCenter = startPoint.center;
    [startPoint resizeMeasurePointWithZoom:_sv.zoomScale];
    [points addObject:startPoint];
    
    currentPath = [[UIBezierPath alloc] init];
    currentLayer = [[CAShapeLayer alloc] init];
    
    [currentPath moveToPoint:CGPointMake(startPoint.centerX, startPoint.centerY)];
    [viewWithNoZoom addSubview:startPoint];
    startPointTitle.right = startPoint.left;
    startPointTitle.bottom = startPoint.bottom;
    [viewWithNoZoom addSubview:startPointTitle];
    
    _polyLineLayout.hidden = NO;
    isDrawingPath = YES;
    isPositionChangedFromLastAdding = NO;
    
    startPointTitle.backgroundColor = kColorFromHex(0x4AADD4);
    finishPointTitle.backgroundColor = kColorFromHex(0x4AADD4);
    
    _polyLineLayout.addPointButton.hidden = NO;
    _polyLineLayout.finishButton.hidden = NO;
    _polyLineLayout.startMeasuringButton.hidden = YES;
    _polyLineLayout.checkPointButton.hidden = YES;
    _polyLineLayout.closeButton.hidden=YES;
    _polyLineLayout.label.text = @"Add check points and tap FINISH";
    [_polyLineLayout.label sizeToFit];
  }
}

- (IBAction)startMeasureBeacon:(id)sender {
  CGRect bounds = self.sv.bounds;
  translatedPoint = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
  CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
  
  // Add some custom content to the alert view
  NSString *beaconName = [NSString stringWithFormat:@"B.%zd.%zd",sublocationId,beacons.count];
  [alertView setContainerView:[self createAddViewWithName:beaconName x: translatedPoint.x/self.contentView.bounds.size.width*self.navigineManager.DEFAULT_WIDTH y:(1. - translatedPoint.y/self.contentView.bounds.size.height)*self.navigineManager.DEFAULT_HEIGHT]];
  
  // Modify the parameters
  [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Start", @"Cancel", nil]];
  [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
    switch (buttonIndex) {
      case 0:
        measureBeaconTitle = name_textView.text;
        addingBeaconPoint = CGPointMake([x_textView.text floatValue], [y_textView.text floatValue]);
        beacon = [[Beacon alloc] initWithBeacon:[[NCBeacon alloc] init]];
        beacon.beacon.subLocationId = sublocationId;
        beacon.beacon.kX = addingBeaconPoint.x/self.navigineManager.DEFAULT_WIDTH;
        beacon.beacon.kY = addingBeaconPoint.y/self.navigineManager.DEFAULT_HEIGHT;
        beacon.beacon.name = measureBeaconTitle;
        
        processPath = [[UIBezierPath alloc] init];
        [processPath moveToPoint:CGPointMake(0, 15.f)];
        processLayer = [CAShapeLayer layer];
        processLayer.path            = [processPath CGPath];
        processLayer.strokeColor     = [kColorFromHex(0x4AADD4) CGColor];
        processLayer.lineWidth       = 30.f;
        processLayer.lineJoin        = kCALineJoinRound;
        processLayer.fillColor       = [[UIColor clearColor] CGColor];
        
        [self.progressBar.layer addSublayer:processLayer];
        progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.progressBar.width, self.progressBar.height)];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.textColor = kColorFromHex(0xfafafa);
        [self.progressBar addSubview:progressLabel];
        {
          [UIView animateWithDuration:0.5f animations:^{
            self.progressBar.bottom = 30.f;
          }];
        }
        [self.navigineManager startMeasureNearestBeacon:beacon.beacon];
        helpView.hidden = NO;
        
        break;
        
      default:
        break;
    }
    [alertView close];
  }];
  
  [alertView setUseMotionEffects:true];
  
  // And launch the dialog
  [alertView show];
}

- (IBAction)showLabels:(id)sender {
  if (_showLabelsButton.isSelected){
    [_showLabelsButton setSelected:NO];
    for(Beacon *beaconButton in beacons){
      beaconButton.textImage.hidden = YES;
    }
  }
  else{
    [_showLabelsButton setSelected:YES];
    for(Beacon *beaconButton in beacons){
      beaconButton.textImage.hidden = NO;
    }
  }
}

- (IBAction)zoomInTouch:(id)sender {
  CGPoint origin = _sv.bounds.origin ;
  CGPoint firstCenter = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
  CGPoint center = CGPointMake(firstCenter.x/self.contentView.bounds.size.width,(1.f - firstCenter.y/self.contentView.bounds.size.height));
  [_sv setZoomScale:zoomScale + 0.2f animated:NO];
  CGFloat newOriginX = firstCenter.x * _sv.zoomScale - _sv.bounds.size.width/2.;
  CGFloat newOriginY = firstCenter.y * _sv.zoomScale - _sv.bounds.size.height/2.;
  _sv.bounds = CGRectMake(newOriginX, newOriginY, _sv.bounds.size.width, _sv.bounds.size.height);
  zoomScale = _sv.zoomScale;
}

- (IBAction)zoomOutTouch:(id)sender {
  CGPoint origin = _sv.bounds.origin ;
  CGPoint firstCenter = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
  CGPoint center = CGPointMake(firstCenter.x/self.contentView.bounds.size.width,(1.f - firstCenter.y/self.contentView.bounds.size.height));
  [_sv setZoomScale:zoomScale - 0.2f animated:NO];
  CGFloat newOriginX = firstCenter.x * _sv.zoomScale - _sv.bounds.size.width/2.;
  CGFloat newOriginY = firstCenter.y * _sv.zoomScale - _sv.bounds.size.height/2.;
  _sv.bounds = CGRectMake(newOriginX, newOriginY, _sv.bounds.size.width, _sv.bounds.size.height);
  zoomScale = _sv.zoomScale;
}

- (IBAction)upFloor:(id)sender {
  self.btnDownFloor.alpha = 1.f;
  if(self.mapHelper.floor != 0){
    self.mapHelper.floor--;
    [self changeFloorTo:self.mapHelper.floor];
  }
}

- (IBAction)downFloor:(id)sender {
  self.btnUpFloor.alpha = 1.f;
  if(self.mapHelper.floor != self.mapHelper.sublocId.count - 1){
    self.mapHelper.floor++;
    [self changeFloorTo:self.mapHelper.floor];
  }
}

- (void) changeFloorTo:(NSInteger)row{
  if(_mapHelper.floor == 0){
    _btnUpFloor.alpha = 0.7f;
  }
  if(_mapHelper.floor == _mapHelper.sublocId.count - 1){
    self.btnDownFloor.alpha = 0.7f; 
  }
  NSError *error = nil;
  sublocationId = [self.mapHelper.sublocId[row] intValue];
  CGSize imageSize = [self.navigineManager sizeForImageAtIndex:self.mapHelper.floor error:&error];
  
  if(error){
    [UIAlertView showWithTitle:@"ERROR" message:@"Incorrect width and height" cancelButtonTitle:@"OK"];
  }
  [self.contentView removeFromSuperview];
  self.contentView = self.mapHelper.webViewArray[row];
  viewWithNoZoom.frame = self.contentView.frame;
  
  self.sv.bounds = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
  
  for(UIButton *btn in beacons) [btn removeFromSuperview];
  [beacons removeAllObjects];
  Sublocation *subLocation = [_navigineManager.location subLocationAtId:sublocationId];
  for(NCBeacon* ncBeacon in subLocation.beacons){
    if(ncBeacon.status != NCBeaconDel){
      Beacon *oldBeacon = [[Beacon alloc] initWithBeacon:ncBeacon];
      [oldBeacon addTarget:self action:@selector(beaconClicked:) forControlEvents:UIControlEventTouchUpInside];
      oldBeacon.center = CGPointMake(ncBeacon.kX * self.contentView.bounds.size.width, (1.f - ncBeacon.kY) * self.contentView.bounds.size.height);
      oldBeacon.originalCenter = oldBeacon.center;
      if(_showLabelsButton.isSelected)
        oldBeacon.textImage.hidden = NO;
      else
        oldBeacon.textImage.hidden = YES;
      [viewWithNoZoom addSubview:oldBeacon];
      [beacons addObject:oldBeacon];
      [oldBeacon resizeBeaconWithZoom:_sv.zoomScale];
    }
  }
  
  self.contentView.origin = CGPointZero;
  viewWithNoZoom.origin = CGPointZero;
  self.sv.contentOffset = CGPointZero;

  [self.sv addSubview:self.contentView];
  self.contentView.hidden = NO;
  [self.sv addSubview:viewWithNoZoom];
  
  self.txtFloor.text = [NSString stringWithFormat:@"%zd", self.mapHelper.floor];
  zoomScale = _sv.zoomScale;
  _sv.frame = CGRectMake(0, 0, 320, 519);
}

- (void) addHelpView{
  helpView = [[UIView alloc] initWithFrame:CGRectMake(0, 368, 320, 87)];
  helpView.backgroundColor = kColorFromHex(0xEDEDED);
  helpView.alpha = 0.9f;
  
  NSString *labelText = @" Keep beacon close to the device while measuring. Tap here to cancel";
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineSpacing = 9.f;
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, 40)];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(29.f, 24.f, 262.f, 42.f)];
  label.attributedText = attributedString;
  label.textColor = kColorFromHex(0x162D47);
  label.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  label.textAlignment = NSTextAlignmentCenter;
  label.numberOfLines = 0;
  [helpView addSubview:label];
  helpView.hidden = YES;
  UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
  tapPress.delaysTouchesBegan   = NO;
  [helpView addGestureRecognizer:tapPress];
  [self.view addSubview:helpView];
}

- (UIView *)createInfoViewWithBeacon:(NCBeacon *)ncBeacon{
  UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 304, 350)];
  
  UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 288, 21)];
  title.text = @"Delete beacon";
  title.textAlignment = NSTextAlignmentCenter;
  title.font  = [UIFont fontWithName:@"Circe-Bold" size:20.0f];
  title.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title];
  
  UILabel *title_name = [[UILabel alloc] initWithFrame:CGRectMake(11, 48, 82, 21)];
  title_name.text = @"Name";
  title_name.textAlignment = NSTextAlignmentCenter;
  title_name.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_name.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_name];
  UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  name.text = ncBeacon.name;
  name.top = title_name.top;
  name.left = title_name.right;
  name.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  name.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:name];
  UIView *name_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  name_line.backgroundColor = kColorFromHex(0xCCCCCC);
  name_line.left = name.left;
  name_line.top = name.bottom;
  [demoView addSubview:name_line];
  
  UILabel *title_uuid = [[UILabel alloc] initWithFrame:CGRectMake(11, 98, 82, 21)];
  title_uuid.text = @"UUID";
  title_uuid.textAlignment = NSTextAlignmentCenter;
  title_uuid.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_uuid.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_uuid];
  UILabel *uuid = [[UILabel alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  uuid.text = ncBeacon.uuid;
  uuid.top = title_uuid.top;
  uuid.left = title_uuid.right;
  uuid.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  uuid.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:uuid];
  UIView *uuid_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  uuid_line.backgroundColor = kColorFromHex(0xCCCCCC);
  uuid_line.left = uuid.left;
  uuid_line.top = uuid.bottom;
  [demoView addSubview:uuid_line];
  
  UILabel *title_major = [[UILabel alloc] initWithFrame:CGRectMake(11, 148, 82, 21)];
  title_major.text = @"Major";
  title_major.textAlignment = NSTextAlignmentCenter;
  title_major.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_major.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_major];
  UILabel *major = [[UILabel alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  major.text = [NSString stringWithFormat:@"%zd", ncBeacon.major];
  major.top = title_major.top;
  major.left = title_major.right;
  major.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  major.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:major];
  UIView *major_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  major_line.backgroundColor = kColorFromHex(0xCCCCCC);
  major_line.left = major.left;
  major_line.top = major.bottom;
  [demoView addSubview:major_line];
  
  UILabel *title_minor = [[UILabel alloc] initWithFrame:CGRectMake(11, 198, 82, 21)];
  title_minor.text = @"Minor";
  title_minor.textAlignment = NSTextAlignmentCenter;
  title_minor.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_minor.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_minor];
  UILabel *minor = [[UILabel alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  minor.text = [NSString stringWithFormat:@"%zd", ncBeacon.minor];
  minor.top = title_minor.top;
  minor.left = title_minor.right;
  minor.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  minor.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:minor];
  UIView *minor_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  minor_line.backgroundColor = kColorFromHex(0xCCCCCC);
  minor_line.left = minor.left;
  minor_line.top = minor.bottom;
  [demoView addSubview:minor_line];
  
  UILabel *title_x = [[UILabel alloc] initWithFrame:CGRectMake(11, 248, 82, 21)];
  title_x.text = @"X";
  title_x.textAlignment = NSTextAlignmentCenter;
  title_x.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_x.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_x];
  UILabel *x = [[UILabel alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  x.text = [NSString stringWithFormat:@"%0.5f", ncBeacon.kX * self.navigineManager.DEFAULT_WIDTH];
  x.top = title_x.top;
  x.left = title_x.right;
  x.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  x.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:x];
  UIView *x_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  x_line.backgroundColor = kColorFromHex(0xCCCCCC);
  x_line.left = x.left;
  x_line.top = x.bottom;
  [demoView addSubview:x_line];
  
  UILabel *title_y = [[UILabel alloc] initWithFrame:CGRectMake(11, 298, 82, 21)];
  title_y.text = @"Y";
  title_y.textAlignment = NSTextAlignmentCenter;
  title_y.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_y.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_y];
  UILabel *y = [[UILabel alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  y.text = [NSString stringWithFormat:@"%0.5f", ncBeacon.kY * self.navigineManager.DEFAULT_HEIGHT];
  y.top = title_y.top;
  y.left = title_y.right;
  y.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  y.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:y];
  UIView *y_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  y_line.backgroundColor = kColorFromHex(0xCCCCCC);
  y_line.left = y.left;
  y_line.top = y.bottom;
  [demoView addSubview:y_line];
  
  return demoView;
}

- (UIView *)createAddViewWithName:(NSString *)beaconName
                                x:(double)x_meters
                                y:(double)y_meters{
  UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 304, 200)];
  
  UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 288, 21)];
  title.text = @"Add beacon";
  title.textAlignment = NSTextAlignmentCenter;
  title.font  = [UIFont fontWithName:@"Circe-Bold" size:20.0f];
  title.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title];
  
  UILabel *title_name = [[UILabel alloc] initWithFrame:CGRectMake(11, 48, 82, 21)];
  title_name.text = @"Name";
  title_name.textAlignment = NSTextAlignmentCenter;
  title_name.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_name.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_name];
  name_textView = [[UITextField alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  name_textView.delegate = self;
  name_textView.autocorrectionType = UITextAutocorrectionTypeNo;
  name_textView.text = beaconName;
  name_textView.top = title_name.top;
  name_textView.left = title_name.right;
  name_textView.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  name_textView.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:name_textView];
  UIView *name_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  name_line.backgroundColor = kColorFromHex(0xCCCCCC);
  name_line.left = name_textView.left;
  name_line.top = name_textView.bottom;
  [demoView addSubview:name_line];
  
  UILabel *title_x = [[UILabel alloc] initWithFrame:CGRectMake(11, 98, 82, 21)];
  title_x.text = @"X";
  title_x.textAlignment = NSTextAlignmentCenter;
  title_x.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_x.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_x];
  x_textView = [[UITextField alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  x_textView.text = [NSString stringWithFormat:@"%0.5f", x_meters];
  x_textView.delegate = self;
  x_textView.top = title_x.top;
  x_textView.left = title_x.right;
  x_textView.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  x_textView.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:x_textView];
  UIView *x_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  x_line.backgroundColor = kColorFromHex(0xCCCCCC);
  x_line.left = x_textView.left;
  x_line.top = x_textView.bottom;
  [demoView addSubview:x_line];
  
  UILabel *title_y = [[UILabel alloc] initWithFrame:CGRectMake(11, 148, 82, 21)];
  title_y.text = @"Y";
  title_y.textAlignment = NSTextAlignmentCenter;
  title_y.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  title_y.textColor = kColorFromHex(0x162D47);
  [demoView addSubview:title_y];
  y_textView = [[UITextField alloc] initWithFrame:CGRectMake(107, 49, 189, 21)];
  y_textView.text = [NSString stringWithFormat:@"%0.5f", y_meters];
  y_textView.delegate = self;
  y_textView.top = title_y.top;
  y_textView.left = title_y.right;
  y_textView.font  = [UIFont fontWithName:@"Circe-Regular" size:20.0f];
  y_textView.textColor = kColorFromHex(0x4AADD4);
  [demoView addSubview:y_textView];
  UIView *y_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189, 1)];
  y_line.backgroundColor = kColorFromHex(0xCCCCCC);
  y_line.left = y_textView.left;
  y_line.top = y_textView.bottom;
  [demoView addSubview:y_line];
  return demoView;
}

- (void)showStatusBarMessage:(NSString *)message withColor:(UIColor *)color hideAfter:(NSTimeInterval)delay{
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

- (void)addPointButtonClicked:(UIButton *)button{
  if(isPositionChangedFromLastAdding){
    [lines addObject:currentLayer];
    MeasurePoint *point = [[MeasurePoint alloc] init];
    point.center = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
    point.originalCenter = point.center;
    [point resizeMeasurePointWithZoom:_sv.zoomScale];
    [points addObject:point];
    
    currentPath = [[UIBezierPath alloc] init];
    currentLayer = [[CAShapeLayer alloc] init];
    
    [currentPath moveToPoint:CGPointMake(point.centerX, point.centerY)];
    [viewWithNoZoom addSubview:point];
    isPositionChangedFromLastAdding = NO;
  }
}

- (void)finishButtonClicked:(UIButton *)button{
  MeasurePoint *finishPoint = [[MeasurePoint alloc] initWithState:MeasurePointFinish];
  finishPoint.center = CGPointMake((self.sv.bounds.size.width/2. + self.sv.bounds.origin.x)/_sv.zoomScale,(self.sv.bounds.size.height/2. + self.sv.bounds.origin.y)/_sv.zoomScale);
  finishPoint.originalCenter = finishPoint.center;
  [finishPoint resizeMeasurePointWithZoom:_sv.zoomScale];
  [lines addObject:currentLayer];
  
  currentPath = [[UIBezierPath alloc] init];
  currentLayer = [[CAShapeLayer alloc] init];
  
  if(isPositionChangedFromLastAdding){
    [currentPath moveToPoint:CGPointMake(finishPoint.centerX, finishPoint.centerY)];
    [viewWithNoZoom addSubview:finishPoint];
    [points addObject:finishPoint];
    isPositionChangedFromLastAdding = NO;
  }
  
  finishPointTitle.right = finishPoint.left;
  finishPointTitle.bottom = finishPoint.bottom;
  [viewWithNoZoom addSubview:finishPointTitle];
  
  isDrawingPath = NO;
  _polyLineLayout.addPointButton.hidden = YES;
  _polyLineLayout.finishButton.hidden = YES;
  _polyLineLayout.startMeasuringButton.hidden = NO;
  _polyLineLayout.checkPointButton.hidden = YES;
  _polyLineLayout.closeButton.hidden = YES;
  _polyLineLayout.label.text = @"Go to the first checkpoint and tap START";
  [_polyLineLayout.label sizeToFit];
}

-(void) closeButtonClicked:(UIButton *)button{
  [_polyLineTimer invalidate];
  if(_addPolyLineButton.selected){
    for (UIImageView *point in points){
      [point removeFromSuperview];
    }
    [points removeAllObjects];
    
    for (CAShapeLayer *line in lines){
      [line removeFromSuperlayer];
    }
    [lines removeAllObjects];
    
    [startPointTitle removeFromSuperview];
    [finishPointTitle removeFromSuperview];
    [_addPolyLineButton setSelected:NO];
    currentPath = nil;
    [currentLayer removeFromSuperlayer];
    currentLayer = nil;
    _polyLineLayout.hidden = YES;
    isDrawingPath = NO;
    isPositionChangedFromLastAdding = NO;
  }
}

- (void) startMeasuringButtonClicked: (UIButton *)button{
  _polyLineLayout.startMeasuringButton.hidden = YES;
  _polyLineLayout.checkPointButton.hidden = NO;
  _polyLineLayout.label.text = @"Measuring checkpoint 1";
  [_polyLineLayout.label sizeToFit];
  
  startPointTitle.backgroundColor = kColorFromHex(0x00A000);
  measuringCheckPointNumber = 0;
  MeasurePoint *point = points[measuringCheckPointNumber];
  [point changeColorTo:kColorFromHex(0x00A000)];
  
  logFileName = [_navigineManager startSaveLogToFile];
  
  CGPoint pointInMeters = CGPointMake(point.centerX * _navigineManager.DEFAULT_WIDTH/_contentView.width, point.centerY * _navigineManager.DEFAULT_HEIGHT/_contentView.height);
  NSString *checkPoint = [NSString stringWithFormat:@"%zd:%zd:%2.2f:%2.2f",measuringCheckPointNumber,sublocationId,pointInMeters.x,pointInMeters.y];
  [_navigineManager addCheckPointToLogFile:checkPoint];
  _polyLineTimer = [NSTimer scheduledTimerWithTimeInterval:1.
                                                    target:self
                                                  selector:@selector(polyLineTimerTick:)
                                                  userInfo:nil
                                                   repeats:YES];
  
}

- (void) checkPointButtonClicked: (UIButton *)button{
  CAShapeLayer *line = lines[measuringCheckPointNumber];
  line.strokeColor     = [kColorFromHex(0x00A000) CGColor];
  
  measuringCheckPointNumber++;
  MeasurePoint *point = points[measuringCheckPointNumber];
  [point changeColorTo:kColorFromHex(0x00A000)];
  
  CGPoint localPoint = CGPointMake(point.centerX/_contentView.width, point.centerY/_contentView.height);
  NSString *checkPoint = [NSString stringWithFormat:@"%zd:%zd:%2.2f:%2.2f",measuringCheckPointNumber,sublocationId,localPoint.x,localPoint.y];
  [_navigineManager addCheckPointToLogFile:checkPoint];
  
  timeFromStartMeasurement = 0;
  [_polyLineTimer invalidate];
  if (measuringCheckPointNumber < points.count - 1){
    _polyLineTimer = [NSTimer scheduledTimerWithTimeInterval:1.
                                                    target:self
                                                  selector:@selector(polyLineTimerTick:)
                                                  userInfo:nil
                                                   repeats:YES];
  }
  else{
    NSString *text = [NSString stringWithFormat:@"File saved: %@",[logFileName lastPathComponent]];
    _polyLineLayout.label.text = text;
    [_polyLineLayout.label sizeToFit];
    finishPointTitle.backgroundColor = kColorFromHex(0x00A000);
    measuringCheckPointNumber = 0;
    [_navigineManager stopSaveLogToFile];
    _polyLineLayout.addPointButton.hidden = YES;
    _polyLineLayout.finishButton.hidden = YES;
    _polyLineLayout.startMeasuringButton.hidden = YES;
    _polyLineLayout.checkPointButton.hidden = YES;
    _polyLineLayout.closeButton.hidden = NO;
  }
}

- (void) polyLineTimerTick: (NSTimer *)timer{
  timeFromStartMeasurement ++;
  NSString *text = [NSString stringWithFormat:@"Measuring checkpoint %zd: %zd secs",measuringCheckPointNumber+1,timeFromStartMeasurement];
  _polyLineLayout.label.text = text;
  [_polyLineLayout.label sizeToFit];
}

#pragma mark - NavigineManagerDelegate methods

- (void) didRangeBeacons:(NSArray *)beaconsDict{
  for(Beacon *beaconButton in beacons){
    [beaconButton updateBeaconWithoutDecibel];
  }
  for(NSDictionary *b in beaconsDict){
    NSNumber *major = b[@"major"];
    NSNumber *minor = b[@"minor"];
    NSString *uuid = b[@"uuid"];
    NSNumber *rssi = b[@"rssi"];
    NSNumber *proximity = b[@"proximity"];
    
    for(Beacon *beaconButton in beacons){
      if (beaconButton.beacon.major == major.intValue &&
          beaconButton.beacon.minor == minor.intValue &&
          [beaconButton.beacon.uuid isEqualToString: uuid]){
        [beaconButton updateBeaconWithDecibel:rssi.intValue];
        break;
      }
    }
  }
}

#pragma mark - UploaderHelperDelegate

- (void) successfullUploading:(LocationInfo *)location{
  [self showStatusBarMessage:@"  Uploading is complete" withColor:kColorFromHex(0x14263b) hideAfter:5];
  NSError *error = nil;
  [_loaderHelper selectLocation:location error:&error];
  [self addRightButton];
  self.navigineManager.modified = NO;
}

- (void) changeUploadingValue:(LocationInfo *)value{
  NSLog(@"%zd",value.loadingProcess);
}

- (void) errorWhileUploading:(NSInteger)error :(LocationInfo *)location{
  [self showStatusBarMessage:@"  Error while uploading" withColor:kColorFromHex(0xD36666) hideAfter:5];
  [self addRightButton];
}

#pragma mark - NavigineManagerMeasureBeaconDelegate

- (void) beaconFounded:(NCBeacon *)ncBeacon error:(NSError **)error{
  if(ncBeacon){
    beacon = [[Beacon alloc] initWithBeacon:ncBeacon];
    [beacon addTarget:self action:@selector(beaconClicked:) forControlEvents:UIControlEventTouchUpInside];
    beacon.center = CGPointMake(ncBeacon.kX * self.contentView.bounds.size.width, (1.f - ncBeacon.kY) * self.contentView.bounds.size.height);
    beacon.originalCenter = beacon.center;
    [beacon resizeBeaconWithZoom:_sv.zoomScale];
    [viewWithNoZoom addSubview:beacon];
    [beacons addObject:beacon];
    if(_showLabelsButton.isSelected)
      beacon.textImage.hidden = NO;
    else
      beacon.textImage.hidden = YES;
    self.navigineManager.modified = YES;
    [self.navigineManager saveBeaconsXML];
    viewWithNoZoom.frame = self.contentView.frame;
  }
  else{
    NSString *errorString = [(*error).userInfo objectForKey:NSLocalizedDescriptionKey];
    [self showStatusBarMessage:errorString withColor:kColorFromHex(0xD36666) hideAfter:5];
  }
  helpView.hidden = YES;
  [UIView animateWithDuration:0.5f animations:^{
    self.progressBar.bottom = -30.f;
  }];
  [processLayer removeFromSuperlayer];
  [progressLabel removeFromSuperview];
  measureBeaconTitle = [NSString string];
}

- (void) measuringBeaconWithProcess: (NSInteger) process{
  [processPath addLineToPoint:CGPointMake(320.f * process/100, 15.f)];
  progressLabel.text = [NSString stringWithFormat:@"%zd%%",process];
  processLayer.hidden = NO;
  processLayer.path = [processPath CGPath];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
  NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
  NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
  return [string isEqualToString:filtered];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}

@end