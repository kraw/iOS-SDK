//
//  ErrorView.h
//  Navigine
//
//  Created by Администратор on 25/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
  ErrorViewTypeNone = 0,
  ErrorViewTypeNavigation,
  ErrorViewTypeNewRoute,
  ErrorViewTypeNoGraph,
  ErrorViewTypeOther
}ErrorViewType;

@interface ErrorView : UIView
@property (nonatomic, assign) ErrorViewType type;

- (void) dismissView: (NSTimer *)timer;

@end
