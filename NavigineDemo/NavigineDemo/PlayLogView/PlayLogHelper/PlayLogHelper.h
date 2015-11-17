//
//  Navigine.h
//  Navigine
//
//  Created by Администратор on 26/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapHelper.h"

@interface PlayLogHelper: NSObject <MapHelperImagesDelegate, UIWebViewDelegate>
@property (nonatomic, strong) NSMutableArray *webViewArray;

+(PlayLogHelper *) sharedInstance;
- (void) refreshMaps;

@end
