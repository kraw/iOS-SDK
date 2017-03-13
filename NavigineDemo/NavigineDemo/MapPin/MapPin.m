//
//  MapPin.m
//  SVO
//
//  Created by Valentine on 30.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

- (id)initWithVenue:(NCVenue *)venue
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        
      self.venue = venue;
      UILabel *title = [[UILabel alloc] init];
      title.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
      title.textColor = kColorFromHex(0xFAFAFA);
      title.text = self.venue.name;
      [title sizeToFit];
      
      _popUp = [[UIButton alloc] initWithFrame:CGRectMake(0,0, title.frame.size.width + 31.f + 22.f, 44.f)];
      _popUp.backgroundColor = [UIColor clearColor];
      _popUp.clipsToBounds = NO;
      
      UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, title.frame.size.width + 31.f + 22.f, 44.f)];
      
      bg.backgroundColor = kColorFromHex(0xCE8951);
      bg.alpha = 1.f;
      bg.layer.cornerRadius = bg.frame.size.height/2.f;
      [_popUp addSubview:bg];
      
      UIImageView *pipka = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmBubbleArrowOrange"]];
      [pipka sizeToFit];
        pipka.top = bg.bottom - 1.f;
      pipka.centerX = bg.centerX;
      [_popUp addSubview:pipka];
      
//      self.btnVenue = [UIButton buttonWithType:UIButtonTypeCustom];
//      [self.btnVenue setImage:[UIImage imageNamed:@"elmBubbleArrow"] forState:UIControlStateNormal];
//      [self.btnVenue sizeToFit];
//      [self.mapView addSubview:self.btnVenue];
//      self.btnVenue.frame.size.right = bg.frame.size.right;
      [_popUp addSubview:title];
      
      title.centerX = bg.centerX;
      title.centerY = bg.centerY;
      _popUp.hidden = YES;
    }
    return self;
}

- (void) resizeMapPinWithZoom: (CGFloat) zoom{
//  self.center = CGPointMake(self.originalCenter.x * zoom, self.originalCenter.y * zoom);
//  self.mapView.frame.size.bottom = self.frame.size.top - 9.0f;
//  self.mapView.frame.size.centerX = self.frame.size.centerX;
}

- (void) saveMapPinSize{
//  self.originalCenter = self.center;
}

@end
