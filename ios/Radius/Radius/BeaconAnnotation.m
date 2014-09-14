//
//  BeaconAnnotation.m
//  radius
//
//  Created by David Herzka on 10/2/12.
//
//

#import "BeaconAnnotation.h"

@implementation BeaconAnnotation

@synthesize coordinate,title,subtitle,beaconInfo;

-(id)initWithBeaconInfo:(NSDictionary *)beaconInfoDict {
    self = [super init];
    
    if(self) {
        self.beaconInfo = beaconInfoDict;
        
        CLLocationDegrees latitude= [[[self.beaconInfo objectForKey:@"center"] objectAtIndex:0]doubleValue];
        CLLocationDegrees longitude= [[[self.beaconInfo objectForKey:@"center"] objectAtIndex:1]doubleValue];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        self.title = [self.beaconInfo valueForKey:@"name"];
    }
    
    return self;
    
}

@end
