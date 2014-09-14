//
//  CreateBeaconAnnotation.m
//  radius
//
//  Created by Hud on 10/18/12.
//
//

#import "CreateBeaconAnnotation.h"

@implementation CreateBeaconAnnotation
@synthesize coordinate = _coordinate;
@synthesize title,subtitle;

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}


@end
