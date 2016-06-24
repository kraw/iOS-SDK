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
@property (nonatomic, strong) NSString *logSize;

- (id) initWithString:(NSString *)logFile andPath:(NSString *)path;
@end
