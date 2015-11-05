//
//  LogView.h
//  Navigine_Demo
//
//  Created by Администратор on 19/06/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogViewCell.h"
#import "DebugHelper.h"
#import "NavigineManager.h"
#import "NavMacros.h"
#import "LogFile.h"
#import "JGActionSheet.h"

@interface LogView : UITableViewController<JGActionSheetDelegate,SWTableViewCellDelegate>

@end