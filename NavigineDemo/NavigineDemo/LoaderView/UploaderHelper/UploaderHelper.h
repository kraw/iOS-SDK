//
//  UploaderHelper.h
//  Navigine
//
//  Created by Администратор on 04/03/16.
//  Copyright © 2016 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationInfo.h"
#import "NavigineManager.h"
#import "Reachability.h"
#import "Uploader.h"

@protocol UploaderHelperDelegate;

@interface UploaderHelper : NSObject

@property (nonatomic, weak) id <UploaderHelperDelegate> uploaderDelegate;
@property (nonatomic, strong) NSString *userHash;

+(UploaderHelper *) sharedInstance;


- (void) startUploadCurrentLocation;
- (void) startUploadProcess: (LocationInfo *)location;
- (void) stopUploadProcess: (LocationInfo *)location;
- (void) selectLocation :(LocationInfo *)location error:(NSError *__autoreleasing *)error;
@end

@protocol UploaderHelperDelegate <NSObject>
@optional
- (void) changeUploadingValue :(LocationInfo *)value;
- (void) errorWhileUploading  :(NSInteger)error
                              :(LocationInfo *)location;
- (void) successfullUploading :(LocationInfo *)location;
@end
