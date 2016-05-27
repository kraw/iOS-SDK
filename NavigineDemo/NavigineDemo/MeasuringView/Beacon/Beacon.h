//
//  Beacon.h
//  Navigine
//
//  Created by Администратор on 01/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCBeacon.h"

@interface Beacon : UIButton

@property (nonatomic, strong) NCBeacon *beacon;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, strong) UIImageView *textImage;

- (id) initWithBeacon:(NCBeacon *)beacon;
- (void) updateBeaconWithDecibel :(NSInteger)decibel;
- (void) updateBeaconWithoutDecibel;
- (void) resizeBeaconWithZoom: (CGFloat) zoom;
@end
