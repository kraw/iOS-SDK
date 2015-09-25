//
//  ViewController.h
//  bt5
//
//  Created by Администратор on 07.10.14.
//  Copyright (c) 2014 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KontaktSDK.h"


@interface ViewController : UIViewController<UITextFieldDelegate>

{
    
@public
    __weak IBOutlet UILabel *text;

    
    
}

@property (weak, nonatomic) IBOutlet UITextField *txtTxPower;
@property (weak, nonatomic) IBOutlet UITextField *txtAdvertisingInterval;

@property (weak, nonatomic) IBOutlet UITextField *txtUserLogin;

- (IBAction)singIn:(id)sender;



@end

