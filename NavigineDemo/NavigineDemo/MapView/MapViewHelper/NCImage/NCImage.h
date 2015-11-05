//
//  NCImage.h
//  Navigine
//
//  Created by Администратор on 20/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICopyableWebView.h"

@interface NCImage : NSObject <NSCopying>

@property (nonatomic, strong) NSData   *data;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, assign) CGSize   size;
@property (nonatomic, assign) CGFloat  scale;


-(id)initWithData: (NSData *)data
         mimeType: (NSString *)mimeType
             size: (CGSize)size
            scale: (CGFloat) scale;
@end
