//
//  MapViewHelper.m
//  Navigine_Demo
//
//  Created by Администратор on 04/06/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "MapHelper.h"

@interface MapHelper(){
  NSTimer      *timerNavigation;
  NSTimer      *startTimer;
  NSMutableArray *viewScale;
}


@property (nonatomic, strong) LoaderHelper     *loaderHelper;
@property (nonatomic, strong) NavigineManager  *navigineManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;

@end

@implementation MapHelper

+(MapHelper *) sharedInstance{
  static MapHelper * _sharedInstance = nil;
  
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[MapHelper alloc] init];
  });
  return _sharedInstance;
}


- (instancetype)init{
  self = [super init];
  if(self){
    self.loaderHelper = [LoaderHelper sharedInstance];
    self.navigineManager = [NavigineManager sharedManager];
    self.webViewArray = [NSMutableArray new];
    self.images = [NSMutableArray new];
    self.sublocId = [NSArray new];
    self.floor = 0;
    viewScale = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNewLocation:)
                                                 name:@"setLocation"
                                               object:nil];
    
  }
  return self;
}


- (void) getMapFromZip{
  NSData *imageData = nil;
  CGFloat scale = 1.f;
  CGSize s = CGSizeZero;
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;
  CGFloat screenHeight = screenRect.size.height - 64.f;
  NSError *error = nil;
  
  self.sublocId = [self.navigineManager arrayWithSublocationsId:&error];
  if(self.imagesDelegate && [self.imagesDelegate respondsToSelector:@selector(numberOfImages:)]){
    [self.imagesDelegate numberOfImages:self.sublocId.count];
  }
  if(error){
    [UIAlertView showWithTitle:@"ERROR" message:@"Incorrect Sublocation" cancelButtonTitle:@"OK"];
    return;
  }
  for(int i = 0; i < [self.sublocId count]; i++){
    NSString *mimeType = nil;
    error = nil;
    imageData = [self.navigineManager dataForSVGImageAtIndex:i error:&error];
    if(!error){
      NSError *svgError;
      TBXML *sourceXML = [TBXML newTBXMLWithXMLData:imageData error:&svgError];
      TBXMLElement *rootElement = sourceXML.rootXMLElement;
      NSString *widthAttribute = [TBXML valueOfAttributeNamed:@"width" forElement:rootElement];
      NSString *heightAttribute = [TBXML valueOfAttributeNamed:@"height" forElement:rootElement];
      NSInteger SVGwidth = [widthAttribute integerValue];
      NSInteger SVGheight = [heightAttribute integerValue];
      if(screenHeight/screenWidth > SVGheight/SVGwidth) {
        scale = screenHeight/SVGheight;
      }
      else scale = screenWidth/SVGwidth;
      s = (CGSize)CGSizeMake(SVGwidth*scale, SVGheight*scale);
      mimeType = @"image/svg+xml";
    }
    else{
      error = nil;
      imageData = [self.navigineManager dataForPNGImageAtIndex:i error:&error];
      if(!error){
        UIImage *PNGim = [UIImage imageWithData:imageData];
        if(screenHeight/screenWidth > PNGim.size.height/PNGim.size.width) {
          scale = screenHeight/PNGim.size.height;
        }
        else
          scale = screenWidth/PNGim.size.width;
        
        s = (CGSize)CGSizeMake(PNGim.size.width*scale, PNGim.size.height*scale);
        mimeType = @"image/png";
      }
      else{
        [UIAlertView showWithTitle:@"ERROR" message:@"Incorrect Image inside archive" cancelButtonTitle:@"OK"];
        return;
      }
    }
    UIWebView *currentView= [[UIWebView alloc] init];
    currentView.delegate = self;
    currentView.bounds = CGRectMake(0, 0, s.width, s.height);
    
    NSString *html = [NSString stringWithFormat:@"<img src='data:%@;base64,%@' />",mimeType, [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    [currentView loadHTMLString:html baseURL:nil];
    [currentView setOpaque:NO];
    
    currentView.hidden = YES;
    [currentView.scrollView setScrollEnabled:NO];
    [currentView.scrollView setPagingEnabled:NO];
    [currentView.scrollView setUserInteractionEnabled:NO];
    
    [viewScale addObject:[NSNumber numberWithFloat:scale]];
    [self.webViewArray addObject:currentView];
    
    NCImage *image = [[NCImage alloc] initWithData:imageData
                                          mimeType:mimeType
                                              size:s
                                             scale:scale];
    [self.images addObject:image];
  }
}


- (void)setNewLocation: (NSNotification *)notification{
  self.floor = 0;
  [viewScale removeAllObjects];
  [self.webViewArray removeAllObjects];
  [self.images removeAllObjects];
  [self getMapFromZip];
  [self start];
}

- (void)start{
  if(timerNavigation == nil) {
    timerNavigation = [NSTimer scheduledTimerWithTimeInterval:1.0/10
                                                        target:self
                                                      selector:@selector(changeCoordinates:)
                                                      userInfo:nil
                                                       repeats:YES];
  }
}

- (void)changeCoordinates: (NSTimer *)timer{
  if(self.delegate && [self.delegate respondsToSelector:@selector(changeCoordinates)]){
    [self.delegate changeCoordinates];
  }
}


#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  NSUInteger index = [self.webViewArray indexOfObject:webView];
  NSNumber *scale = viewScale[index];
  if(scale){
    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %@;",scale];
    [webView stringByEvaluatingJavaScriptFromString:jsCommand];
  }
  if(self.imagesDelegate && [self.imagesDelegate respondsToSelector:@selector(finishLoadWithImage:atIndex:)]){
    [self.imagesDelegate finishLoadWithImage:[self.images objectAtIndex:index] atIndex:index];
  }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  return YES;
}

#pragma mark - CBCentralManagerDelegate methods

@end
