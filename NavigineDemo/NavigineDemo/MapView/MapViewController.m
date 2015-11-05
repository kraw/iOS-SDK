
//  MapView
//  NavigineDemo
//
//  Created by Administrator on 7/14/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"
#import "NavigineSDK.h"
#import "NavigineManager.h"

@interface MapViewController(){
  BOOL enableFollow;
  BOOL centerPosition;
  BOOL isRoutingNow;
  int sublocationId;
  NSInteger error4count;
  CGFloat zoomScale;
  
  MapPin *currentPin;//ввеньюс-кнопка, на который нажали
  NSMutableArray *pins;// массив с MapPin'ами
  
  UIView *routeErrorView;
  NSTimer *errorViewTimer;
  
  NSMutableArray *routeArray;
  CAShapeLayer   *routeLayer;
  UIBezierPath   *uipath;
  PressPin *pin; // то, что после лонг-тапа появляется
  
  PointOnMap rotatePoint;
  PointOnMap routePoint;
  
  UIView       *arrow;
  UIImageView    *current;
  
  NavigationResults res;
}
@property (nonatomic) DistanceType distanceType;
@property (nonatomic) RouteType routeType;

@property (nonatomic, strong) NCImage *image;
@property (nonatomic, strong) LoaderHelper *loaderHelper;
@property (nonatomic, strong) MapHelper *mapHelper;
@property (nonatomic, strong) NavigineManager *navigineManager;
@end

@implementation MapViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  self.view.backgroundColor = kColorFromHex(0xEAEAEA);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;

  self.sv.backgroundColor = kColorFromHex(0xEAEAEA);
  CustomTabBarViewController *slide = (CustomTabBarViewController *)self.tabBarController;
  slide.tabBar.hidden = YES;
  
  self.title = @"NAVIGATION MODE";
  
  [self addLeftButton];
  [self addRouteErrorViewWithTitle:@"It is impossible to build a route.      You are out of range of navigation"];
  
  self.navigineManager = [NavigineManager sharedManager];
  self.navigineManager.stepsDelegate = self;
  
  self.mapHelper = [MapHelper sharedInstance];
  self.mapHelper.delegate = self;
  self.mapHelper.venueDelegate = nil;
  
  self.rotateButton.hidden = NO;
  self.rotateButton.alpha = 1.f;
  self.rotateButton.layer.cornerRadius = self.rotateButton.height/2.f;
  self.rotateButton.transform = CGAffineTransformMakeRotation(M_PI/4.);
  
  self.zoomInBtn.layer.cornerRadius = self.zoomInBtn.height/2.f;
  self.zoomOutBtn.layer.cornerRadius = self.zoomOutBtn.height/2.f;
  
  self.btnDownFloor.transform = CGAffineTransformMakeRotation(M_PI);
  self.btnDownFloor.hidden = NO;
  
  self.btnUpFloor.hidden = NO;
  
  enableFollow = NO;
  centerPosition = NO;
  error4count = 0;
  zoomScale = 1.0f;
  pins = [[NSMutableArray alloc] init];
  
  [self.sv addSubview:self.contentView];
  current = [[UIImageView alloc] init];
  current.backgroundColor = kColorFromHex(0x4AADD4);

  current.alpha = 0.4;
  current.hidden = YES;
  [self.contentView addSubview:current];
  
  arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmUserCerlceArrow"]];
  [arrow sizeToFit];
  arrow.hidden = YES;
  current.frame = CGRectMake(0, 0, 36, 36);
  [self.contentView addSubview:arrow];
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
  longPress.minimumPressDuration = 1;
  longPress.delaysTouchesBegan   = NO;
  [_sv addGestureRecognizer:longPress];
  
  UIRotationGestureRecognizer *rotate=[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
  [self.contentView addGestureRecognizer:rotate];
  
  UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
  tapPress.delaysTouchesBegan   = NO;
  [_sv addGestureRecognizer:tapPress];
  
  self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void) rotation:(UIRotationGestureRecognizer *) sender{
  if (([sender state] == UIGestureRecognizerStateBegan ||
       [sender state] == UIGestureRecognizerStateChanged) &&
      !enableFollow) {
    [sender view].transform = CGAffineTransformRotate([[sender view] transform], [(UIRotationGestureRecognizer *)sender rotation]);
//    [(UIRotationGestureRecognizer *)sender setRotation:0];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  if (self.mapHelper.sublocId.count == 1){
    self.btnDownFloor.hidden = YES;
    self.btnUpFloor.hidden = YES;
    self.txtFloor.hidden = YES;
  }
  else{
    self.btnDownFloor.hidden = NO;
    self.btnUpFloor.hidden = NO;
    self.txtFloor.hidden = NO;
    self.btnDownFloor.alpha = 0.7f;
  }
  [super viewDidAppear:animated];
  if([self.mapHelper.venueDelegate respondsToSelector:@selector(routeToPlace)]) {
    if([[self.mapHelper.venueDelegate showType] isEqualToString:@"route"]) {
      Venue *v = [self.mapHelper.venueDelegate routeToPlace];
      CGFloat mapWidthInMeter = [self.navigineManager DEFAULT_WIDTH];
      
      CGFloat mapWidthInHeight = [self.navigineManager DEFAULT_HEIGHT];
      
      CGFloat xPoint =  v.kx.doubleValue * mapWidthInMeter;
      CGFloat yPoint =  v.ky.doubleValue * mapWidthInHeight;
      
      CGPoint point = CGPointMake(xPoint, yPoint);
      [self startRouteWithFinishPoint:point andRouteType:RouteTypeFromIcon];
    }
  }
  self.mapHelper.venueDelegate = nil;
}

- (void)selectPinWithVenue:(Venue *)v {
  for (MapPin *m in pins) {
    if(m.venue == v) {
      currentPin = m;
      [self zoomToPoint:currentPin.center withScale:1.0 animated:YES];
      [self showAnnotationForMapPin:currentPin];
    }
  }
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)movePositionWithZoom:(BOOL)isZoom {
  res = [self.navigineManager getNavigationResults];

  if((res.X == 0.0 && res.Y == 0.0) || res.ErrorCode != 0)  {
    
    if(res.ErrorCode == 4 && error4count < 10) {
      error4count++;
    }
    else {
      current.hidden = YES;
      arrow.hidden = YES;
      routeLayer.hidden = YES;
      return;
    }
  }
  if(res.ErrorCode == 0){
    error4count = 0;
    arrow.hidden = NO;
    current.hidden = NO;
  }
  
  self.naviginePedometer.text = [NSString stringWithFormat:@"Navigine:%zd length:%.3lf",res.outStepCounter,res.outStepLength];
  
  CGFloat mapWidthInMeter = [self.navigineManager DEFAULT_WIDTH];
  CGFloat mapOriginalWidth = (CGFloat)self.contentView.bounds.size.width;
  CGFloat poX = (CGFloat)res.X;
  
  CGFloat mapWidthInHeight = [self.navigineManager DEFAULT_HEIGHT];
  CGFloat mapOriginalHeight = (CGFloat)self.contentView.bounds.size.height;
  CGFloat poY = (CGFloat)res.Y;
  
  CGFloat xPoint =  (poX * mapOriginalWidth) / mapWidthInMeter;
  CGFloat yPoint =  mapOriginalHeight - poY * mapOriginalHeight / mapWidthInHeight;
  
  CGPoint point = CGPointMake(xPoint, yPoint);
  CGFloat xPixInMeter = (CGFloat)mapOriginalWidth/mapWidthInMeter;
  CGFloat yPixInMeter = (CGFloat)mapOriginalWidth/mapWidthInMeter;
  CGRect pointFrame = CGRectMake(0.0,0.0, 2.0f * xPixInMeter * res.R, 2.0f * yPixInMeter * res.R);
  
  [UIView animateWithDuration:1.0/10 animations:^{
    current.bounds = pointFrame;
    current.layer.cornerRadius = current.height/2.f;
    arrow.transform = CGAffineTransformMakeRotation((CGFloat)res.Yaw);
    current.center = point;
    arrow.center = point;
  }];
  
  current.hidden = NO;
  arrow.hidden = NO;
  
  if (sublocationId != res.outSubLocation){
    current.hidden = YES;
    arrow.hidden = YES;
    enableFollow = NO;
    centerPosition = NO;
  }
  else{
    current.hidden = NO;
    arrow.hidden = NO;
  }
  
  if(enableFollow ){
    
    CGSize zoomSize;
    zoomSize.width  = _sv.bounds.size.width;
    zoomSize.height = _sv.bounds.size.height;
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    
    CGRect zoomRect;
    zoomRect.origin.x    = (point.x*zoomScale - zoomSize.width / 2.0f);
    zoomRect.origin.y    = (point.y*zoomScale - zoomSize.height / 2.0f);
    zoomRect.size.width  = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
    
    _sv.contentOffset = CGPointMake(zoomRect.origin.x, zoomRect.origin.y);
    
    rotatePoint.x = point.x - self.contentView.bounds.size.width/2.0;
    rotatePoint.y = point.y - self.contentView.bounds.size.height/2.0;
    rotatePoint.sublocationId = sublocationId;
    CGPoint rPoint = CGPointMake(rotatePoint.x, rotatePoint.y);
    self.contentView.transform = CGAffineTransformMakeRotationAt(-res.Yaw, rPoint, zoomScale);
  }
  
  
  if(isZoom) {
    [self zoomToPoint:point withScale:1 animated:YES];
  }
  
  CGPoint rPoint = CGPointMake(routePoint.x, routePoint.y);
  if(!CGPointEqualToPoint(rPoint, CGPointZero)) {
    isRoutingNow = YES;
    [self drawRouteWithXml:[self.navigineManager makeRoute :res.outSubLocation :res.X :res.Y :routePoint.sublocationId :routePoint.x :routePoint.y]];
  }
  
}


CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt, CGFloat scale){
  const CGFloat fx = pt.x;
  const CGFloat fy = pt.y;
  const CGFloat fcos = cos(angle);
  const CGFloat fsin = sin(angle);
  return CGAffineTransformMake(fcos*scale, fsin*scale, -fsin*scale, fcos*scale, (fx - fx * fcos + fy * fsin)*scale, (fy - fx * fsin - fy * fcos)*scale);
}

-(void)drawRouteWithXml:(NSArray *)str {
  Vertex *vertex;// = [[Vertex alloc] init];
  
  routeArray = [[NSMutableArray alloc] init];
  [routeArray removeAllObjects];
  
  for(int i = 0; i< [str count]; i++){
    vertex = [str objectAtIndex:i];
    if(sublocationId == vertex.subLocation){
      CGPoint p = CGPointMake([vertex x], [vertex y]);
      [routeArray addObject:[NSValue valueWithCGPoint:p]];
    }
  }
  [self drawWayWithArray];
}

-(void)drawWayWithArray {
  if(routeArray.count == 0) return;
  
  [routeLayer removeFromSuperlayer];
  routeLayer = nil;
  
  [uipath removeAllPoints];
  uipath = nil;
  
  
  uipath     = [[UIBezierPath alloc] init];
  routeLayer = [CAShapeLayer layer];
  
  
  float distance = 0;
  CGPoint prevPoint = [[routeArray objectAtIndex:0] CGPointValue];
  
  for(int i = 0; i < routeArray.count; i++) {
    
    if(i == routeArray.count-1){
      
      CGPoint p = [[routeArray objectAtIndex:routeArray.count-1] CGPointValue];

      CGFloat mapWidthInMeter = [self.navigineManager DEFAULT_WIDTH];
      CGFloat mapOriginalWidth = (CGFloat)self.contentView.bounds.size.width;
      CGFloat poX = (CGFloat)p.x;
      
      
      CGFloat mapWidthInHeight = [self.navigineManager DEFAULT_HEIGHT];
      CGFloat mapOriginalHeight = (CGFloat)self.contentView.bounds.size.height;
      CGFloat poY = (CGFloat)p.y;
      
      CGFloat xPoint =  (poX * mapOriginalWidth) / mapWidthInMeter;
      CGFloat yPoint =  mapOriginalHeight - poY * mapOriginalHeight / mapWidthInHeight;
      
      CGPoint point = CGPointMake(xPoint, yPoint);
    }
    
    CGPoint p = [[routeArray objectAtIndex:i] CGPointValue];
    
    CGFloat mapWidthInMeter = [self.navigineManager DEFAULT_WIDTH];
    CGFloat mapOriginalWidth = (CGFloat)self.contentView.bounds.size.width;
    CGFloat poX = (CGFloat)p.x;
    
    
    CGFloat mapWidthInHeight = [self.navigineManager DEFAULT_HEIGHT];
    CGFloat mapOriginalHeight = (CGFloat)self.contentView.bounds.size.height;
    CGFloat poY = (CGFloat)p.y;
    
    CGFloat xPoint =  (poX * mapOriginalWidth) / mapWidthInMeter;
    CGFloat yPoint =  mapOriginalHeight - poY * mapOriginalHeight / mapWidthInHeight;
    
    if(i == 0) {
      [uipath moveToPoint:CGPointMake(xPoint, yPoint)];
    }
    else {
      [uipath addLineToPoint:CGPointMake(xPoint, yPoint)];
    }
    distance += sqrtf((p.x - prevPoint.x) * (p.x - prevPoint.x) + (p.y - prevPoint.y) * (p.y - prevPoint.y));
    prevPoint = p;
  }
  
  routeLayer.hidden = NO;
  routeLayer.path            = [uipath CGPath];
  routeLayer.strokeColor     = [kColorFromHex(0x4AADD4) CGColor];
  routeLayer.lineWidth       = 2.0;
  routeLayer.lineJoin        = kCALineJoinRound;
  routeLayer.fillColor       = [[UIColor clearColor] CGColor];
  
  //[_contentView.layer insertSublayer:routeLayer atIndex:0];
  [self.contentView.layer addSublayer:routeLayer];
  [self.contentView bringSubviewToFront:current];
  [self.contentView bringSubviewToFront:arrow];
  [self.contentView bringSubviewToFront:pin.unnotationView];
  
  if(distance <= 5 && distance >= 2) {
    [self stopRoute];
  }
}

- (void)addPinToMapWithVenue:(Venue *)v andImage:(UIImage *)image{
  CGFloat mapWidthInMeter = [self.navigineManager DEFAULT_WIDTH];
  CGFloat mapOriginalWidth = (CGFloat)self.contentView.bounds.size.width;
  
  CGFloat mapWidthInHeight = [self.navigineManager DEFAULT_HEIGHT];
  CGFloat mapOriginalHeight = (CGFloat)self.contentView.bounds.size.height;
  
  CGFloat xPoint =  v.kx.doubleValue * mapOriginalWidth;
  CGFloat yPoint =  mapOriginalHeight - v.ky.doubleValue * mapOriginalHeight;
  
  CGPoint point = CGPointMake(xPoint, yPoint);
  
  MapPin *btnPin = [[MapPin alloc] initWithVenue:v];
  [btnPin setImage:image forState:UIControlStateNormal];
  [btnPin setImage:image forState:UIControlStateHighlighted];
  [btnPin addTarget:self action:@selector(btnPinPressed:) forControlEvents:UIControlEventTouchUpInside];
  [btnPin sizeToFit];
  btnPin.bottom  = point.y;
  btnPin.centerX = point.x;
  [self.contentView addSubview:btnPin];
  [pins addObject:btnPin];
}

- (IBAction)btnPinPressed:(id)sender {
  currentPin = (MapPin *)sender;
  if(!currentPin.mapView.hidden){
    [currentPin.mapView removeFromSuperview];
    currentPin.mapView.hidden = YES;
  }
  else{
    for(MapPin *mapPin in pins){
      [mapPin.mapView removeFromSuperview];
      mapPin.mapView.hidden = YES;
    }
    
    currentPin.mapView.hidden = NO;
    [self zoomToPoint:currentPin.center withScale:1.0 animated:YES];
    [self showAnnotationForMapPin:currentPin];
  }
}

- (void)showAnnotationForMapPin:(MapPin *)mappin {
  [self.contentView addSubview:mappin.mapView];
  [mappin.btnVenue addTarget:self action:@selector(btnVenue:) forControlEvents:UIControlEventTouchUpInside];
  mappin.mapView.bottom = 0.f;
  mappin.mapView.centerX  = mappin.centerX;
  mappin.mapView.alpha = 0.f;
  //Animate drop
  [UIView animateWithDuration:0.2 delay:0 options: UIViewAnimationOptionCurveLinear animations:^{
    mappin.mapView.bottom   = mappin.top - 9.0f;
    mappin.mapView.alpha = 1.f;
  } completion:^(BOOL finished){
  }];
  mappin.mapView.bottom   = mappin.top - 9.0f;
  
}

- (IBAction)btnVenue:(id)sender {
  [self performSegueWithIdentifier:@"placeSegue" sender:sender];
  [self deselectPins];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier hasPrefix:@"placeSegue"]) {
    PlaceView *pw = (PlaceView *)segue.destinationViewController;
    pw.venues = currentPin.venue;
    pw.navigationController.navigationBarHidden = YES;
  }
}

- (IBAction)backRoutePressed:(id)sender {
  [self.navigationController setNavigationBarHidden:NO animated:YES];
  
  _routeType = RouteTypeNone;
  self.sv.origin = CGPointZero;
  [self stopRoute];
}

- (void)deselectPins {
  if(pin && !isRoutingNow){
    [pin removeFromSuperview];
    [pin.unnotationView removeFromSuperview];
  }
  for(MapPin *mapPin in pins){
    [mapPin.mapView removeFromSuperview];
    mapPin.mapView.hidden = YES;
  }
}

- (void)tapPress:(UITapGestureRecognizer *)gesture {
  [self deselectPins];
}

- (void)startRouteWithFinishPoint:(CGPoint)point andRouteType:(RouteType)type {
  if(![self.navigineManager isNavigineFine]) {
    [self addRouteErrorViewWithTitle:@"It is impossible to build a route.      You are out of range of navigation"];
    routeErrorView.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:5.f
                                     target:self
                                   selector:@selector(dismissRouteErrorView:)
                                   userInfo:nil
                                    repeats:NO];
    
    if(pin && type == RouteTypeFromClick) {
      [pin removeFromSuperview];
      [pin.unnotationView removeFromSuperview];
    }
    return;
  }
  
  _routeType = type;
  
  if(isRoutingNow) {
    [self stopRoute];
  }
  
  routePoint.x = point.x;
  routePoint.y = point.y;
  routePoint.sublocationId = sublocationId;

  isRoutingNow = YES;
}

- (void) dismissRouteErrorView :(NSTimer *)timer{
  routeErrorView.hidden = YES;
  [timer invalidate];
}

- (void)stopRoute {
  if(pin && (_routeType != RouteTypeFromClick || _routeType == RouteTypeNone)) {
    [pin removeFromSuperview];
    [pin.unnotationView removeFromSuperview];
  }
  
  isRoutingNow = NO;
  routePoint.x = 0;
  routePoint.y = 0;
  routePoint.sublocationId = -1;
  
  [routeLayer removeFromSuperlayer];
  routeLayer = nil;
  
  [uipath removeAllPoints];
  uipath = nil;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.contentView;
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
  if(centerPosition == YES && enableFollow == NO)
    centerPosition = NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  [self centerScrollViewContents];
  if(enableFollow == YES) self.contentView.origin = CGPointMake(0.f, 0.f);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
  [self movePositionWithZoom:NO];
}

- (IBAction)currentLocationPressed:(id)sender {
  [self movePositionWithZoom:YES];
}

- (void)addLeftButton {
  UIImage *buttonImage = [UIImage imageNamed:@"btnMenu"];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  [leftButton addTarget:self action:@selector(menuPressed:)  forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
  
}

- (IBAction)zoomButton:(id)sender {
  UIButton *btn = (UIButton *)sender;
  
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
  } completion:^(BOOL finished) {
    
  }];
}

-(void) addRouteErrorViewWithTitle: (NSString *)title{
  [routeErrorView removeFromSuperview];
  routeErrorView.hidden = YES;
  routeErrorView = nil;
  [errorViewTimer invalidate];
  errorViewTimer = nil;
  
  routeErrorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 87)];
  routeErrorView.backgroundColor = kColorFromHex(0xD36666);
  routeErrorView.alpha = 0.9f;
  
  NSString *labelText = title;
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineSpacing = 9.f;
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, 40)];
  
  UILabel *unavaliableRoute = [[UILabel alloc] initWithFrame:CGRectMake(33.f, 22.f, 253.f, 42.f)];
  unavaliableRoute.attributedText = attributedString;
  unavaliableRoute.textColor = kColorFromHex(0xFAFAFA);
  unavaliableRoute.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  unavaliableRoute.textAlignment = NSTextAlignmentCenter;
  unavaliableRoute.numberOfLines = 0;
  [routeErrorView addSubview:unavaliableRoute];
  [self.view addSubview:routeErrorView];
  routeErrorView.hidden = YES;
}

- (IBAction)zoomButtonOut:(id)sender {
  UIButton *btn = (UIButton *)sender;
  
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    btn.transform = CGAffineTransformMakeScale(1.0, 1.0);
  } completion:^(BOOL finished) {
    
  }];
  
  if(sender == _zoomInBtn) {
    [_sv setZoomScale:_sv.zoomScale + 0.2f animated:YES];
  }
  else {
    [_sv setZoomScale:_sv.zoomScale - 0.2f animated:YES];
  }
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
  
  //apply the resize
  
//  zoomSize.width  = _sv.bounds.size.width;
//  zoomSize.height = _sv.bounds.size.height;
//  //offset the zoom rect so the actual zoom point is in the middle of the rectangle
//  
//  zoomRect.origin.x    = (zoomPoint.x*zoomScale - self.view.width / 2.0f);
//  zoomRect.origin.y    = (zoomPoint.y*zoomScale - self.view.height / 2.0f);
//  zoomRect.size.width  = zoomSize.width;
//  zoomRect.size.height = zoomSize.height;
  
//  _sv.contentOffset = CGPointMake(zoomRect.origin.x, zoomRect.origin.y);
  
  [_sv zoomToRect:zoomRect animated: YES];
  
}

- (void)zoomToPoint:(CGPoint)zoomPoint animated: (BOOL)animated{
  //Normalize current content size back to content scale of 1.0f
  CGSize contentSize;
  contentSize.width  = (_sv.contentSize.width / _sv.zoomScale);
  contentSize.height = (_sv.contentSize.height / _sv.zoomScale);
  
  
  CGFloat mapWidthInMeter = [self.navigineManager DEFAULT_WIDTH];
  CGFloat mapOriginalWidth = (CGFloat)self.contentView.bounds.size.width;
  CGFloat poX = (CGFloat)res.X;
  
  CGFloat mapWidthInHeight = [self.navigineManager DEFAULT_HEIGHT];
  CGFloat mapOriginalHeight = (CGFloat)self.contentView.bounds.size.height;
  CGFloat poY = (CGFloat)res.Y;
  
  CGFloat xPoint =  (poX * mapOriginalWidth) / mapWidthInMeter;
  CGFloat yPoint =  mapOriginalHeight - poY * mapOriginalHeight / mapWidthInHeight;
  //translate the zoom point to relative to the content rect
  //  zoomPoint.x = (zoomPoint.x / _sv.bounds.size.width) * contentSize.width;
  //  zoomPoint.y = (zoomPoint.y / _sv.bounds.size.height) * contentSize.height;
  
  //derive the size of the region to zoom to
  CGSize zoomSize;
  zoomSize.width  = _sv.bounds.size.width;
  zoomSize.height = _sv.bounds.size.height;
  
  //offset the zoom rect so the actual zoom point is in the middle of the rectangle
  CGRect zoomRect;
  zoomRect.origin.x    = xPoint - zoomSize.width / 2.0f;
  zoomRect.origin.y    = yPoint - zoomSize.height / 2.0f;
  zoomRect.size.width  = zoomSize.width;
  zoomRect.size.height = zoomSize.height;
  
  //apply the resize
  
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
}

- (void)longPress:(UIGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateBegan) {
    CGPoint translatedPoint = [(UIGestureRecognizer*)gesture locationInView:self.contentView];
    
    if(pin) {
      [self stopRoute];
      pin = nil;
    }
    
    pin = [[PressPin alloc] initWithFrame:CGRectZero];
    [pin addTarget:self action:@selector(btnRoutePin:) forControlEvents:UIControlEventTouchUpInside];
    [pin sizeToFit];
    pin.center = CGPointMake(translatedPoint.x, 0);
    
    pin.bottom = translatedPoint.y;
    pin.centerX = translatedPoint.x;
    pin.hidden = NO;
    [self.contentView addSubview:pin];
    
    [pin.btn addTarget:self action:@selector(btnRoute:) forControlEvents:UIControlEventTouchUpInside];
 
    pin.unnotationView.bottom   = pin.top - 10;
    pin.unnotationView.centerX  = pin.centerX;
    
    [self.contentView addSubview:pin.unnotationView];
  }
}

- (IBAction) btnRoute:(id)sender{
  UIButton *btn = (UIButton *)sender;
  UIImageView *pipka = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmBubbleArrowBlue"]];
  
  CGPoint point = CGPointMake(pin.unnotationView.centerX, pin.unnotationView.bottom + pipka.height + pin.height);
  
  CGFloat mapWidthInMeter  = [self.navigineManager DEFAULT_WIDTH];
  CGFloat mapOriginalWidth = (CGFloat)self.contentView.bounds.size.width;
  
  CGFloat mapWidthInHeight  = [self.navigineManager DEFAULT_HEIGHT];
  CGFloat mapOriginalHeight = (CGFloat)self.contentView.bounds.size.height;
  
  CGFloat xPoint = (point.x / mapOriginalWidth) * mapWidthInMeter;
  CGFloat yPoint = (mapOriginalHeight - point.y) /  mapOriginalHeight * mapWidthInHeight;
  point = CGPointMake(xPoint , yPoint);
  
  [self startRouteWithFinishPoint:point andRouteType:RouteTypeFromClick];
  [pin.unnotationView removeFromSuperview];
}

- (IBAction)btnRoutePin:(id)sender{
  if(!isRoutingNow) return;
  [pin swithPinMode];
  [pin.btn addTarget:self action:@selector(btnCancelRoute:) forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:pin.unnotationView];
}

-(IBAction)btnCancelRoute:(id)sender{
  [self stopRoute];
  if(pin){
    [pin removeFromSuperview];
    [pin.unnotationView removeFromSuperview];
  }
}

-(void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];

}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  self.mapHelper = [MapHelper sharedInstance];
  self.mapHelper.delegate = self;
  _sv.minimumZoomScale = 1.f;
  _sv.maximumZoomScale = 5.0f;
  _sv.zoomScale = 1.0f;
  zoomScale = 1.0f;
  [self changeFloorTo:self.mapHelper.floor];
}

- (IBAction)menuPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
    [self.slidingPanelController closePanel];
  }
  else {
    [self.slidingPanelController openLeftPanel];
  }
}

- (IBAction)zoomInTouch:(id)sender {
  [_sv setZoomScale:zoomScale + 0.2f animated:NO];
  zoomScale = _sv.zoomScale;
  [self movePositionWithZoom:NO];
}

- (IBAction)zoomOutTouch:(id)sender {
  [_sv setZoomScale:zoomScale - 0.2f animated:NO];
  zoomScale = _sv.zoomScale;
  [self movePositionWithZoom:NO];
}

- (IBAction)upFloor:(id)sender {
  self.btnDownFloor.alpha = 1.f;
  
  if(self.mapHelper.floor != self.mapHelper.sublocId.count - 1){
    self.mapHelper.floor++;
    [self changeFloorTo:self.mapHelper.floor];
  }
  
  if(self.mapHelper.floor == self.mapHelper.sublocId.count - 1){
    self.btnUpFloor.alpha = 0.7f;
  }
}

- (IBAction)downFloor:(id)sender {
  if(self.mapHelper.floor == 0){
    return;
  }
  self.mapHelper.floor--;
  self.btnUpFloor.alpha = 1.f;
  [self changeFloorTo:self.mapHelper.floor];
  if(self.mapHelper.floor == 0){
    self.btnDownFloor.alpha = 0.7f;
  }
}

- (void) changeFloorTo:(NSInteger)row{
  if(self.mapHelper.floor == 0){
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
  for(UIImageView *p in pins) [p removeFromSuperview];
  
  [self.contentView addSubview:current];
  [self.contentView addSubview:arrow];
  
  [_sv setZoomScale:zoomScale animated:YES];
  for (Venue *v in [self.navigineManager venues]) {
    if(v.sublocationId == sublocationId){
      [self addPinToMapWithVenue:v  andImage:[UIImage imageNamed:@"elmVenueIcon"]];
    }
  }
  
  [self.sv addSubview:self.contentView];
  self.contentView.hidden = NO;
  if (enableFollow){
    [_rotateButton setImage:[UIImage imageNamed:@"btnDynamicMap"] forState:UIControlStateNormal];
    enableFollow = NO;
    _sv.scrollEnabled = YES;
    CGPoint point = CGPointMake(rotatePoint.x, rotatePoint.y);
    self.contentView.transform = CGAffineTransformMakeRotationAt(0.0, point,zoomScale);
  }
  self.txtFloor.text = [NSString stringWithFormat:@"%zd", self.mapHelper.floor];
  [self centerScrollViewContents];
}

- (IBAction)folowing:(id)sender {
  if(centerPosition == NO){
    if(res.ErrorCode){
      [self addRouteErrorViewWithTitle:@"I can't detect your position.              You are out of range of navigation"];
      routeErrorView.hidden = NO;
      [errorViewTimer invalidate];
      errorViewTimer = [NSTimer scheduledTimerWithTimeInterval:5.f
                                       target:self
                                     selector:@selector(dismissRouteErrorView:)
                                     userInfo:nil
                                      repeats:NO];
    }
    else{
      centerPosition = YES;
      if (sublocationId != res.outSubLocation){
        NSUInteger floor = [self.mapHelper.sublocId indexOfObject:[NSNumber numberWithInteger:res.outSubLocation]];
        self.btnUpFloor.alpha = 1.f;
        self.btnDownFloor.alpha = 1.f;
        if(floor == 0)
          self.btnDownFloor.alpha = 0.7f;
        if(floor == self.mapHelper.sublocId.count - 1)
          self.btnUpFloor.alpha = 0.7f;
        self.mapHelper.floor = floor;
        [self changeFloorTo:floor];
      }
      CGPoint pointOfZoom = CGPointMake(res.X, res.Y);
      [self zoomToPoint:pointOfZoom animated:YES];
    }
  }
  else{
    if (enableFollow){
      [errorViewTimer invalidate];
      [_rotateButton setImage:[UIImage imageNamed:@"btnDynamicMap"] forState:UIControlStateNormal];
      self.rotateButton.transform = CGAffineTransformMakeRotation(M_PI/4.);
      enableFollow = NO;
      centerPosition = NO;
      _sv.scrollEnabled = YES;
      CGPoint point = CGPointMake(rotatePoint.x, rotatePoint.y);
      self.contentView.transform = CGAffineTransformMakeRotationAt(0.0, point,zoomScale);
      zoomScale = _sv.zoomScale;
      self.sv.pinchGestureRecognizer.enabled = YES;
      [self.sv setZoomScale:zoomScale - 0.0001f];
    }
    else{
      if(res.ErrorCode){
        [self addRouteErrorViewWithTitle:@"I can't detect your position.              You are out of range of navigation"];
        routeErrorView.hidden = NO;
        errorViewTimer = [NSTimer scheduledTimerWithTimeInterval:5.f
                                         target:self
                                       selector:@selector(dismissRouteErrorView:)
                                       userInfo:nil
                                        repeats:NO];
      }
      else{
        [errorViewTimer invalidate];
        routeErrorView = nil;
        [_rotateButton setImage:[UIImage imageNamed:@"btnDynamicMap"] forState:UIControlStateNormal];
        self.rotateButton.transform = CGAffineTransformMakeRotation(0.f);
        enableFollow = YES;
        _sv.scrollEnabled = NO;
        zoomScale = _sv.zoomScale;
        self.sv.pinchGestureRecognizer.enabled = NO;
        [self.sv setZoomScale:zoomScale + 0.0001f];
      
      }
    }
  }
}

#pragma mark - MapHelperDelegate

- (void) startNavigation{
  if (self.mapHelper.sublocId.count == 1){
    self.btnDownFloor.hidden = YES;
    self.btnUpFloor.hidden = YES;
    self.txtFloor.hidden = YES;
  }
  else{
    self.btnDownFloor.alpha = 0.7f;
  }
}

- (void) stopNavigation{
  current.hidden = YES;
  enableFollow = NO;
}

- (void) changeCoordinates{
  [self movePositionWithZoom:NO];
}

#pragma mark - NavigineManagerStepsDelegate

-(void) updateSteps:(NSNumber *)numberOfSteps with:(NSNumber *)distance{
  NSString *text = [NSString stringWithFormat:@"iOS:%@ distance:%.2lf",numberOfSteps, [distance floatValue]];
  self.iOSPedometer.text = text;
}

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %lf;",self.image.scale];
  [webView stringByEvaluatingJavaScriptFromString:jsCommand];
//  [self.sv addSubview:contentView];
}

@end
