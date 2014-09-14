//
//  BeaconSuggestionsView.h
//  radius
//
//  Created by David Herzka on 1/11/13.
//
//

#import <UIKit/UIKit.h>

@interface BeaconSuggestionsView : UIView <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end
