//
//  PlaceView.h
//  SVO
//
//  Created by Valentine on 27.07.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "MapView.h"
#import "NavigineSDK.h"
#import "NavigineManager.h"

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "MapHelper.h"

@interface PlaceView : UIViewController <MapViewDelegate>{
}

+ (PlaceView *)sharedManager;

@property (weak, nonatomic) IBOutlet UIScrollView *sv;

@property (strong,nonatomic) Venue *venues;

@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *line0;

@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *line;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *line2;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end
