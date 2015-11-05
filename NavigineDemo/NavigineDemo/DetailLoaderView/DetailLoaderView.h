//
//  DetailLoaderView.h
//  NavigineDemo
//
//  Created by Администратор on 13/01/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//
#import "LoaderView.h"
#import "DetailLoaderViewHelper.h"


@interface DetailLoaderView :UIViewController <UIScrollViewDelegate,DetailLoaderViewHelperDelegate,UIWebViewDelegate>{
}
@property (nonatomic, strong) Location *location;
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UILabel *size;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end