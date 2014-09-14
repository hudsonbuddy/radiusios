//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>

@interface SideMenuViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray * radiusNavigationArray;
@property (nonatomic, strong) NSMutableArray * radiusNavigationViewArray;
@property (nonatomic, strong) NSIndexPath *lastCellSelected;
@property (nonatomic, strong) NSArray *blackImageArray;
@property (nonatomic, strong) NSArray *whiteImageArray;

@end