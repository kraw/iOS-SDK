//
//  Loader.m
//  Navigine
//
//  Created by Администратор on 11/09/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "Loader.h"

@implementation Loader

-(id)initWithLocation:(LocationInfo *)location andLoaderId: (NSInteger) loaderId{
  self = [super init];
  if(self){
    self.location = location;
    self.loaderId = loaderId;
  }
  return self;
}

@end
