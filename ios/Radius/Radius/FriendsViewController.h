//
//  FriendsViewController.h
//  radius
//
//  Created by Hud on 12/17/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"
#import "RadiusViewController.h"

@interface FriendsViewController : RadiusViewController <UITableViewDataSource, UITableViewDelegate> {
    
    
    
}
@property (strong, nonatomic) IBOutlet UITableView *friendsTableViewOutlet;

@end
