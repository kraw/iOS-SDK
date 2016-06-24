//
//  PositionOnMap.h
//  Navigine
//
//  Created by Администратор on 04/12/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionOnMap : UIImageView

@property (nonatomic, assign) NSUInteger locationId;
@property (nonatomic, assign) NSUInteger sublocationId;
@property (nonatomic, assign) CGFloat R;

@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIImageView *background;

@property (nonatomic, assign) BOOL arrowHidden;

- (void) resizePositionOnMapWithZoom: (CGFloat) zoom;

@end
