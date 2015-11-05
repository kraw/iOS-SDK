//
//  LogFile.m
//  Navigine
//
//  Created by Администратор on 09/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "LogFile.h"

@interface LogFile(){
  NSDictionary *months;
}
@property (nonatomic, strong) NSString *logFileAsString;
@end

@implementation LogFile

-(id) initWithString: (NSString *)logFile{
  self = [super init];
  if(self){
    self.logFileAsString = logFile;
    months = @{@"01":@"Jan",@"02":@"Feb",@"03":@"Mar",@"04":@"Apr",@"05":@"May",@"06":@"Jun",
               @"07":@"Jul",@"08":@"Aug",@"09":@"Sep",@"10":@"Oct",@"11":@"Nov",@"12":@"Dec"};
    NSArray *components = [logFile componentsSeparatedByString:@"-"];
    NSString *tail = components[6];
    NSArray *seconds = [tail componentsSeparatedByString:@"."];
    NSInteger monIndex = [components[2] integerValue];
    NSString *month = [months objectForKey:[NSString stringWithFormat:@"%02zd",monIndex]];
    
    NSInteger year = [components[1] integerValue];
    NSInteger day =  [components[3] integerValue];
    NSInteger hour = [components[4] integerValue];
    NSInteger min =  [components[5] integerValue];
    NSInteger sec =  [components[6] integerValue];
    self.logName =  components[0];
    self.logDate = [NSString stringWithFormat:@"%@ %02zd, %02zd:%02zd:%02zd",
                    month,day,hour,min,sec];
  }
  return  self;
}

- (NSString *) logFileToString{
  return self.logFileAsString;
}

@end
