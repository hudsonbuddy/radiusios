//
//  Notification.h
//  radius
//
//  Created by David Herzka on 10/26/12.
//
//

#import <Foundation/Foundation.h>
#import "RadiusEvent.h"

@interface Notification : NSObject

@property (strong,nonatomic) RadiusEvent *event;
@property (nonatomic) NSUInteger id;
@property (nonatomic) BOOL isRead;

+(id) notificationWithDictionary:(NSDictionary *)notificationDictionary;

-(void)markRead;

@end
