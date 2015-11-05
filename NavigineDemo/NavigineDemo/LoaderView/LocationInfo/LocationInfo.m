//
//  LoaderInfo.m
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "LocationInfo.h"

@implementation LocationInfo

-(id) init{
  self = [super init];
  if(self){
    self.isSet = NO;
    self.isDownloaded = NO;
    self.isValidArchive = YES;
    self.serverVersion = 0;
    self.loadingProcess = 0;
    self.location = [Location new];
    self.indexPathForCell = nil;
    
    self.circle=[CAShapeLayer layer];
    self.circle.fillColor=[UIColor clearColor].CGColor;
    self.circle.strokeColor=kColorFromHex(0x162D47).CGColor;
    self.circle.lineWidth=2;
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if(self){
    self.isSet = [aDecoder decodeBoolForKey:@"isSet"];
    self.isDownloaded = [aDecoder decodeBoolForKey:@"isDownloaded"];
    self.isValidArchive = [aDecoder decodeBoolForKey:@"isValidArchive"];
    self.serverVersion = [aDecoder decodeIntegerForKey:@"serverVersion"];
    self.loadingProcess = [aDecoder decodeIntegerForKey:@"loadingProcess"];
    self.location = (Location *)[aDecoder decodeObjectForKey:@"location"];
    self.indexPathForCell = (NSIndexPath *)[aDecoder decodeObjectForKey:@"indexPath"];
    self.circle = (CAShapeLayer *)[aDecoder decodeObjectForKey:@"circle"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder{
  [aCoder encodeBool:self.isSet forKey:@"isSet"];
  [aCoder encodeBool:self.isDownloaded forKey:@"isDownloaded"];
  [aCoder encodeBool:self.isValidArchive forKey:@"isValidArchive"];
  [aCoder encodeInteger:self.serverVersion forKey:@"serverVersion"];
  [aCoder encodeInteger:self.loadingProcess forKey:@"loadingProcess"];
  [aCoder encodeObject:self.location forKey:@"location"];
  [aCoder encodeObject:self.indexPathForCell forKey:@"indexPath"];
  [aCoder encodeObject:self.circle forKey:@"circle"];
}
@end
