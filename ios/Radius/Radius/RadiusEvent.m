//
//  RadiusEvent.m
//  radius
//
//  Created by David Herzka on 10/26/12.
//
//

#import "RadiusEvent.h"
#import "CommentEvent.h"
#import "BeaconInviteEvent.h"
#import "ContentPostEvent.h"
#import "BeaconFollowEvent.h"
#import "ConversationReplyEvent.h"
#import "ConversationThreadCreateEvent.h"
#import "BeaconCreateEvent.h"
#import "BeaconAccessApproveEvent.h"
#import "BeaconAccessRequestEvent.h"

@implementation RadiusEvent

+(RadiusEvent *)eventWithDictionary:(NSDictionary *)eventDictionary {
    NSString *eventType = [eventDictionary objectForKey:@"type"];
    
    Class eventClass = nil;
    if([eventType isEqualToString:@"CommentEvent"]) {
        eventClass = [CommentEvent class];
    } else if([eventType isEqualToString:@"BeaconInviteEvent"]) {
        eventClass = [BeaconInviteEvent class];
    } else if ([eventType isEqualToString:@"ContentPostEvent"]) {
        eventClass = [ContentPostEvent class];
    } else if ([eventType isEqualToString:@"BeaconFollowEvent"]) {
        eventClass = [BeaconFollowEvent class];
    } else if ([eventType isEqualToString:@"ConversationReplyEvent"]) {
        eventClass = [ConversationReplyEvent class];
    } else if ([eventType isEqualToString:@"ConversationThreadCreateEvent"]) {
        eventClass = [ConversationThreadCreateEvent class];
    } else if ([eventType isEqualToString:@"BeaconCreateEvent"]) {
        eventClass = [BeaconCreateEvent class];
    } else if ([eventType isEqualToString:@"BeaconAccessRequestEvent"]) {
        eventClass = [BeaconAccessRequestEvent class];
    } else if ([eventType isEqualToString:@"BeaconAccessApproveEvent"]) {
        eventClass = [BeaconAccessApproveEvent class];
    }
        
    if(!eventClass) return nil;
    
    RadiusEvent *event = [[eventClass alloc] initWithDictionary:eventDictionary];
    return event;
    
}

-(id)initWithDictionary:(NSDictionary *)eventDictionary {
    self = [self init];
    if(self) {
        self.performerInfo = [eventDictionary objectForKey:@"performer"];
        self.beaconInfo = [eventDictionary objectForKey:@"beacon"];
        self.timestamp = [[eventDictionary objectForKey:@"timestamp"] intValue];
        self.eventID = [[eventDictionary objectForKey:@"id"] integerValue];
    }
    return self;
}

-(FeedCell *)newsFeedCellForTableView:(UITableView *)tableView imageCache:(id)imageCache {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(CGFloat)newsFeedCellHeight {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString *)notificationText {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString *)recentActivityText {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(UIViewController *)linkViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString *) eventImageURL
{
    return nil;
}

@end
