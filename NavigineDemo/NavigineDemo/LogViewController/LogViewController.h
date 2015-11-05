//
//  ConsoleView.h
//  Navigine
//
//  Created by Администратор on 18.01.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebugHelper.h"


@interface LogViewController: UIViewController <UITextFieldDelegate, UIScrollViewDelegate>{
}
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UILabel *logFile;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *navigateThisLog;
@property (weak, nonatomic) IBOutlet UIButton *removeThisLog;
@property (weak, nonatomic) IBOutlet UIImageView *line;
- (IBAction)btnNavigate:(id)sender;
- (IBAction)btnRemove:(id)sender;

@end