//
//  ViewController.h
//  AsyncImageTest
//
//  Created by David Herzka on 10/14/12.
//  Copyright (c) 2012 David Herzka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsyncImageView;

@interface ViewController : UIViewController <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)printCache:(id)sender;

@end
