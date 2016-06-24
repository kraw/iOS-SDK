//
//  LoaderView.m
//  NavigineDemo
//
//  Created by Администратор on 13/01/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "LoaderView.h"



@interface LoaderView(){
  BOOL isLocationSet;
  NSArray *loadedLocations;
}

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshAnimating;

@property (nonatomic, strong) LoaderHelper *loaderHelper;
@property (nonatomic, strong) UploaderHelper *uploaderHelper;
@property (nonatomic, strong) LoginHelper *userHashHelper;
@property (nonatomic, strong) NavigineManager *navigineManager;
@end


@implementation LoaderView

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

-(void)viewDidLoad{
  [super viewDidLoad];
  self.view.backgroundColor = kColorFromHex(0xEAEAEA);
  self.navigationController.navigationBar.barTintColor = kColorFromHex(0x162D47);
  self.navigationController.navigationBar.translucent = NO;
  
  [self addLeftButton];
  [self addRightButton];
  self.navigineManager = [NavigineManager sharedManager];
  
  
  //initialize loader helper
  self.loaderHelper = [LoaderHelper sharedInstance];
  self.loaderHelper.loaderDelegate = self;
  
  //initialize uploader helper
  self.uploaderHelper = [UploaderHelper sharedInstance];
  
  self.userHashHelper = [LoginHelper sharedInstance];
  CustomTabBarViewController *slide = (CustomTabBarViewController *)self.tabBarController;
  
  
  self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
  isLocationSet = NO;
  loadedLocations = self.loaderHelper.loadedLocations;
  for(LocationInfo *location in loadedLocations){
    if(location.isSet){
      [self setLocation:location];
      break;
    }
  }
  
  [self setupRefreshControl];
  [self.tableView reloadData];
  if (_navigineManager.loadFromURL){
    _navigineManager.loadFromURL = NO;
    NSIndexPath *index = [NSIndexPath indexPathForItem:2 inSection:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
  }
  
}

- (void) viewDidAppear:(BOOL)animated{
  
  self.uploaderHelper.uploaderDelegate = self;
  self.title = self.userHashHelper.name.uppercaseString;
  [self.tableView reloadData];
  [super viewDidAppear:animated];
}

-(void) viewWillAppear:(BOOL)animated{
  [self.userHashHelper refreshLocationList];
  [_loaderHelper refreshLocationList];
  loadedLocations = self.loaderHelper.loadedLocations;
  [super viewWillAppear:animated];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
  [textField resignFirstResponder];
  return YES;
}


- (void)addRightButton {
   UIImage *buttonImage = [UIImage imageNamed:@"btnLogout"];
   UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
   [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
   aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
   UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
   [aButton addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
   
   UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
   [negativeSpacer setWidth:-17];
   
   [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
}

- (void)addLeftButton {
  UIImage *buttonImage = [UIImage imageNamed:@"btnMenu"];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage
                        forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  [leftButton addTarget:self
                 action:@selector(menuPressed:)
       forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
  [negativeSpacer setWidth:-17];
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  // Return the number of sections.
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return loadedLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *CellIdentifier = @"cell";
  
  LocationInfo *currentLocCell = loadedLocations[indexPath.row];
  LocationTableViewCell *cell = (LocationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                                         forIndexPath:indexPath];
  if(currentLocCell.indexPathForCell == nil){
    currentLocCell.indexPathForCell = indexPath;
  }
  
  cell.backgroundColor = kColorFromHex(0xEAEAEA);
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.btnLocationInfo.hidden = YES;
  cell.selectedMap.hidden = YES;
  cell.selectedMap.right = cell.btnDownloadMap.left - 12.f;
  cell.selectedMap.top = cell.btnDownloadMap.top;
  
  
  if(currentLocCell.isValidArchive == NO){
    cell.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  
    cell.titleLabel.text = currentLocCell.location.name;
    cell.titleLabel.top = 10.f;
    
    cell.serverVersion.text = @"Invalid archive";
    cell.serverVersion.font  = [UIFont fontWithName:@"Circe-Bold" size:13.0f];
    cell.serverVersion.textColor = kColorFromHex(0xD36666);
    
    cell.btnLocationInfo.hidden = YES;
    cell.btnDownloadMap.hidden = YES;
    if(currentLocCell.serverVersion != currentLocCell.location.version){
      cell.btnDownloadMap.hidden = NO;
      [cell.btnDownloadMap setImage:[UIImage imageNamed:@"btnDownloadMap"] forState:UIControlStateNormal];
    }
    if(currentLocCell.isDownloadingNow){
      cell.serverVersion.text = @"Downloading...";
      [cell.btnDownloadMap setImage:[UIImage imageNamed:@"elmCercleGray2"] forState:UIControlStateNormal];
    }
    
    return cell;
  }
  

  cell.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  cell.titleLabel.textColor = kColorFromHex(0x162D47);

  cell.titleLabel.text = currentLocCell.location.name;
  cell.titleLabel.top = 10.f;
  
  cell.serverVersion.font  = [UIFont fontWithName:@"Circe-Bold" size:13.0f];
  cell.serverVersion.textColor = kColorFromHex(0x939393);
  //
  if(currentLocCell.isDownloaded){
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:kColorFromHex(0xD36666) icon:[UIImage imageNamed:@"btnDeleteMap"]];
    UIButton *deleteLocation = [rightUtilityButtons objectAtIndex:0];
    deleteLocation.frame = CGRectMake(0, 0, 64, 64);

    cell.serverVersion.text = @"";
    cell.titleLabel.top = 23.f;
    cell.btnLocationInfo.hidden = NO;
    cell.btnDownloadMap.hidden = YES;
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    cell.btnDownloadMap.right = cell.btnLocationInfo.right;
    cell.selectedMap.hidden = NO;
    cell.selectedMap.image = [UIImage imageNamed:@"elmUnselectedmap"];
  }
  else{
    cell.btnLocationInfo.hidden = YES;
    cell.btnDownloadMap.left = cell.btnLocationInfo.left;
  }
  
  if(currentLocCell.serverVersion > currentLocCell.location.version || currentLocCell.location.modified){
    cell.titleLabel.top = 10.f;
    cell.btnDownloadMap.hidden = NO;
    if(currentLocCell.isDownloaded){
      cell.btnDownloadMap.right = cell.btnLocationInfo.left - 12.f;
    }
    if(!currentLocCell.isDownloadingNow){
      if(currentLocCell.location.modified){
        cell.serverVersion.text = [NSString stringWithFormat:@"Version is modified.Upload?"];
        [cell.btnDownloadMap setImage:[UIImage imageNamed:@"btnUploadMap"] forState:UIControlStateNormal];
        cell.btnDownloadMap.tintColor = kColorFromHex(0x43566c);
      }
      else{
        cell.serverVersion.text = [NSString stringWithFormat:@"Version avaliable: %zd",currentLocCell.serverVersion];
        [cell.btnDownloadMap setImage:[UIImage imageNamed:@"btnDownloadMap"] forState:UIControlStateNormal];
        cell.btnDownloadMap.tintColor = kColorFromHex(0xAAAAAA);
      }
    }
    else{
      cell.serverVersion.text = @"Downloading...";
      [cell.btnDownloadMap setImage:[UIImage imageNamed:@"elmCercleGray2"] forState:UIControlStateNormal];
    }
  }
  
  if(currentLocCell.isSet == YES){
    cell.selectedMap.hidden = NO;
    cell.selectedMap.image = [UIImage imageNamed:@"elmSelectedmap"];
    cell.selectedMap.right = cell.btnDownloadMap.left - 12.f;
    cell.selectedMap.top = cell.btnDownloadMap.top;
  }
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  LocationInfo *currentLocation = loadedLocations[indexPath.row];
  if(currentLocation.isDownloaded){
    [self setLocation:currentLocation];
    [self.tableView reloadData];
  }
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
  LocationTableViewCell *tableCell = (LocationTableViewCell *)cell;
  NSString *location = tableCell.titleLabel.text;
  [self.loaderHelper deleteLocation:location];
  [cell hideUtilityButtonsAnimated:YES];
  [self.tableView reloadData];
}


- (IBAction)logOut:(id)sender {
  NSArray *playTitles = [NSArray arrayWithObject:@"Logout"];
  JGActionSheetSection *playSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:playTitles buttonStyle:JGActionSheetButtonStyleRed];
  
  NSArray *cancelTitles = [NSArray arrayWithObject:@"Cancel"];
  JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:cancelTitles buttonStyle:JGActionSheetButtonStyleCancel];
  NSArray *sections = @[playSection,cancelSection];
  JGActionSheet *sheet = [[JGActionSheet alloc] initWithSections:sections];
  
  sheet.delegate = self;
  
  [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
    switch (indexPath.section) {
      case 0:
        [self.loaderHelper stopNavigine];
        [self.loaderHelper deleteAllLocations];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed"
                                                            object:nil
                                                          userInfo:@{@"index": [NSIndexPath indexPathForItem:0 inSection:0]}];
        [sheet dismissAnimated:NO];
        break;
      case 1:
        [sheet dismissAnimated:YES];
        break;
      default:
        break;
    }
  }];
  
  [sheet showInView:self.navigationController.view animated:YES];
}

- (IBAction)menuPressed:(id)sender {
  if(self.slidingPanelController.sideDisplayed == MSSPSideDisplayedLeft) {
    [self.slidingPanelController closePanel];
  }
  else {
    [self.slidingPanelController openLeftPanel];
  }
}

- (void) changeDownloadingValue:(LocationInfo *)locationInfo{
  locationInfo.circle.path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(18, 18)
                                             radius:16.5f
                                         startAngle:-M_PI_2
                                           endAngle:-M_PI_2 + 2*M_PI/100.*locationInfo.loadingProcess
                                          clockwise:YES].CGPath;
}

- (void) changeUploadingValue:(LocationInfo *)locationInfo{
  locationInfo.circle.path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(18, 18)
                                                          radius:16.5f
                                                      startAngle:-M_PI_2
                                                        endAngle:-M_PI_2 + 2*M_PI/100.*locationInfo.loadingProcess
                                                       clockwise:YES].CGPath;
}

- (void)errorWhileDownloading:(NSInteger)error :(LocationInfo *)locationInfo{
  locationInfo.isDownloadingNow = NO;
  locationInfo.location.version = 0;
  locationInfo.isDownloadingNow = NO;
  [locationInfo.circle removeFromSuperlayer];
  locationInfo.loadingProcess = 0;
  [self showStatusBarMessage:@"    Cannot connect to server. Check your internet connection." withColor:kColorFromHex(0xD36666) hideAfter:5];

  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:locationInfo.indexPathForCell] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView endUpdates];
}

- (void) errorWhileUploading:(NSInteger)error :(LocationInfo *)locationInfo{
  locationInfo.isDownloadingNow = NO;
  locationInfo.location.version = 0;
  locationInfo.isDownloadingNow = NO;
  [locationInfo.circle removeFromSuperlayer];
  locationInfo.loadingProcess = 0;
  [self showStatusBarMessage:@"    Cannot connect to server. Check your internet connection." withColor:kColorFromHex(0xD36666) hideAfter:5];
  
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:locationInfo.indexPathForCell] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView endUpdates];
}

-(void)successfullDownloading:(LocationInfo *)locationInfo{
  [locationInfo.circle removeFromSuperlayer];
  locationInfo.isDownloaded = YES;
  locationInfo.isDownloadingNow = NO;
  NSError *error = nil;
  [self.loaderHelper selectLocation:locationInfo error:&error];
  [self.uploaderHelper selectLocation:locationInfo error:&error];
  if(error != nil){
    isLocationSet = NO;
    locationInfo.isValidArchive = NO;
    locationInfo.isSet = NO;
  }
  else{
    isLocationSet = YES;
    locationInfo.isValidArchive = YES;
    [self showStatusBarMessage:@"    Downloading is complete" withColor:kColorFromHex(0x14263b) hideAfter:5];
  }
  locationInfo.serverVersion = locationInfo.location.version;
  [self.tableView reloadData];
}

-(void) successfullUploading:(LocationInfo *)locationInfo{
  [locationInfo.circle removeFromSuperlayer];
  locationInfo.isDownloaded = YES;
  locationInfo.isDownloadingNow = NO;
  NSError *error = nil;
  [self.loaderHelper selectLocation:locationInfo error:&error];
  [self.uploaderHelper selectLocation:locationInfo error:&error];
  if(error != nil){
    isLocationSet = NO;
    locationInfo.isValidArchive = NO;
    locationInfo.isSet = NO;
  }
  else{
    isLocationSet = YES;
    locationInfo.isValidArchive = YES;
    [self showStatusBarMessage:@"    Downloading is complete" withColor:kColorFromHex(0x14263b) hideAfter:5];
  }
  locationInfo.serverVersion = locationInfo.location.version;
  [self.tableView reloadData];
}

-(void)showStatusBarMessage:(NSString *)message withColor:(UIColor *)color hideAfter:(NSTimeInterval)delay{
  __block UIWindow *statusWindow = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
  statusWindow.windowLevel = UIWindowLevelStatusBar + 1;
  UILabel *label = [[UILabel alloc] initWithFrame:statusWindow.bounds];
  label.textAlignment = NSTextAlignmentLeft;
  label.backgroundColor = color;
  label.textColor = kColorFromHex(0xF9F9F9);
  label.font  = [UIFont fontWithName:@"Circe-Bold" size:11.0f];
  label.text = message;
  [statusWindow addSubview:label];
  [statusWindow makeKeyAndVisible];
  label.bottom = statusWindow.top;
  [UIView animateWithDuration:0.7 animations:^{
    label.bottom = statusWindow.bottom;
  }completion:^(BOOL finished){
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [UIView animateWithDuration:0.5 animations:^{
        label.bottom = statusWindow.top;
      }completion:^(BOOL finished){
        statusWindow = nil;
        [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
      }];
    });
  }];
}

- (void)setLocation :(LocationInfo *)locationInfo{
  NSError *error = nil;
  self.navigineManager.modified = NO;
  [self.loaderHelper selectLocation:locationInfo error:&error];
  [self.uploaderHelper selectLocation:locationInfo error:&error];
  if(error != nil){
    isLocationSet = NO;
    locationInfo.isValidArchive = NO;
    locationInfo.isSet = NO;
  }
  else{
    isLocationSet = YES;
    locationInfo.isValidArchive = YES;
    locationInfo.serverVersion = locationInfo.location.version;
  }
  [self.tableView reloadData];
}

- (IBAction)btnMapInfo:(id)sender {
  [self performSegueWithIdentifier:@"detail" sender:sender];
}

- (IBAction)btnDownloadMapPressed:(id)sender {
  UIButton *downloadBtn = (UIButton *)sender;
  LocationTableViewCell *cell = (LocationTableViewCell*)[[[[downloadBtn superview] superview] superview] superview];
  
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cell.center];
  LocationInfo *currentLocation = loadedLocations[indexPath.row];
  
  if(currentLocation.isDownloadingNow){
    currentLocation.isDownloadingNow = NO;
    currentLocation.loadingProcess = 0;
    LocationTableViewCell *cell = (LocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cell"
                                                                                                forIndexPath:indexPath];
    [self.loaderHelper stopDownloadProcess:currentLocation];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
  }
  else{
    currentLocation.isDownloadingNow = YES;
    currentLocation.loadingProcess = 1;
    currentLocation.circle.path=[UIBezierPath bezierPathWithArcCenter: CGPointMake(18, 18)
                                                               radius: 16.5f
                                                           startAngle: -M_PI_2
                                                             endAngle: -M_PI_2
                                                            clockwise: YES].CGPath;
    LocationTableViewCell *cell = (LocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cell"
                                                                                                forIndexPath:indexPath];
    [cell.btnDownloadMap.layer addSublayer:currentLocation.circle];
    if(currentLocation.location.modified){
      [self.uploaderHelper startUploadProcess:currentLocation];
    }
    else{
      [self.loaderHelper startDownloadProcess:currentLocation :YES];
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
  }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  UIButton *downloadBtn = (UIButton *)sender;
  LocationTableViewCell *cell = (LocationTableViewCell*)[[[[downloadBtn superview] superview] superview] superview];
  
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cell.center];
  LocationInfo *currentLocation = loadedLocations[indexPath.row];

  if ([segue.identifier hasPrefix:@"detail"]) {
    DetailLoaderView *dlvc = (DetailLoaderView *)segue.destinationViewController;
    dlvc.location = currentLocation.location;
  }
}

-(void) deleteLocation :(NSString *)locationForDelete{
  [self.loaderHelper deleteLocation:locationForDelete];
  if(self.navigineManager.location == nil)
    isLocationSet = NO;
  [self.tableView reloadData];
}

- (void)setupRefreshControl{
  self.refreshControl = [[UIRefreshControl alloc] init];
  
  // Setup the loading view, which will hold the moving graphics
  self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
  self.refreshLoadingView.height = 64.f;
  self.refreshLoadingView.backgroundColor = kColorFromHex(0xD8D8D8);
  
  // Create the graphic image views
  self.compass_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elmRefreshList"]];
  self.compass_spinner.centerX = self.refreshLoadingView.centerX;
  self.compass_spinner.centerY = self.refreshLoadingView.centerY - 2.f;
  // Add the graphics to the loading view
  [self.refreshLoadingView addSubview:self.compass_spinner];
  
  // Clip so the graphics don't stick out
  self.refreshLoadingView.clipsToBounds = YES;
  
  // Hide the original spinner icon
  self.refreshControl.tintColor = [UIColor clearColor];
  
  // Add the loading and colors views to our refresh control
  [self.refreshControl addSubview:self.refreshLoadingView];
  
  // Initalize flags
  self.isRefreshAnimating = NO;
  
  // When activated, invoke our refresh function
  [self.refreshControl addTarget:self
                          action:@selector(refresh:)
                forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender{
  [self.loaderHelper reloadLocationList];
}

- (void)animateRefreshView{
  // Flag that we are animating
  self.isRefreshAnimating = YES;
  
  [UIView animateWithDuration:0.3
                        delay:0
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                     // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                     [self.compass_spinner setTransform:CGAffineTransformRotate(self.compass_spinner.transform, -M_PI_2)];
                   }
                   completion:^(BOOL finished) {
                     // If still refreshing, keep spinning, else reset
                     if (self.refreshControl.isRefreshing) {
                       [self animateRefreshView];
                     }else{
                       [self resetAnimation];
                     }
                   }];
}

- (void)resetAnimation{
  // Reset our flags and background color
  self.isRefreshAnimating = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  // Get the current size of the refresh controller
  CGRect refreshBounds = self.refreshControl.bounds;
  
  // Distance the table has been pulled >= 0
  CGFloat pullDistance = MAX(0.0, - scrollView.contentOffset.y);

  CGFloat pullRatio = pullDistance / 64.f;
  
  self.compass_spinner.transform = CGAffineTransformMakeRotation(M_PI * pullRatio);
  // Set the encompassing view's frames
  refreshBounds.size.height = pullDistance;
  
  self.refreshLoadingView.frame = refreshBounds;
  
  // If we're refreshing and the animation is not playing, then play the animation
  if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
    [self animateRefreshView];
  }
}

- (void)locationListUpdateSuccessful{
  [self.refreshControl endRefreshing];
  [self.loaderHelper refreshLocationList];
  loadedLocations = self.loaderHelper.loadedLocations;
  [self.tableView reloadData];
}

- (void)locationListUpdateError:(NSInteger)error{
  [self.refreshControl endRefreshing];
  [self.tableView reloadData];
  if(error == -1)
    [self showStatusBarMessage:@"    Cannot connect to server. Check your internet connection." withColor:kColorFromHex(0xD36666) hideAfter:5];
}

-(void)viewDidDisappear:(BOOL)animated{
  [super viewDidDisappear:animated];
  self.uploaderHelper.uploaderDelegate = nil;
}

//- (UIImage *)convertViewToImage {
//  UIGraphicsBeginImageContext(self.navigationController.view.bounds.size);
//  [self.navigationController.view drawViewHierarchyInRect:self.navigationController.view.bounds afterScreenUpdates:YES];
//  UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  
//  return image2;
//}
@end