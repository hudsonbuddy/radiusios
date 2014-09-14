//
//  FeedCell.m
//  Radius
//
//  Created by Fred Ehrsam on 9/27/12.
//
//

#import "FeedCell.h"
#import "BeaconContentViewController2.h"

@implementation FeedCell

@synthesize timePostedLabel;
@synthesize distanceLabel, beaconNameLabel, numberOfFollowersLabel;
@synthesize nearbyBanner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupFonts];
        [timePostedLabel setFont:[UIFont fontWithName:@"Quicksand" size:timePostedLabel.font.pointSize]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setupFonts
{
    [timePostedLabel setFont:[UIFont fontWithName:@"Quicksand" size:timePostedLabel.font.pointSize]];
    [distanceLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:distanceLabel.font.pointSize]];
    [beaconNameLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:beaconNameLabel.font.pointSize]];
    [numberOfFollowersLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:numberOfFollowersLabel.font.pointSize]];
}

-(void)beaconButtonPressed:(id)sender
{
    if(self.beaconDictionary) {
        UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        
        BeaconContentViewController2 *demoController = [st instantiateViewControllerWithIdentifier:@"beaconContentID3"];
        [demoController initializeWithBeaconDictionary:self.beaconDictionary];
        [[MFSideMenuManager sharedManager].navigationController pushViewController:demoController animated:YES];
    }
}

-(void) setDistanceLabelWithDistance:(NSString *)distance
{
    double dist = [[distance substringToIndex:[distance rangeOfString:@" "].location] doubleValue];
    if (dist < 1.5)
    {
        [self.nearbyBanner setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_nfp_nearbybanner.png"]]];
        [self resizeForNearbyBanner];
    }
    else
    {
        [self.nearbyBanner setBackgroundColor:[UIColor clearColor]];
    }
    [self.distanceLabel setText:distance];
}

-(void) resizeForNearbyBanner
{
    
}

@end
