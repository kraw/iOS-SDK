//
//  LoaderHelper.h
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserHashHelper.h"

@protocol DetailLoaderViewHelperDelegate;

@interface DetailLoaderViewHelper : NSObject<UIWebViewDelegate>

@property (nonatomic, weak) id <DetailLoaderViewHelperDelegate> delegate;

- (id) init;
- (id) initWithLocation:(Location *)location;
- (void) getMapFromZip;
@end

@protocol DetailLoaderViewHelperDelegate <NSObject>
@optional
- (void) didRangeImages:(NSArray *)images;

@end