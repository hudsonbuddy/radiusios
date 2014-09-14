//
//  BeaconAnnotation.h
//  radius
//
//  Created by David Herzka on 10/2/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BeaconAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSDictionary *beaconInfo;

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(id) initWithBeaconInfo:(NSDictionary *)beaconInfo;

@end
