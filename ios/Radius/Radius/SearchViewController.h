//
//  SearchViewController.h
//  Radius
//
//  Created by Hud on 7/17/12.
//
//

#import <UIKit/UIKit.h>
#import "FindSearchBeacons.h"
#import "BeaconContentViewController2.h"
#import "RadiusViewController.h"

@interface SearchViewController : RadiusViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UISearchBar *searchBarInput;
@property (strong, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UIButton *beaconButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleButton;

- (IBAction)pressedBeaconButton:(id)sender;
- (IBAction)pressedPeopleButton:(id)sender;

typedef enum{SearchModeBeacons=0,SearchModePeople=1} SearchMode;

@end
