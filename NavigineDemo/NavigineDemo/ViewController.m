//
//  ViewController.m
//  NavigineDemo
//
//  Created by Администратор on 29/08/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "ViewController.h"


@interface ViewController (){
    UIBezierPath   *uipath;
    CAShapeLayer   *routeLayer;
}
@property (nonatomic, strong) MapPin *pressedPin;
@property (nonatomic, assign) BOOL isRouting;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sv.frame = self.view.frame;
    _sv.delegate = self;
    _sv.pinchGestureRecognizer.enabled = YES;
    _sv.minimumZoomScale = 1.f;
    _sv.zoomScale = 1.f;
    _sv.maximumZoomScale = 2.f;
    [_sv addSubview:_imageView];
    [NavigineCore defaultCore].userHash = @"628B-9792-0789-C136";
    [NavigineCore defaultCore].delegate = self;
    
    // Point on map
    _current = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _current.backgroundColor = [UIColor redColor];
    _current.layer.cornerRadius = _current.frame.size.height/2.f;
    [_imageView addSubview:_current];
    _imageView.userInteractionEnabled = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(navigationTick:)
                                   userInfo:nil
                                    repeats:YES];
    _isRouting = NO;
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    tapPress.delaysTouchesBegan   = NO;
    [_sv addGestureRecognizer:tapPress];
    
    [[NavigineCore defaultCore] downloadLocationByName:@"Navigine_Proletarsakya"
                                           forceReload:NO
                                          processBlock:^(NSInteger loadProcess) {
                                              NSLog(@"%zd",loadProcess);
                                          } successBlock:^(NSDictionary *userInfo) {
                                              [self setupNavigine];
                                          } failBlock:^(NSError *error) {
                                              NSLog(@"%@",error);
                                          }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) navigationTick: (NSTimer *)timer{
    NavigationResults res = [[NavigineCore defaultCore] getNavigationResults];
    if (res.ErrorCode == 0){
        NSLog(@"RESULT: %lf %lf",res.X,res.Y);
        _current.center = CGPointMake(_imageView.width / _sv.zoomScale * res.kX,
                                      _imageView.height / _sv.zoomScale * (1. - res.kY));
    }
    else{
        NSLog(@"Error code:%zd",res.ErrorCode);
    }
    if (_isRouting){
        
        NSArray *path = [[NavigineCore defaultCore] routePaths].firstObject;
        NSNumber *distance = [[NavigineCore defaultCore] routeDistances].firstObject;
        [self drawRouteWithPath:path andDistance:distance];
    }
}

-(void) drawRouteWithPath: (NSArray *)path
              andDistance: (NSNumber *)distance {
//    // We check that we are close to the finish point of the route
    if (distance.doubleValue <= 3.){
//        [self stopRoute];
    }
    else{
        [routeLayer removeFromSuperlayer];
        [uipath removeAllPoints];

        uipath     = [[UIBezierPath alloc] init];
        routeLayer = [CAShapeLayer layer];
        
        for (int i = 0; i < path.count; i++ ){
            NCVertex *vertex = path[i];
            CGSize imageSizeInMeters = [[NavigineCore defaultCore] sizeForImageAtIndex:0 error:nil];
            
            CGFloat xPoint =  (vertex.x.doubleValue / imageSizeInMeters.width) * (_imageView.width / _sv.zoomScale);
            CGFloat yPoint =  (1. - vertex.y.doubleValue / imageSizeInMeters.height)  * (_imageView.height / _sv.zoomScale);
            if(i == 0) {
                [uipath moveToPoint:CGPointMake(xPoint, yPoint)];
            }
            else {
                [uipath addLineToPoint:CGPointMake(xPoint, yPoint)];
            }
        }
    }
    routeLayer.hidden = NO;
    routeLayer.path            = [uipath CGPath];
    routeLayer.strokeColor     = [kColorFromHex(0x4AADD4) CGColor];
    routeLayer.lineWidth       = 2.0;
    routeLayer.lineJoin        = kCALineJoinRound;
    routeLayer.fillColor       = [[UIColor clearColor] CGColor];
    
    [_imageView.layer addSublayer:routeLayer];
    [_imageView bringSubviewToFront:_current];
}

- (void)addPinToMapWithVenue:(NCVenue *)v andImage:(UIImage *)image{
    CGFloat xPoint = v.kX.doubleValue * _imageView.width;
    CGFloat yPoint = (1. - v.kY.doubleValue) * _imageView.height;
    
    CGPoint point = CGPointMake(xPoint, yPoint);
    MapPin *mapPin = [[MapPin alloc] initWithVenue:v];
    [mapPin setImage:image forState:UIControlStateNormal];
    [mapPin setImage:image forState:UIControlStateHighlighted];
    [mapPin addTarget:self action:@selector(mapPinPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mapPin sizeToFit];
    [_imageView addSubview:mapPin];
    [_sv bringSubviewToFront:mapPin];
    
    mapPin.center  = point;
}

- (void)mapPinPressed:(id)sender {
    MapPin *mapPin = (MapPin *)sender;
    [_pressedPin.popUp removeFromSuperview];
    _pressedPin.popUp.hidden = YES;
    
    _pressedPin = mapPin;
    [_imageView addSubview:mapPin.popUp];
    mapPin.popUp.hidden = NO;
    
    mapPin.popUp.bottom   = mapPin.top - 9.0f;
    mapPin.popUp.centerX  = mapPin.centerX;
    
    [mapPin.popUp addTarget:self action:@selector(popUpPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)popUpPressed:(id)sender {
    NavigationResults res = [[NavigineCore defaultCore] getNavigationResults];
    CGSize imageSizeInMeters = [[NavigineCore defaultCore] sizeForImageAtIndex:0 error:nil];
    CGFloat xPoint = _pressedPin.centerX /_imageView.width * imageSizeInMeters.width;
    CGFloat yPoint = (1. - _pressedPin.centerY /_imageView.height) * imageSizeInMeters.height;
    NCVertex *vertex = [[NCVertex alloc] init];
    vertex.sublocationId = res.outSubLocation;
    vertex.x = @(xPoint);
    vertex.y = @(yPoint);
    [[NavigineCore defaultCore] addTatget:vertex];
    [_pressedPin.popUp removeFromSuperview];
    _pressedPin.popUp.hidden = YES;
    _isRouting = YES;
}

- (void)stopRoute {
    _isRouting = NO;
    
    [routeLayer removeFromSuperlayer];
    routeLayer = nil;
    
    [uipath removeAllPoints];
    uipath = nil;
//    [[NavigineCore defaultCore] cancelTargets];
}

- (void)tapPress:(UITapGestureRecognizer *)gesture {
    [_pressedPin.popUp removeFromSuperview];
    _pressedPin.popUp.hidden = YES;
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

#pragma mark NavigineCoreDelegate methods

- (void) didRangePushWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(NSString *)image
                            id:(NSInteger)id{
    // Your code
}

- (void) didRangeVenues:(NSArray *)venues :(NSArray *)categories{
    for (NCVenue *v in venues) {
        [self addPinToMapWithVenue:v  andImage:[UIImage imageNamed:@"elmVenueIcon"]];
    }
}

- (IBAction)startPressed:(id)sender {
//    [[NavigineCore defaultCore] loadArchive:@"Navigine_Proletarsakya" error:nil];
//    [[NavigineCore defaultCore] startNavigine];
}

- (IBAction)stopPressed:(id)sender {
//    [[NavigineCore defaultCore] stopNavigine];
}


-(void) setupNavigine{
    [[NavigineCore defaultCore] startNavigine];
    [[NavigineCore defaultCore] startPushManager];
    [[NavigineCore defaultCore] startVenueManager];
    
    NCLocation *location = [NavigineCore defaultCore].location;
    NCSublocation *sublocation = [location subLocationAtIndex:0];

    NSData *imageData = sublocation.pngImage;
    UIImage *image = [UIImage imageWithData:imageData];
    
    float scale = 1.f;
    if (image.size.width / image.size.height >
        self.view.frame.size.width / self.view.frame.size.height){
        scale = self.view.frame.size.height / image.size.height;
    }
    else{
        scale = self.view.frame.size.width / image.size.width;
    }
    _imageView.frame = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
    _imageView.image = image;
    _sv.contentSize = _imageView.frame.size;
}
@end
