//
//  ErrorView.m
//  Navigine
//
//  Created by Администратор on 25/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "ErrorView.h"

@interface ErrorView()
@property  (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableAttributedString *text;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;
@end

@implementation ErrorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
  self = [super initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 151, 320, 87)];
  if(self){
    self.backgroundColor = kColorFromHex(0xD36666);
    self.alpha = 0.9f;
    
    _text = [[NSMutableAttributedString alloc] initWithString:@"I can't detect your position.              You are out of range of navigation"];
    _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    _paragraphStyle.lineSpacing = 9.f;
    [_text addAttribute:NSParagraphStyleAttributeName value:_paragraphStyle range:NSMakeRange(0, 40)];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(33.f, 22.f, 253.f, 42.f)];
    _label.attributedText = _text;
    _label.textColor = kColorFromHex(0xFAFAFA);
    _label.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    [self addSubview:_label];
    _type = ErrorViewTypeNone;
    
    _timer = nil;
    
    self.hidden = YES;
  }
  return self;
}

-(void) setType:(ErrorViewType)type{
  _type = type;
  [_timer invalidate];
  _timer = nil;
  self.hidden = NO;
  [_label removeFromSuperview];
  switch (type) {
    case ErrorViewTypeNone:
      break;
    case ErrorViewTypeNavigation:
      _text.mutableString.string = @"I can't detect your position.              You are out of range of navigation";
      break;
    case ErrorViewTypeNewRoute:
      _text.mutableString.string = @"Unable to make route: you must cancel previous route first!";
      _timer = [NSTimer scheduledTimerWithTimeInterval:5.
                                                target:self
                                              selector:@selector(dismissView:)
                                              userInfo:nil
                                               repeats:NO];
      break;
    case ErrorViewTypeOther:
      _text.mutableString.string = @"Something is wrong with location!      Please, contact technical support!";
      break;
    case ErrorViewTypeNoGraph:
      _text.mutableString.string = @"Unable to make route!                         Graph is empty!";
      _timer = [NSTimer scheduledTimerWithTimeInterval:5.
                                                target:self
                                              selector:@selector(dismissView:)
                                              userInfo:nil
                                               repeats:NO];
      break;
    default:
      break;
  }
  
  [_text addAttribute:NSParagraphStyleAttributeName value:_paragraphStyle range:NSMakeRange(0, 40)];
  _label.attributedText = _text;
  _label.textColor = kColorFromHex(0xFAFAFA);
  _label.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  _label.textAlignment = NSTextAlignmentCenter;
  _label.numberOfLines = 0;
  [self addSubview:_label];
}

- (void) dismissView: (NSTimer *)timer{
  _type = ErrorViewTypeNone;
  [_timer invalidate];
  _timer = nil;
  self.hidden = YES;
}

@end
