//
//  Loader.h
//  Navigine
//
//  Created by Администратор on 11/09/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationInfo.h"

@interface Loader : NSObject

@property(nonatomic,strong) LocationInfo *location;
@property(nonatomic) NSInteger loaderId;

-(id)initWithLocation:(LocationInfo *)location andLoaderId: (NSInteger) loaderId;

@end
