//
//  BeaconAccessRequestEvent.m
//  radius
//
//  Created by David Herzka on 1/11/13.
//
//

#import "BeaconAccessRequestEvent.h"
#import "PrivacyManagerViewController.h"

@implementation BeaconAccessRequestEvent

-(UIViewController *)linkViewController
{
    PrivacyManagerViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PrivacyManagerID"];
    [vc setBeaconID:[self.beaconInfo objectForKey:@"id"]];
    
    return vc;

}

-(NSString *)notificationText
{
    return [NSString stringWithFormat:@"%@ requested access to %@",[self.performerInfo objectForKey:@"display_name"],[self.beaconInfo objectForKey:@"name"]];
}

@end
