//
//  MapViewHelper.h
//  Navigine_Demo
//
//  Created by Администратор on 04/06/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LoaderHelper.h"
#import "TBXML.h"
#import "NCImage.h"
#import "UICopyableWebView.h"


struct PointOnMap {
  CGFloat x;
  CGFloat y;
  int sublocationId;
};
typedef struct PointOnMap PointOnMap;


@protocol MapHelperDelegate;
@protocol MapHelperImagesDelegate;
@protocol MapViewDelegate;

@interface MapHelper : NSObject <UIWebViewDelegate, NCBluetoothStateDelegate>

@property (nonatomic, weak) id <MapHelperDelegate> delegate;
@property (nonatomic, weak) id <MapHelperImagesDelegate> imagesDelegate;
@property (nonatomic, weak) id <MapViewDelegate> venueDelegate;

@property (nonatomic, strong) NSMutableArray *webViewArray;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) UIWebView *contentView;
@property (nonatomic, strong) NSArray *sublocId;
@property (nonatomic, assign) NSInteger floor;

+ (MapHelper *)sharedInstance;
- (void)setNewLocation: (NSNotification *)notification;
@end

@protocol MapHelperDelegate <NSObject>
@optional
- (void) startNavigation;
- (void) stopNavigation;
- (void) changeCoordinates;
@end

@protocol MapHelperImagesDelegate <NSObject>
- (void) numberOfImages: (NSUInteger) count;
- (void) finishLoadWithImage: (NCImage*)image atIndex: (NSUInteger)index;
@end

@protocol MapViewDelegate <NSObject>
- (NSString *)showType;
- (Venue *)routeToPlace;
@end
