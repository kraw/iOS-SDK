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
  UILabel *title;
}

@end

@implementation PressPin

-(id)initWithFrame:(CGRect)frame{
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
    self.btn.frame =self.unnotationView.frame;
    [self.unnotationView addSubview:self.btn];
    
    title = [[UILabel alloc] init];
    title.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    title.textColor = kColorFromHex(0xFAFAFA);
    title.text = @"Make route";
    [title sizeToFit];
    [self.unnotationView addSubview:title];
    
    title.textAlignment = NSTextAlignmentCenter;
    
    title.centerY = self.unnotationView.centerY;
    title.centerX = self.unnotationView.frame.size.width/2.f;
    
    self.unnotationView.bottom   = self.top - pipka.height;
    self.unnotationView.centerX  = self.centerX;
  }
  return self;
}

-(void) swithPinMode{
  self.unnotationView.backgroundColor = kColorFromHex(0xD36666);
  pipka.image = [UIImage imageNamed:@"elmelmBubbleArrowRed"];
  title.textColor = kColorFromHex(0xFAFAFA);
  title.text = @"Remove pin";
  [title sizeToFit];
}

@end
