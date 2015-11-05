//
//  LogViewCell.h
//  Navigine_Demo
//
//  Created by Администратор on 19/06/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface LogViewCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel* logfile;
@property (nonatomic, weak) IBOutlet UILabel* fileDate;
@property (nonatomic, weak) IBOutlet UILabel* fileSize;

@end
