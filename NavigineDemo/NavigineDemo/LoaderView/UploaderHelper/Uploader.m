//
//  Uploader.m
//  Navigine
//
//  Created by Администратор on 04/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import "Uploader.h"

@implementation Uploader

-(id)initWithLocation:(LocationInfo *)location andUploaderId: (NSInteger) uploaderId{
  self = [super init];
  if(self){
    self.location = location;
    self.uploaderId = uploaderId;
  }
  return self;
}

@end
