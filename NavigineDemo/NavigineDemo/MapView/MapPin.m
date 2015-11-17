//
//  MapPin.m
//  SVO
//
//  Created by Valentine on 30.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

- (id)initWithVenue:(Venue *)venue
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
      
      self.mapView = [[UIView alloc] initWithFrame:CGRectMake(0,0, title.width + 31.f + 22.f, 44.f)];
      self.mapView.backgroundColor = [UIColor clearColor];
      self.mapView.clipsToBounds = NO;
      
      UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, title.width + 31.f + 22.f, 44.f)];
      
      bg.backgroundColor = kColorFromHex(0xCE8951);
      bg.alpha = 1.f;
      bg.layer.cornerRadius = bg.height/2.f;
      [self.mapView addSubview:bg];
      
      UIImageView *pipka = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmBubbleArrowOrange"]];
      [pipka sizeToFit];
      pipka.top = bg.bottom - 1.0f;
      pipka.centerX = bg.centerX;
      [self.mapView addSubview:pipka];
      
      self.btnVenue = [UIButton buttonWithType:UIButtonTypeCustom];
      [self.btnVenue setImage:[UIImage imageNamed:@"elmBubbleArrow"] forState:UIControlStateNormal];
      [self.btnVenue setImage:[UIImage imageNamed:@"elmBubbleArrow"] forState:UIControlStateHighlighted];
      [self.btnVenue sizeToFit];
      [self.mapView addSubview:self.btnVenue];
      self.btnVenue.right = bg.right;
      [self.mapView addSubview:title];
      title.left = 22.f;
      
      title.centerY = bg.centerY;
      self.mapView.hidden = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
