//
//  LogView.m
//  Navigine_Demo
//
//  Created by Администратор on 19/06/15.
//  Copyright (c) 2015 Navigine. All rights reserved.
//

#import "LogView.h"

@interface LogView(){
  NSArray *filelist;
  NSMutableArray *logFiles;
  NSFileManager *filemgr;
}
@property (nonatomic, strong) NavigineManager *navigineManager;
@property (nonatomic, strong) DebugHelper *debugHelper;
@property (nonatomic, strong) MapHelper *mapHelper;

@end

@implementation LogView

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
  self.navigineManager = [NavigineManager sharedManager];
  self.debugHelper = [DebugHelper sharedInstance];
  self.mapHelper = [MapHelper sharedInstance];
  filelist = [NSArray array];
  logFiles = [NSMutableArray array];
  filemgr = [NSFileManager defaultManager];
  self.tableView.backgroundColor = kColorFromHex(0xEAEAEA);
  
  [self addBackButton];
  [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"btnBack"]];
  [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"btnBack"]];
}


- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
  self.navigationItem.title = self.navigineManager.location.name;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [paths[0] stringByAppendingPathComponent:self.navigineManager.location.name];
  filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
  for(NSString *fileName in filelist){
    if([fileName hasSuffix:@".log"]){
      LogFile *logfile = [[LogFile alloc] initWithString:fileName];
      [logFiles addObject:logfile];
    }
  }
  [self.tableView reloadData];
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [logFiles removeAllObjects];
  [super viewWillDisappear:animated];
}

-(void) addBackButton{
  UIImage *buttonImage = [UIImage imageNamed:@"btnBack"];
  UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  leftButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
  UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
  [leftButton addTarget:self action:@selector(backPressed:)  forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [negativeSpacer setWidth:-17];
  
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,aBarButtonItem,nil] animated:YES];
}

- (IBAction)backPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  // Return the number of sections.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [logFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *CellIdentifier = @"logCell";
  
  LogViewCell *cell = (LogViewCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                                    forIndexPath :indexPath];
  
  LogFile *logfile = logFiles[indexPath.row];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[paths[0] stringByAppendingPathComponent:self.navigineManager.location.name] stringByAppendingPathComponent:filelist[indexPath.row]];
  NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
  cell.logfile.text = [logfile.logName stringByAppendingFormat:@"-%zd",indexPath.row + 1];
  cell.logfile.font  = [UIFont fontWithName:@"Circe-Bold" size:16.0f];
  cell.logfile.textColor = kColorFromHex(0x162D47);
  
  cell.fileDate.text = logfile.logDate;
  cell.fileDate.font  = [UIFont fontWithName:@"Circe-Bold" size:13.f];
  cell.fileDate.textColor = kColorFromHex(0x939393);
  
  cell.fileSize.text = [NSString stringWithFormat:@"%.1fkB",[[fileAttributes objectForKey:NSFileSize] longLongValue]/1024.];
  cell.fileSize.font  = [UIFont fontWithName:@"Circe-Bold" size:17.f];
  cell.fileSize.textColor = kColorFromHex(0xAFAFAF);
  
  NSMutableArray *rightUtilityButtons = [NSMutableArray new];
  [rightUtilityButtons sw_addUtilityButtonWithColor:kColorFromHex(0xD36666) icon:[UIImage imageNamed:@"btnDeleteMap"]];
  UIButton *deleteLocation = [rightUtilityButtons objectAtIndex:0];
  deleteLocation.frame = CGRectMake(0, 0, 64, 64);
  cell.rightUtilityButtons = rightUtilityButtons;
  cell.delegate = self;

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  NSString *logFile = filelist[indexPath.row];
  if(![logFile hasSuffix:@"zip"]){
    LogFile *logfile = logFiles[indexPath.row];
    self.debugHelper.navigateLogfile = logFile;
    self.debugHelper.navigateLogfileTitle = logfile.logName;
    NSString *title = [NSString stringWithFormat:@"Play %@",logfile.logName];
    NSArray *playTitles = [NSArray arrayWithObject:title];
    JGActionSheetSection *playSection = [JGActionSheetSection sectionWithTitle: nil
                                                                       message: nil
                                                                  buttonTitles: playTitles
                                                                   buttonStyle: JGActionSheetButtonStyleBlue];
    
    NSArray *cancelTitles = [NSArray arrayWithObject:@"Cancel"];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle: nil
                                                                         message: nil
                                                                    buttonTitles: cancelTitles
                                                                     buttonStyle: JGActionSheetButtonStyleCancel];
    NSArray *sections = @[playSection,cancelSection];
    JGActionSheet *sheet = [[JGActionSheet alloc] initWithSections:sections];
    
    sheet.delegate = self;
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
      switch (indexPath.section) {
        case 0:
          [self performSegueWithIdentifier:@"toMapSegue" sender:nil];
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  if ([segue.identifier hasPrefix:@"toMapSegue"]) {
    MapViewController *mvc = (MapViewController *)segue.destinationViewController;
    self.mapHelper.navigationType = NavigationTypeLog;
  }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
  LogFile *logfile = logFiles[index];
  NSError *error = nil;
  [self.navigineManager removeLog: [logfile logFileToString]
                            error: &error];
  if(error){
    DLog(@"Can't remove log: %@ error:%@",[logfile logFileToString],errorß);
  }
  [logFiles removeObject:logfile];
  [cell hideUtilityButtonsAnimated:YES];
  [self.tableView reloadData];
}

@end
