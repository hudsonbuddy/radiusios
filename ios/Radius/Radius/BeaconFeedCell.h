//
//  BeaconFeedCell.h
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "FeedCell.h"
#import <MapKit/MapKit.h>

@interface BeaconFeedCell : FeedCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) NSDictionary *beaconDictionary;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier beaconDictionary:(NSDictionary *)beaconDictionary;

@end
