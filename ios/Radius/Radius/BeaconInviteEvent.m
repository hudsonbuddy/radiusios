//
//  BeaconInviteEvent.m
//  radius
//
//  Created by David Herzka on 10/27/12.
//
//

#import "BeaconInviteEvent.h"
#import "BeaconContentViewController2.h"

@interface BeaconInviteEvent() 

@end

@implementation BeaconInviteEvent

-(NSString *)notificationText
{
    NSString *displayNameString = [self.performerInfo objectForKey:@"display_name"];
    
    NSString *beaconName = [self.beaconInfo objectForKey:@"name"];
    
    NSString *text = [NSString stringWithFormat:@"%@ invited you to check out %@", displayNameString, beaconName];
    
    return text;
}

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];

    BeaconContentViewController2 *vc = [st instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [vc initializeWithBeaconDictionary:self.beaconInfo];
    return vc;
    
}


@end
