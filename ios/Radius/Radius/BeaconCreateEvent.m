//
//  BeaconCreateEvent.m
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "BeaconCreateEvent.h"
#import "BeaconContentViewController2.h"
#import "BeaconFeedCell.h"

@implementation BeaconCreateEvent

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    BeaconContentViewController2 *vc = [st instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [vc initializeWithBeaconDictionary:self.beaconInfo];
    return vc;
    
}


-(FeedCell *)newsFeedCellForTableView:(UITableView *)tableView imageCache:(id)imageCache
{
    NSString *cellIdentifier = @"BeaconCreateEventCell";
    BeaconFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BeaconFeedCell alloc] initWithReuseIdentifier:cellIdentifier beaconDictionary:self.beaconInfo];
    } else {
        cell.beaconDictionary = self.beaconInfo;
    }
    
    return cell;
}

-(CGFloat)newsFeedCellHeight
{
    return 140.0;
}


-(NSString *)recentActivityText
{
    return [NSString stringWithFormat:@"Created a new beacon"];
}

@end
