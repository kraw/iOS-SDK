//
//  MeasurePoint.m
//  Navigine
//
//  Created by Pavel Tychinin on 08/06/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "MeasurePoint.h"

@interface MeasurePoint()
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, strong) UIView *pointTitle;
@end

@implementation MeasurePoint

- (id) init{
  self = [super initWithFrame:CGRectMake(0, 0, 10, 10)];
  if(self){
    self.layer.cornerRadius = 5;
    self.backgroundColor = kColorFromHex(0x4AADD4);
  }
  return self;
}

- (id) initWithState:(MeasurePointState) state{
  self = [super initWithFrame:CGRectMake(0, 0, 10, 10)];
  if(self){
    self.layer.cornerRadius = 5;
    self.backgroundColor = kColorFromHex(0x4AADD4);
    switch (state) {
      case MeasurePointStart:
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.text = @"start";
        _pointLabel.font = [UIFont fontWithName:@"Cicle-Regular" size:12];
        _pointLabel.textColor = kWhiteColor;
        [_pointLabel sizeToFit];
        
        _pointTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pointLabel.width + 10, _pointLabel.height)];
        _pointTitle.backgroundColor = kColorFromHex(0x4AADD4);
        [_pointTitle addSubview:_pointLabel];
        _pointLabel.centerX = _pointTitle.width/2.;
        _pointLabel.centerY = _pointTitle.height/2.;
        _pointTitle.layer.cornerRadius = _pointLabel.height/2.;
        _pointTitle.right = self.left;
        _pointTitle.bottom = self.bottom;
        [self addSubview:_pointTitle];
        break;
      case MeasurePointFinish:
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.text = @"finish";
        _pointLabel.font = [UIFont fontWithName:@"Cicle-Regular" size:12];
        _pointLabel.textColor = kWhiteColor;
        [_pointLabel sizeToFit];
        
        _pointTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pointLabel.width + 10, _pointLabel.height)];
        _pointTitle.backgroundColor = kColorFromHex(0x4AADD4);
        [_pointTitle addSubview:_pointLabel];
        _pointLabel.centerX = _pointTitle.width/2.;
        _pointLabel.centerY = _pointTitle.height/2.;
        _pointTitle.layer.cornerRadius = _pointLabel.height/2.;
        _pointTitle.right = self.left;
        _pointTitle.bottom = self.bottom;
        [self addSubview:_pointTitle];
        break;
      default:
        break;
    }
  }
  return self;
}

- (void) changeColorTo:(UIColor*)color{
  self.backgroundColor = color;
  _pointTitle.backgroundColor = color;
}

- (void) resizeMeasurePointWithZoom: (CGFloat) zoom{
  self.center = CGPointMake(self.originalCenter.x * zoom, self.originalCenter.y * zoom);
}

@end
