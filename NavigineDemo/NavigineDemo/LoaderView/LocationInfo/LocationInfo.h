//
//  LoaderInfo.h
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTableViewCell.h"
#import "Location.h"

@interface LocationInfo : NSObject <NSCoding>
@property (nonatomic, strong) Location *location;
@property (nonatomic) BOOL isSet;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) BOOL isDownloadingNow;
@property (nonatomic) BOOL isValidArchive;
@property (nonatomic, assign) NSInteger serverVersion;
@property (nonatomic) NSInteger loadingProcess;
@property (nonatomic, strong) NSIndexPath *indexPathForCell;
@property (nonatomic, strong) CAShapeLayer *circle;
@end
