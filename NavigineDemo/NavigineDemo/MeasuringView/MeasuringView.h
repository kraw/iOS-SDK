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
#import "CustomTabBarViewController.h"
#import "CustomIOSAlertView.h"
#import "MapHelper.h"
#import "UploaderHelper.h"
#import "LoaderHelper.h"
#import "Beacon.h"
#import "ErrorView.h"
#import "PolyLineLayout.h"
#import "MeasurePoint.h"


@interface MeasuringView : UIViewController <UIScrollViewDelegate, UIWebViewDelegate, MapHelperDelegate, UIGestureRecognizerDelegate,UIAlertViewDelegate,NavigineManagerMeasureBeaconDelegate,UploaderHelperDelegate, CustomIOSAlertViewDelegate, UITextFieldDelegate,NavigineManagerDelegate>

//@property (nonatomic, weak) NSObject <LoaderHelperDelegate> *loaderHelperDelegate;

@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UIButton *zoomInBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnDownFloor;
@property (weak, nonatomic) IBOutlet UIButton *btnUpFloor;
@property (weak, nonatomic) IBOutlet UILabel *txtFloor;
@property (weak, nonatomic) IBOutlet UIWebView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *showLabelsButton;
@property (weak, nonatomic) IBOutlet UIView *viewAddBeacon;
@property (weak, nonatomic) IBOutlet UIButton *addPolyLineButton;


- (IBAction)startMeasurePolyLine:(id)sender;
- (IBAction)startMeasureBeacon:(id)sender;
- (IBAction)showLabels:(id)sender;

- (IBAction)zoomInTouch:(id)sender;
- (IBAction)zoomOutTouch:(id)sender;
- (IBAction)upFloor:(id)sender;
- (IBAction)downFloor:(id)sender;

@end
