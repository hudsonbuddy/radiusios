//
//  RadiusUserData.m
//  radius
//
//  Created by Hud on 12/12/12.
//
//

#import "RadiusUserData.h"

@implementation RadiusUserData

@synthesize followedBeacons;
@synthesize recentActivity;
@synthesize friends;
@synthesize asyncImageCache;

static RadiusUserData *instance = nil;


- (id) init
{
    self = [super init];
    if ( self )
    {
        // custom initialization goes here
    }
    
    return self;
}

+ (RadiusUserData *) sharedRadiusUserData {
    
    if ( instance == nil )
    {
        instance = [[self alloc] init];
    }
    
    return instance;
}

+ (void) resetRadiusUserData {

    instance = nil;
    
}




@end
