//
//  Beacon.m
//  Navigine
//
//  Created by Администратор on 01/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "Beacon.h"

@implementation Beacon

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) initWithBeacon:(NCBeacon *)beacon{
  self = [super initWithFrame:CGRectZero];
  if(self){
    _beacon = [[NCBeacon alloc] initWithBeacon:beacon];
    [self setBackgroundImage:[UIImage imageNamed:@"elmBeaconIcon"] forState:UIControlStateNormal];
    [self setTitleColor:kColorFromHex(0x4AADD4) forState:UIControlStateNormal];
    [self sizeToFit];
    NSString *status = [NSString string];
    if(beacon.status == NCBeaconNew){
      status = @"*";
    }
    // Label for beacon name & decibels
    UILabel *title = [[UILabel alloc] init];
    title.text = [beacon.name stringByAppendingString:status];
    title.font  = [UIFont fontWithName:@"Circe-Bold" size:15.0f];
    title.textColor = kColorFromHex(0xFAFAFA);
    title.left = 5;
    title.top = 1;
    [title sizeToFit];
    _textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, title.width + 10, title.height)];
    _textImage.layer.cornerRadius = _textImage.height/2.f;
    _textImage.backgroundColor = kColorFromHex(0x4AADD4);
    [_textImage addSubview:title];
    [self addSubview:_textImage];
    _textImage.right = 0;
    _textImage.bottom = self.height;
    _textImage.hidden = YES;
  }
  return self;
}

- (void) updateBeaconWithoutDecibel{
  [_textImage removeAllSubviews];
  NSString *status = [NSString string];
  if(_beacon.status == NCBeaconNew){
    status = @"*";
  }
  UILabel *title = [[UILabel alloc] init];
  title.text = [_beacon.name stringByAppendingString:status];
  title.font  = [UIFont fontWithName:@"Circe-Bold" size:15.0f];
  title.textColor = kColorFromHex(0xFAFAFA);
  title.left = 5;
  title.top = 1;
  [title sizeToFit];
  _textImage.frame = CGRectMake(0, 0, title.width + 10, title.height);
  [_textImage addSubview:title];
  _textImage.right = 0;
  _textImage.bottom = self.height;
}

- (void) updateBeaconWithDecibel :(NSInteger)decibel{
  [_textImage removeAllSubviews];
  NSString *status = [NSString string];
  if(_beacon.status == NCBeaconNew){
    status = @"*";
  }
  UILabel *title = [[UILabel alloc] init];
  title.text = [[_beacon.name stringByAppendingString:status] stringByAppendingFormat:@"(%ld)",(long)decibel];
  title.font  = [UIFont fontWithName:@"Circe-Bold" size:15.0f];
  title.textColor = kColorFromHex(0xFAFAFA);
  title.left = 5;
  title.top = 1;
  [title sizeToFit];
  _textImage.frame = CGRectMake(0, 0, title.width + 10, title.height);
  [_textImage addSubview:title];
  _textImage.right = 0;
  _textImage.bottom = self.height;
}

- (void) resizeBeaconWithZoom: (CGFloat) zoom{
  self.center = CGPointMake(self.originalCenter.x * zoom, self.originalCenter.y * zoom);
}
@end
