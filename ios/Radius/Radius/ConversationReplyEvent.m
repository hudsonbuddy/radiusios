//
//  ConversationReplyEvent.m
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "ConversationReplyEvent.h"
#import "ConvoThreadViewController.h"

@implementation ConversationReplyEvent

-(id)initWithDictionary:(NSDictionary *)eventDictionary
{
    self = [super initWithDictionary:eventDictionary];
    if(self) {
        self.postInfo = [[eventDictionary objectForKey:@"data"] objectForKey:@"post"];
        self.threadInfo = [[eventDictionary objectForKey:@"data"] objectForKey:@"thread"];
    }
    return self;
}

-(NSString *)notificationText
{
    return [NSString stringWithFormat:@"%@ replied to your post in the thread \"%@\"",[self.performerInfo objectForKey:@"display_name"],[self.threadInfo objectForKey:@"title"]];
}

-(NSString *)recentActivityText
{
    return [NSString stringWithFormat:@"Posted a reply to the thread \"%@\"",[self.threadInfo objectForKey:@"title"]];
}

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    ConvoThreadViewController *threadController = [st instantiateViewControllerWithIdentifier:@"convoThreadID"];
    
    [threadController initializeWithThreadID:[[self.threadInfo objectForKey:@"id"] integerValue] threadTitle:[self.threadInfo objectForKey:@"title"] beaconName:[self.beaconInfo objectForKey:@"name"] beaconID:[[self.beaconInfo objectForKey:@"id"] integerValue]];
    
    return threadController;
}

@end
