//
//  NCImage.m
//  Navigine
//
//  Created by Администратор on 20/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "NCImage.h"

@implementation NCImage

-(id)initWithData: (NSData *)data
         mimeType: (NSString *)mimeType
             size: (CGSize)size
            scale: (CGFloat)scale{
  self = [super init];
  if(self){
    self.data = data;
    self.mimeType = mimeType;
    self.size = size;
    self.scale = scale;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone{
  NCImage *image = [[[self class] alloc] initWithData:self.data
                                             mimeType:self.mimeType
                                                 size:self.size
                                                scale:self.scale];
  return image;
}

@end
