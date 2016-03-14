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
@property (nonatomic, assign) CGPoint routePoint;
@property (nonatomic, assign) CGFloat originalBottom;
@property (nonatomic, assign) CGFloat originalCenterX;
@property (nonatomic, assign) CGFloat sublocationId;


-(void) swithPinMode;
- (void) resizePressPinWithZoom: (CGFloat) zoom;
- (void) savePressPinSize;
@end
