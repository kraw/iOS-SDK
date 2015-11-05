//
//  LoaderHelper.m
//  Navigine_Demo
//
//  Created by Администратор on 21/05/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "DetailLoaderViewHelper.h"

@interface DetailLoaderViewHelper(){
  Location *location;
  NSMutableDictionary *viewScaleDictionary;
}

@property (nonatomic, strong) NavigineManager *navigineManager;
@property (nonatomic, strong) NSMutableArray *webViewArray;
//@property (nonatomic, strong) NSMutableDictionary *sublocId;
@end

@implementation DetailLoaderViewHelper

//+(DetailLoaderViewHelper *) sharedInstance{
//  static DetailLoaderViewHelper * _sharedInstance = nil;
//  
//  static dispatch_once_t oncePredicate;
//  dispatch_once(&oncePredicate, ^{
//    _sharedInstance = [[DetailLoaderViewHelper alloc] init];
//  });
//  return _sharedInstance;
//}

-(id)init{
  self = [super init];
  if(self){
    location = [Location new];
    self.navigineManager = [NavigineManager sharedManager];
  }
  return self;
}

-(id)initWithLocation:(Location *)location_{
  self = [super init];
  if(self){
    location = location_;
    viewScaleDictionary = [NSMutableDictionary new];
    self.navigineManager = [NavigineManager sharedManager];
    self.webViewArray = [NSMutableArray new];
//    self.sublocId = [NSMutableDictionary new];
  }
  return self;
}

- (void) getMapFromZip{
  NSData *imageData = nil;
  CGFloat scale = 1.f;
  CGSize s = CGSizeZero;
  CGFloat screenWidth = 280.f;
  CGFloat screenHeight = 152.f;
  NSError *error = nil;
  
  for(int i = 0; i < location.subLocations.count; i++){
    NSString *mimeType = nil;
    Sublocation *sublocation = location.subLocations[i];
    imageData = sublocation.svgImage;
    if(imageData != nil){
      NSError *svgError;
      TBXML *sourceXML = [TBXML newTBXMLWithXMLData:imageData error:&svgError];
      TBXMLElement *rootElement = sourceXML.rootXMLElement;
      NSString *widthAttribute = [TBXML valueOfAttributeNamed:@"width" forElement:rootElement];
      NSString *heightAttribute = [TBXML valueOfAttributeNamed:@"height" forElement:rootElement];
      NSInteger SVGwidth = [widthAttribute integerValue];
      NSInteger SVGheight = [heightAttribute integerValue];
      if(screenHeight/screenWidth < SVGheight/SVGwidth) {
        scale = screenHeight/SVGheight;
      }
      else scale = screenWidth/SVGwidth;
      s = (CGSize)CGSizeMake(SVGwidth*scale, SVGheight*scale);
      mimeType = @"image/svg+xml";
    }
    else{
      error = nil;
      imageData = sublocation.pngImage;
      if(imageData != nil){
        UIImage *PNGim = [UIImage imageWithData:imageData];
        if(screenHeight/screenWidth < PNGim.size.height/PNGim.size.width) {
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
    //[currentView loadData:imageData MIMEType:mimeType textEncodingName:@"utf-8" baseURL:nil];
    
    currentView.hidden = YES;
    [currentView.scrollView setScrollEnabled:NO];
    [currentView.scrollView setPagingEnabled:NO];
    [currentView.scrollView setUserInteractionEnabled:NO];
    
    
    [viewScaleDictionary setObject:[NSNumber numberWithFloat:scale] forKey:[NSNumber numberWithInt:i]];
    [self.webViewArray addObject:currentView];
  }
  if(self.delegate && [self.delegate respondsToSelector:@selector(didRangeImages:)]){
    [self.delegate didRangeImages:self.webViewArray];
  }
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  NSNumber *index = [NSNumber numberWithInteger:[self.webViewArray indexOfObject:webView]];
  NSNumber *scale = [viewScaleDictionary objectForKey:index];
  if(scale){
    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %@;",scale];
    [webView stringByEvaluatingJavaScriptFromString:jsCommand];
  }
  /*
   CGRect frame = self.contentView.frame;
   CGSize fittingSize = [self.contentView sizeThatFits:self.contentView.scrollView.contentSize];
   NSLog(@"frame: %lf %lf", fittingSize.height, fittingSize.width);
   frame.size = fittingSize;
   self.contentView.frame = frame;*/
  //webView.scrollView.zoomScale = 0.2f;
  
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  return YES;
}

@end
