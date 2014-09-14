//
//  ConversationThreadCreateEvent.h
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "RadiusEvent.h"

@interface ConversationThreadCreateEvent : RadiusEvent

@property (strong,nonatomic) NSDictionary *threadInfo;

@end
