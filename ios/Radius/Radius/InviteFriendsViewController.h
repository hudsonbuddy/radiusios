//
//  InviteFriendsViewController.h
//  Radius
//
//  Created by Fred Ehrsam on 10/25/12.
//
//

#import <UIKit/UIKit.h>
#import "FindSearchBeacons.h"
#import "BeaconContentViewController2.h"
#import "RadiusViewController.h"

@interface InviteFriendsViewController : RadiusViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UISearchBar *searchBarInput;
@property (strong, nonatomic) IBOutlet UITableView *searchResultsTableView;

@property (strong, nonatomic) NSMutableDictionary *selectedPeopleDictionary;

@property (strong, nonatomic) NSString *beaconID;
@property (strong, nonatomic) NSString *beaconName;
@property (nonatomic) BOOL justCreated;

@end
