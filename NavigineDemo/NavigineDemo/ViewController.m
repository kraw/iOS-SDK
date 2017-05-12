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
@property (nonatomic, strong) NavigineCore *navigineCore;
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
    _navigineCore = [[NavigineCore alloc] initWithUserHash:@"0000-0000-0000-0000"
                                                    server:@"https://api.navigine.com"];
    _navigineCore.delegate = self;
    
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
    
    
    [_navigineCore downloadLocationById:1571
                            forceReload:true
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
    NCDeviceInfo *res = _navigineCore.deviceInfo;
    if (res.error.code == 0){
        NSLog(@"RESULT: %lf %lf", res.x, res.y);
        _current.center = CGPointMake(_imageView.width / _sv.zoomScale * res.kx,
                                      _imageView.height / _sv.zoomScale * (1. - res.ky));
    }
    else{
        NSLog(@"Error code:%zd",res.error.code);
    }
    if (_isRouting){
        NCDevicePath *devicePath = res.paths.firstObject;
        NSArray *path = devicePath.path;
        float distance = devicePath.lenght;
        [self drawRouteWithPath:path andDistance:distance];
    }
}

-(void) drawRouteWithPath: (NSArray *)path
              andDistance: (float)distance {
//    // We check that we are close to the finish point of the route
    if (distance <= 3.){
//        [self stopRoute];
    }
    else{
        [routeLayer removeFromSuperlayer];
        [uipath removeAllPoints];

        uipath     = [[UIBezierPath alloc] init];
        routeLayer = [CAShapeLayer layer];
        
        for (int i = 0; i < path.count; i++ ){
            NCVertex *vertex = path[i];
            NCSublocation *sublocation = _navigineCore.location.sublocations[0];
            CGSize imageSizeInMeters = CGSizeMake(sublocation.width, sublocation.height);
            
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
//    NavigationResults res = [_navigineCore getNavigationResults];
    NCDeviceInfo *res = _navigineCore.deviceInfo;
    NCSublocation *sublocation = _navigineCore.location.sublocations[0];
    CGSize imageSizeInMeters = CGSizeMake(sublocation.width, sublocation.height);
    CGFloat xPoint = _pressedPin.centerX /_imageView.width * imageSizeInMeters.width;
    CGFloat yPoint = (1. - _pressedPin.centerY /_imageView.height) * imageSizeInMeters.height;
    NCVertex *vertex = [[NCVertex alloc] init];
    vertex.sublocationId = res.subLocation;
    vertex.x = @(xPoint);
    vertex.y = @(yPoint);
    [_navigineCore addTatget:vertex];
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
        [self addPinToMapWithVenue:v andImage:[UIImage imageNamed:@"elmVenueIcon"]];
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
    [_navigineCore startNavigine];
    [_navigineCore startPushManager];
    [_navigineCore startVenueManager];
    
    NCLocation *location = _navigineCore.location;
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
