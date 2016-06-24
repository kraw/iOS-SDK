//
//  MeasurePoint.h
//  Navigine
//
//  Created by Pavel Tychinin on 08/06/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
  MeasurePointStart = 0,
  MeasurePointRegular,
  MeasurePointFinish
} MeasurePointState;

@interface MeasurePoint : UIImageView

@property (nonatomic, assign) CGPoint originalCenter;

- (id) initWithState:(MeasurePointState) state;
- (void) resizeMeasurePointWithZoom: (CGFloat) zoom;
- (void) changeColorTo:(UIColor*)color;
@end
