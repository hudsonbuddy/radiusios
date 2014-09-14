//
//  BeaconAccessApproveEvent.m
//  radius
//
//  Created by David Herzka on 1/11/13.
//
//

#import "BeaconAccessApproveEvent.h"
#import "BeaconContentViewController2.h"

@implementation BeaconAccessApproveEvent

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    BeaconContentViewController2 *vc = [st instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [vc initializeWithBeaconDictionary:self.beaconInfo];
    
    return vc;
}

-(NSString *)notificationText
{
    return [NSString stringWithFormat:@"You have been approved to access %@",[self.beaconInfo objectForKey:@"name"]];
}

@end
