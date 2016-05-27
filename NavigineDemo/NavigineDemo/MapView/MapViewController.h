//
//  MapView.h
//  NavigineDemo
//
//  Created by Administrator on 7/14/14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineManager.h"
#import <UIKit/UIGestureRecognizer.h>
#import "PlaceView.h"
#import "CustomTabBarViewController.h"
#import "MapHelper.h"
#import "DebugHelper.h"
#import "MapPin.h"
#import "PressPin.h"
#import "PositionOnMap.h"
#import "ErrorView.h"

typedef enum {
  DistanceInMinutes = 0,
  DistanceInMeters
} DistanceType;


typedef enum {
  RouteTypeNone = 0,
  RouteTypeFromClick
} RouteType;


@interface MapViewController : UIViewController <UIScrollViewDelegate, MapHelperDelegate, NavigineManagerStepsDelegate, UIGestureRecognizerDelegate>{
}

@property (nonatomic, weak) NSObject <LoaderHelperDelegate> *loaderHelperDelegate;

@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UIButton *rotateButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomInBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnDownFloor;
@property (weak, nonatomic) IBOutlet UIButton *btnUpFloor;
@property (weak, nonatomic) IBOutlet UILabel *txtFloor;
@property (weak, nonatomic) IBOutlet UILabel *iOSPedometer;
@property (weak, nonatomic) IBOutlet UILabel *naviginePedometer;
@property (weak, nonatomic) IBOutlet UIWebView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *rotateView;
@property (weak, nonatomic) IBOutlet UIImageView *progressBar;


- (IBAction)zoomInTouch:(id)sender;
- (IBAction)zoomOutTouch:(id)sender;
- (IBAction)upFloor:(id)sender;
- (IBAction)downFloor:(id)sender;

@end
