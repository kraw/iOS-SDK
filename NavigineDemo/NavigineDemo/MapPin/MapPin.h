//
//  MapPin.h
//  SVO
//
//  Created by Valentine on 30.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigineSDK.h"
#import "UIView+Additions.h"
#define kColorFromHex(color)[UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0]

@interface MapPin : UIButton
@property (nonatomic, strong) UIButton *popUp;
@property (nonatomic, strong) NCVenue *venue;

- (id)initWithVenue:(NCVenue *)venue;
- (void) resizeMapPinWithZoom: (CGFloat) zoom;
- (void) saveMapPinSize;

@end
