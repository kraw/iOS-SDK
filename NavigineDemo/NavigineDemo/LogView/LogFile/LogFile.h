//
//  LogFile.h
//  Navigine
//
//  Created by Администратор on 09/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogFile : NSObject
@property (nonatomic, strong) NSString *logName;
@property (nonatomic, strong) NSString *logDate;

- (id) initWithString: (NSString *)logFile;
- (NSString *)logFileToString;
@end
