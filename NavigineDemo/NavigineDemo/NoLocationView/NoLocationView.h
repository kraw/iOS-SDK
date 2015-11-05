//
//  NoLocationView.h
//  Navigine
//
//  Created by Администратор on 07/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoLocationView : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnChooseMap;
@property (weak, nonatomic) IBOutlet UILabel *text;
- (IBAction)btnChooseMapPressed:(id)sender;

@end
