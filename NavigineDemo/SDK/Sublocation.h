//
//  Sublocation.h
//  NavigineSDK
//
//  Created by Администратор on 27/04/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#ifndef NavigineSDK_Sublocation_h
#define NavigineSDK_Sublocation_h

#endif

@interface Sublocation :NSObject <NSCoding>{
}

@property (nonatomic,assign) NSInteger id;
@property (nonatomic,copy)   NSString  *name;

@property (nonatomic,copy)   NSString  *svgFile;
@property (nonatomic,copy)   NSString  *pngFile;
@property (nonatomic,copy)   NSString  *jpgFile;

@property (nonatomic,copy)   NSData    *svgImage;
@property (nonatomic,copy)   NSData    *pngImage;
@property (nonatomic,copy)   NSData    *jpgImage;

@property (nonatomic,assign) float     width;
@property (nonatomic,assign) float     height;
@property (nonatomic,assign) float     azimuth;
@property (nonatomic,assign) double    gpsLatitude;
@property (nonatomic,assign) double    gpsLongitude;

@property (nonatomic,copy) NSString    *archiveFile;

-(id) initWithSublocation: (Sublocation *)sublocation;
-(NSArray *)getGpsCoordinates: (float)x :(float)y;
@end