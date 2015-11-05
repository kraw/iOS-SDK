//
//  Navigine.m
//  Navigine
//
//  Created by Администратор on 26/10/15.
//  Copyright © 2015 Navigine. All rights reserved.
//

#import "PlayLogHelper.h"

@interface PlayLogHelper(){
  NSMutableArray *viewScale;
}
@property (nonatomic, strong) MapHelper *mapHelper;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation PlayLogHelper

+(PlayLogHelper *) sharedInstance{
  static PlayLogHelper * _sharedInstance = nil;
  
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[PlayLogHelper alloc] init];
  });
  return _sharedInstance;
}


- (instancetype)init{
  self = [super init];
  if(self){
    self.mapHelper = [MapHelper sharedInstance];
    self.mapHelper.imagesDelegate = self;
    
    self.webViewArray = [NSMutableArray array];
    viewScale = [NSMutableArray array];
    
    self.images = [NSMutableArray array];
  }
  return self;
}

- (void) refreshMaps{
  [viewScale removeAllObjects];
  [self.webViewArray removeAllObjects];
  self.images =[[NSMutableArray alloc] initWithArray:self.mapHelper.images];
  for(NCImage *image in self.images){
    UIWebView *currentView= [[UIWebView alloc] init];
    currentView.delegate = self;
    currentView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    
    NSString *html = [NSString stringWithFormat:@"<img src='data:%@;base64,%@' />",image.mimeType, [image.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    [currentView loadHTMLString:html baseURL:nil];
    [currentView setOpaque:NO];
    
    currentView.hidden = YES;
    [currentView.scrollView setScrollEnabled:NO];
    [currentView.scrollView setPagingEnabled:NO];
    [currentView.scrollView setUserInteractionEnabled:NO];
    
    [viewScale addObject:[NSNumber numberWithFloat:image.scale]];
    [self.webViewArray addObject:currentView];
  }
}

#pragma mark MapHelperDelegate methods

- (void) finishLoadWithImage:(NCImage*)image atIndex:(NSUInteger)index{
  UIWebView *currentView= [[UIWebView alloc] init];
  currentView.delegate = self;
  currentView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
  
  NSString *html = [NSString stringWithFormat:@"<img src='data:%@;base64,%@' />",image.mimeType, [image.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
  [currentView loadHTMLString:html baseURL:nil];
  [currentView setOpaque:NO];
  
  currentView.hidden = YES;
  [currentView.scrollView setScrollEnabled:NO];
  [currentView.scrollView setPagingEnabled:NO];
  [currentView.scrollView setUserInteractionEnabled:NO];
  
  [viewScale addObject:[NSNumber numberWithFloat:image.scale]];
  [self.webViewArray addObject:currentView];
  [self.images addObject:image];
}

- (void) numberOfImages: (NSUInteger) count{
  [self.webViewArray removeAllObjects];
  [self.images removeAllObjects];
  [viewScale removeAllObjects];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView{
  NSUInteger index = [self.webViewArray indexOfObject:webView];
  NSNumber *scale = viewScale[index];
  if(scale){
    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = %@;",scale];
    [webView stringByEvaluatingJavaScriptFromString:jsCommand];
  }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  return YES;
}

@end
