//
//  FeedCell.h
//  Radius
//
//  Created by Fred Ehrsam on 9/27/12.
//
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timePostedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *beaconNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;
@property (weak, nonatomic) IBOutlet UIView *nearbyBanner;

-(IBAction)beaconButtonPressed:(id)sender;

@property (strong, nonatomic) NSDictionary *beaconDictionary;

-(void) setDistanceLabelWithDistance:(NSString *)distance;
-(void) resizeForNearbyBanner;

@end
