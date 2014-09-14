//
//  CreateBeaconControllerViewController.h
//  Radius
//
//  Created by Hudson Duan on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import "Beacon.h"
#import "SBJson.h"
#import "MFSideMenu.h"
#import "PostBeaconTags.h"
#import "CreateBeaconAnnotation.h"
#import "RadiusViewController.h"

@interface CreateBeaconControllerViewController : RadiusViewController <MKMapViewDelegate> {
    
    NSMutableData *jsonData;
}

-(void)initializeWithLocation:(CLLocationCoordinate2D)location name:(NSString *)name googlePlaceReference:(NSString *)ref;
-(void)initializeWithLocation:(CLLocationCoordinate2D)location;

@property (strong, nonatomic) IBOutlet MKMapView *createMap;
@property (nonatomic, retain) CLLocationManager* locationManager;

@property (weak, nonatomic) IBOutlet UIView *beaconNameBackgroundView;
@property (strong, nonatomic) NSString *beaconNameString;
@property (strong, nonatomic) IBOutlet UITextField *beaconName;
- (IBAction)createDetailButton:(id)sender;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSMutableArray *jsonArray;
@property (nonatomic, strong) Beacon *createdBeacon;
@property (weak, nonatomic) IBOutlet UIButton *createBeaconButton;

@property (weak, nonatomic) IBOutlet UIView *descriptionBackgroundView;
@property (strong, nonatomic) IBOutlet UITextView *beaconDescriptionTextView;
@property (strong, nonatomic) NSString * beaconTagString;
@property (strong, nonatomic) NSString *userTokenString;

@property (weak, nonatomic) IBOutlet UIView *adjustSizeBackgroundView;
@property (strong, nonatomic) IBOutlet UIButton *switchMapTypeButton;
- (IBAction)switchMapTypeButtonPressed:(id)sender;

@property (nonatomic) CLLocationCoordinate2D location;

@property (nonatomic) MKMapPoint inputBeaconCenter;
@property (weak, nonatomic) NSString *googleRefToken;

@end
