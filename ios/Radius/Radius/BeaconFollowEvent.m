//
//  BeaconFollowEvent.m
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "BeaconFollowEvent.h"
#import "BeaconContentViewController2.h"

@implementation BeaconFollowEvent

-(id)initWithDictionary:(NSDictionary *)eventDictionary
{
    self = [super initWithDictionary:eventDictionary];
    if(self) {
        self.wasFollowed = [[[eventDictionary objectForKey:@"data"] objectForKey:@"followed"] boolValue];
    }
    return self;
}

-(NSString *)recentActivityText
{
    return [NSString stringWithFormat:@"%@ a beacon",self.wasFollowed?@"Followed":@"Unfollowd"];
}

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    BeaconContentViewController2 *vc = [st instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [vc initializeWithBeaconDictionary:self.beaconInfo];
    return vc;
}

@end
