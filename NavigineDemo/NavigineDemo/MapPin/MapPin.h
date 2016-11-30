//
//  MapPin.h
//  SVO
//
//  Created by Valentine on 30.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineSDK.h"

@interface MapPin : UIButton
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, strong) UIView *mapView;

@property (nonatomic, assign) CGPoint mapViewOriginalCenter;
@property (nonatomic, strong) UIButton *btnVenue;
@property (nonatomic, strong) Venue *venue;

@property (nonatomic, assign) CGFloat xShift;
@property (nonatomic, assign) CGFloat yShift;

- (id)initWithVenue:(Venue *)venue;
- (void) resizeMapPinWithZoom: (CGFloat) zoom;
- (void) saveMapPinSize;

@end
