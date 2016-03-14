//
//  PositionOnMap.m
//  Navigine
//
//  Created by Администратор on 04/12/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "PositionOnMap.h"

@interface PositionOnMap()

@property (nonatomic, assign) CGRect originalFrame;
@end


@implementation PositionOnMap

- (id) init{
  self = [super init];
  if(self){
    self.background = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 36, 36)];
    self.background.center = CGPointZero;
    self.background.backgroundColor = kColorFromHex(0x4AADD4);
    self.background.layer.cornerRadius = self.background.height / 2.f;
    self.background.alpha = 0.4;
    
    self.arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmUserCerlceArrow_fill"]];
    self.arrow.center = CGPointZero;
    self.originalFrame = self.arrow.frame;
    [self sizeToFit];
    
    [self addSubview:self.background];
    [self addSubview:self.arrow];
  }
  return self;
}

- (void) resizePositionOnMapWithZoom: (CGFloat) zoom{
  self.arrow.frame = CGRectMake(0.f, 0.f, self.originalFrame.size.width / zoom, self.originalFrame.size.height / zoom);
  self.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
  self.arrow.center = CGPointZero;
}

- (void) savePositionOnMapSize{
  
}

@end
