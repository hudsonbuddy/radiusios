//
//  RadiusError.m
//  radius
//
//  Created by David Herzka on 11/9/12.
//
//

#import "RadiusError.h"

@implementation RadiusError

@synthesize message = _message;
@synthesize type = _type;
@synthesize errors = _errors;

-(id)initWithResponseObject:(NSDictionary *)responseObject
{
    self = [super init];
    if(self) {
        NSDictionary *error = [responseObject objectForKey:@"error"];
        self.message = [error objectForKey:@"message"];
        
        NSUInteger code = [[error objectForKey:@"code"] intValue];
        if(code > MAX_BACKEND_ERROR_CODE) {
            self.type = RadiusErrorUnknownError;
        } else {
            self.type = code;
        }

        if(self.type==RadiusErrorFormError) {
            self.errors = [error objectForKey:@"errors"];
        }
        
    }
    return self;
}

-(id)initWithType:(RadiusErrorType)type message:(NSString *)message
{
    self = [super init];
    if(self) {
        self.type = type;
        self.message = message;
    }
    return self;
}

@end
