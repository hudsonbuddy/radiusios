//
//  NotificationsWindow.h
//  Radius
//
//  Created by Fred Ehrsam on 9/9/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"
#import "BeaconDetailContentViewController.h"
#import "BeaconDetailContentImageViewController.h"
#import "BeaconDetailContentVideoViewController.h"
#import "ConvoThreadViewController.h"
#import "NotificationsFind.h"
#import "DateAndTimeHelper.h"
#import "AsyncImageView.h"

@interface NotificationsWindow : UIView <UITableViewDataSource, UITableViewDelegate> {
    
    
}

@property (weak, nonatomic) IBOutlet UITableView *notificationsTable;
//@property (strong, nonatomic) UIView * superView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSMutableArray *notificationResponseArray;
@property (strong, nonatomic) NSMutableDictionary *notificationResponseDictionary;

- (IBAction)dismiss:(id)sender;

@property (strong, nonatomic) NSArray *notifications;

@end
