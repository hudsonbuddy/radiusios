//
//  CreateBeaconAnnotation.h
//  radius
//
//  Created by Hud on 10/18/12.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CreateBeaconAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;


@end
