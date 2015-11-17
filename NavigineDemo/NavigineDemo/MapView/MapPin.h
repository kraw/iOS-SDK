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

@property (nonatomic, strong) UIView *mapView;
@property (nonatomic, strong) UIButton *btnVenue;
@property (nonatomic, strong) Venue *venue;

- (id)initWithVenue:(Venue *)venue;

@end
