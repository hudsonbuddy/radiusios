//
//  ConversationReplyEvent.h
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "RadiusEvent.h"

@interface ConversationReplyEvent : RadiusEvent

@property (strong,nonatomic) NSDictionary *postInfo;
@property (strong,nonatomic) NSDictionary *threadInfo;

@end
