//
//  PolyLineController.m
//  Navigine
//
//  Created by Администратор on 12/05/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "PolyLineLayout.h"

@interface PolyLineLayout()
@end

@implementation PolyLineLayout

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
  self = [super init];
  if (self) {
    self.width = [UIScreen mainScreen].bounds.size.width;
    self.height = 75;
    self.origin = CGPointMake(0, 0);
    self.backgroundColor = kColorFromHex(0xA6A6A6);
    
    _label = [[UILabel alloc] init];
    _label.text = @"Add check points and tap FINISH";
    _label.origin = CGPointMake(10, 5);
    _label.font = [UIFont fontWithName:@"Circe-Regular" size:16.0f];
    _label.textColor = kColorFromHex(0x14273D);
    [_label sizeToFit];
    [self addSubview:_label];
    
    _addPointButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, self.width/2 - 10, 45)];
    _addPointButton.top = _label.bottom + 5;
    _addPointButton.backgroundColor = kColorFromHex(0xdddddd);
    UILabel *addPointLabel = [[UILabel alloc] init];
    addPointLabel.text = @"ADD POINT";
    addPointLabel.font = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    addPointLabel.textColor = kColorFromHex(0x40A3CD);
    [addPointLabel sizeToFit];
    [_addPointButton addSubview:addPointLabel];
    addPointLabel.centerX = _addPointButton.width/2.;
    addPointLabel.centerY = _addPointButton.height/2.;
    [self addSubview:_addPointButton];
    
    _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(_addPointButton.width + 15, 0, self.width/2 - 10, 45)];
    _finishButton.top = _label.bottom + 5;
    _finishButton.backgroundColor = kColorFromHex(0xdddddd);
    UILabel *finishPointLabel = [[UILabel alloc] init];
    finishPointLabel.text = @"FINISH";
    finishPointLabel.font = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    finishPointLabel.textColor = kColorFromHex(0x40A3CD);
    [finishPointLabel sizeToFit];
    [_finishButton addSubview:finishPointLabel];
    finishPointLabel.centerX = _finishButton.width/2.;
    finishPointLabel.centerY = _finishButton.height/2.;
    [self addSubview:_finishButton];
    
    UILabel *startMeasuringLabel = [[UILabel alloc] init];
    startMeasuringLabel.text = @"START MEASURING";
    startMeasuringLabel.font = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    startMeasuringLabel.textColor = kColorFromHex(0x40A3CD);
    [startMeasuringLabel sizeToFit];
    _startMeasuringButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, startMeasuringLabel.width + 10, 45)];
    _startMeasuringButton.top = _label.bottom + 5;
    _startMeasuringButton.centerX = self.width/2.;
    _startMeasuringButton.backgroundColor = kColorFromHex(0xdddddd);
    [_startMeasuringButton addSubview:startMeasuringLabel];
    startMeasuringLabel.centerX = _startMeasuringButton.width/2.;
    startMeasuringLabel.centerY = _startMeasuringButton.height/2.;
    [self addSubview:_startMeasuringButton];
    
    UILabel *checkPointLabel = [[UILabel alloc] init];
    checkPointLabel.text = @"CHECK POINT";
    checkPointLabel.font = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    checkPointLabel.textColor = kColorFromHex(0x40A3CD);
    [checkPointLabel sizeToFit];
    _checkPointButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, checkPointLabel.width + 10, 45)];
    _checkPointButton.top = _label.bottom + 5;
    _checkPointButton.centerX = self.width/2.;
    _checkPointButton.backgroundColor = kColorFromHex(0xdddddd);
    [_checkPointButton addSubview:checkPointLabel];
    checkPointLabel.centerX = _checkPointButton.width/2.;
    checkPointLabel.centerY = _checkPointButton.height/2.;
    [self addSubview:_checkPointButton];
    
    UILabel *closeLabel = [[UILabel alloc] init];
    closeLabel.text = @"FINISH";
    closeLabel.font = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
    closeLabel.textColor = kColorFromHex(0x40A3CD);
    [closeLabel sizeToFit];
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, closeLabel.width + 10, 45)];
    _closeButton.top = _label.bottom + 5;
    _closeButton.centerX = self.width/2.;
    _closeButton.backgroundColor = kColorFromHex(0xdddddd);
    [_closeButton addSubview:closeLabel];
    closeLabel.centerX = _closeButton.width/2.;
    closeLabel.centerY = _closeButton.height/2.;
    [self addSubview:_closeButton];
  }
  return self;
}

@end
