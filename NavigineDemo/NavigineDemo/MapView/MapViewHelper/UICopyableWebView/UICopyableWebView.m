//
//  UICopyableWebView.m
//  Navigine
//
//  Created by Администратор on 26/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "UICopyableWebView.h"

@implementation UICopyableWebView
- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];
  
  if (copy) {
    copy = self;
    // copy the relevant features of the current instance to the copy instance
  }
  return copy;
}
@end
