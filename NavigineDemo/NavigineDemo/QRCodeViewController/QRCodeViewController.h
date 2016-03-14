//
//  UserHashViewController.h
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginHelper.h"
#import "NavigineManager.h"
#import <AVFoundation/AVFoundation.h>


@interface QRCodeViewController: UIViewController<AVCaptureMetadataOutputObjectsDelegate,LoginHelperDelegate> {
}

@property (weak, nonatomic) IBOutlet UIImageView *qrImage;
@property (strong) AVCaptureSession *captureSession;
@property (weak, nonatomic) IBOutlet UIButton *userHash;
@property (weak, nonatomic) IBOutlet UILabel *inviteText;

@end
