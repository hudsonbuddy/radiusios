//
//  BeaconFeedCell.m
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "BeaconFeedCell.h"
#import "BeaconAnnotation.h"

@interface BeaconFeedCell() {
    id<MKAnnotation> beaconPin;
}

@end

@implementation BeaconFeedCell

@synthesize beaconDictionary = _beaconDictionary;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
       
        
        
    }
    return self;
}

static const CLLocationDegrees SPAN_LONGITUDE = 0.006;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier beaconDictionary:(NSDictionary *)beaconDictionary
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"BeaconFeedCell" owner:self options:nil]; 
        
        self.backgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_nfp_beaconcell.png"]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.beaconDictionary = beaconDictionary;
        
        [self setupFonts];
        
    }
    return self;
}

-(void)setBeaconDictionary:(NSDictionary *)beaconDictionary
{
    CLLocationDegrees latitude= [[[beaconDictionary objectForKey:@"center"] objectAtIndex:0]doubleValue];
    CLLocationDegrees longitude= [[[beaconDictionary objectForKey:@"center"] objectAtIndex:1]doubleValue];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    
    
    
    MKCoordinateRegion region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.0,SPAN_LONGITUDE));
    
    region = [self.mapView regionThatFits:region];
    
    region.center.latitude += 0.25*region.span.latitudeDelta;
    
    self.mapView.region = region;

    [self.mapView removeAnnotation:beaconPin];
    
    beaconPin = [[BeaconAnnotation alloc] initWithBeaconInfo:beaconDictionary];
    [self.mapView addAnnotation:beaconPin];
}

-(void)setupFonts
{

    [self.timePostedLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
    [self.distanceLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
    [self.beaconNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
    [self.numberOfFollowersLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
    
    UIImage *pinImage = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
    annotationView.contentMode = UIViewContentModeScaleToFill;
    annotationView.image = pinImage;
    annotationView.frame = CGRectMake(0,0,44,44);
    annotationView.centerOffset = CGPointMake(0, -22);
    
    annotationView.draggable = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        BeaconAnnotation *beaconAnnotation = (BeaconAnnotation *)annotation;
        NSString * urlString = [beaconAnnotation.beaconInfo valueForKey:@"pin"];
        NSURL *imageURL = [NSURL URLWithString:urlString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *profilePictureForBeacon = [UIImage imageWithData:imageData];
        CGRect oldFrame = annotationView.frame;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            annotationView.image = profilePictureForBeacon;
            annotationView.frame = oldFrame;
        });
        
    });
    
    return annotationView;

}

@end
