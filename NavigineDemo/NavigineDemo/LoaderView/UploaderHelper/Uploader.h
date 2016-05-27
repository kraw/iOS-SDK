//
//  Uploader.h
//  Navigine
//
//  Created by Администратор on 04/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationInfo.h"

@interface Uploader : NSObject

@property(nonatomic,strong) LocationInfo *location;
@property(nonatomic,assign) NSInteger uploaderId;

-(id)initWithLocation:(LocationInfo *)location andUploaderId: (NSInteger) uploaderId;

@end
