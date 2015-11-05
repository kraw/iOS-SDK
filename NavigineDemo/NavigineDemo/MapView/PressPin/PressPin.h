//
//  PressPin.h
//  
//
//  Created by Администратор on 02/10/15.
//
//

#import <UIKit/UIKit.h>

@interface PressPin : UIButton

@property (nonatomic, strong) UIView *unnotationView;
@property (nonatomic, strong) UIButton *btn;

-(void) swithPinMode;
@end
