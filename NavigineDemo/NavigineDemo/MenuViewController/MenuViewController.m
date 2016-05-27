//
//  MenuViewController.m
//  SVO
//
//  Created by Valentine on 17.06.14.
//  Copyright (c) 2014 Valentine. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuTableViewCell.h"


@interface MenuViewController (){

}

@property (nonatomic, strong) NavigineManager *navigineManager;
@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  self.view.backgroundColor = kColorFromHex(0x14263B);
  self.navigineManager = [NavigineManager sharedManager];
  BOOL su = self.navigineManager.su;
  
  if(!_navigineManager.debugModeEnable)
    _menuArray = [[NSMutableArray alloc] initWithObjects:@"Location management",@"Navigation mode",@"Settings", nil];
  else
    _menuArray = [[NSMutableArray alloc] initWithObjects:@"Location management",@"Navigation mode",@"Settings",@"Debug mode",@"Measuring mode", nil];
  
  [_tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(locationManagementPressed:)
                                               name:@"locationManagementPressed"
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(navigationModePressed:)
                                               name:@"navigationModePressed"
                                             object:nil];
}

- (void) viewWillAppear:(BOOL)animated{
  if (_navigineManager.debugModeEnable){
    _menuArray = [[NSMutableArray alloc] initWithObjects:@"Location management",@"Navigation mode",@"Settings",@"Debug mode",@"Measuring mode", nil];
    [_tv reloadData];
  }
  else{
    _menuArray = [[NSMutableArray alloc] initWithObjects:@"Location management",@"Navigation mode",@"Settings", nil];
    [_tv reloadData];
  }
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)locationManagementPressed:(NSNotification *)notification {
  NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
  [self.tv selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
  NSIndexPath *index = [NSIndexPath indexPathForItem:1 inSection:0];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
}

- (void)navigationModePressed:(NSNotification *)notification {
  NSIndexPath *path = [NSIndexPath indexPathForItem:1 inSection:0];
  [self.tv selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
  NSIndexPath *index = [NSIndexPath indexPathForItem:2 inSection:0];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _menuArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"cell";
  
  MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  cell.titleLabel.font  = [UIFont fontWithName:@"Circe-Bold" size:19.0f];
  cell.titleLabel.textColor = kColorFromHex(0xb4c2cc);
  cell.titleLabel.highlightedTextColor = kColorFromHex(0xfafafa);
  
  cell.titleLabel.text = _menuArray[indexPath.row];
  
  UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
  myBackView.backgroundColor = [UIColor clearColor];
  cell.selectedBackgroundView = myBackView;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSIndexPath *index = [NSIndexPath indexPathForItem:indexPath.row + 1 inSection:0];
  if (indexPath.row > 5) {
    return;
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:@"menuItemPressed" object:nil userInfo:@{@"index": index}];
}

@end
