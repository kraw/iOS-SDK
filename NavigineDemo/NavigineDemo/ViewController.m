//
//  ViewController.m
//  NavigineDemo
//
//  Created by Администратор on 29/08/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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
    
    // Point on map
    _current = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _current.backgroundColor = [UIColor redColor];
    _current.layer.cornerRadius = _current.frame.size.height/2.f;
    [_imageView addSubview:_current];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(navigationTick:)
                                   userInfo:nil
                                    repeats:YES];
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
        _current.center = CGPointMake(_imageView.frame.size.width*res.kX,
                                      _imageView.frame.size.height*(1. - res.kY));
    }
    else{
        NSLog(@"Error code:%zd",res.ErrorCode);
    }
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
    // Your code
}

@end
