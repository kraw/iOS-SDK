//
//  LogFile.m
//  Navigine
//
//  Created by Администратор on 09/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "LogFile.h"

@implementation LogFile

- (id) initWithString:(NSString *)logFile andPath:(NSString *)path{
  self = [super init];
  if(self){
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:logFile] error:nil];
    _logSize = [fileAttributes objectForKey:NSFileSize];
    NSDate *date = [fileAttributes objectForKey:NSFileCreationDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, HH:mm:ss"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    NSString *myDate = [dateFormatter stringFromDate:date];
    _logDate = [dateFormatter stringFromDate:date];
    _logName = logFile;
  }
  return  self;
}

@end
