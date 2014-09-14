//
//  Notification.m
//  radius
//
//  Created by David Herzka on 10/26/12.
//
//

#import "Notification.h"
#import "RadiusRequest.h"

@implementation Notification

+(id)notificationWithDictionary:(NSDictionary *)notificationDictionary
{
    RadiusEvent *event = [RadiusEvent eventWithDictionary:[notificationDictionary objectForKey:@"event"]];
    if(!event) return nil;
    
    Notification *notification = [[Notification alloc] init];
    notification.event = event;
        
    notification.id = [[notificationDictionary objectForKey:@"id"] intValue];
    notification.isRead = [[notificationDictionary objectForKey:@"is_read"] boolValue];
    
    return notification;
}

-(void)markRead
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.id],@"notifications", nil];
    RadiusRequest *request = [RadiusRequest requestWithParameters:params apiMethod:@"me/notifications/read" httpMethod:@"POST"];
    
    [request start];
}

@end
