//
//  PressPin.m
//
//
//  Created by Администратор on 02/10/15.
//
//

#import "PressPin.h"

@interface PressPin(){
  UIImageView *pipka;
}

@end

@implementation PressPin

- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if(self){
    [self setImage:[UIImage imageNamed:@"elmMapPin"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"elmMapPin"] forState:UIControlStateHighlighted];
    
    self.unnotationView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 120, 44)];
    self.unnotationView.backgroundColor = kColorFromHex(0x4AADD4);
    self.unnotationView.clipsToBounds = NO;
    self.unnotationView.layer.cornerRadius = self.unnotationView.height/2.f;
    self.unnotationView.alpha = 1.f;
    
    pipka = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmBubbleArrowBlue"]];
    [pipka sizeToFit];
    pipka.top = self.unnotationView.bottom - 1.0f;
    pipka.centerX = self.unnotationView.centerX;
    [self.unnotationView addSubview:pipka];
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn setTitle:@"Make route" forState:UIControlStateNormal];
    [self.btn setTitleColor:kColorFromHex(0xFAFAFA) forState:UIControlStateNormal];
    self.btn.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    
    self.btn.frame = self.unnotationView.frame;
    [self.unnotationView addSubview:self.btn];
    
    self.unnotationView.bottom   = self.top - pipka.height;
    self.unnotationView.centerX  = self.centerX;
  }
  return self;
}

-(void) swithPinMode{
  self.unnotationView.backgroundColor = kColorFromHex(0xD36666);
  pipka.image = [UIImage imageNamed:@"elmelmBubbleArrowRed"];
  [self.btn setTitle:@"Remove pin" forState:UIControlStateNormal];
  self.btn.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
}

- (void) resizePressPinWithZoom: (CGFloat)zoom{
  self.centerX = self.originalCenterX * zoom;
  self.bottom = self.originalBottom * zoom;
  self.unnotationView.bottom   = self.top - pipka.height;
  self.unnotationView.centerX  = self.centerX;
}

- (void) savePressPinSize{
  self.originalCenterX = self.centerX ;
  self.originalBottom = self.bottom;
}

@end
