//
//  LocationTableViewCell.h
//  SVO
//
//  Created by Administrator on 17.06.14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface LocationTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnLocationInfo;
@property (weak, nonatomic) IBOutlet UILabel *serverVersion;
@property (weak, nonatomic) IBOutlet UIImageView *selectedMap;
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadMap;

@end
