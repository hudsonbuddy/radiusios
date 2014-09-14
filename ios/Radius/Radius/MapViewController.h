//
//  MapViewController.h
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <QuartzCore/QuartzCore.h>
#import "Beacon.h"
#import "SBJson.h"
#import "BeaconContentViewController2.h"
#import "FindBeaconContent.h"
#import "RadiusViewController.h"
#import "CreateBeaconControllerViewController.h"
#import "PopupView.h"


@interface MapViewController : RadiusViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,UIGestureRecognizerDelegate> {
    
    CGFloat barVelocity;
    NSURLConnection *_connection;
    NSMutableData *jsonData;
    NSMutableDictionary *imageCache;
}

@property (strong, nonatomic) IBOutlet MKMapView *radiusmap;
@property (nonatomic, retain) NSMutableArray *mapAnnotations;
@property (strong, nonatomic) IBOutlet UIButton *mapDragButton;
@property (weak, nonatomic) IBOutlet UIButton *createNewBeaconButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UITableView *mapDragTableView;
@property (strong, nonatomic) IBOutlet UILabel *cityStateLabel;
@property (nonatomic, retain) CLLocationManager* locationManager;


- (IBAction)tableTouchUp:(id)sender withEvent:(UIEvent *) event;
- (IBAction)createNewBeaconPressed:(id)sender;
- (IBAction)refreshPressed:(id)sender;


-(void) moveTableUpWithVelocity:(CGFloat) velocity;
-(void) moveTableDownWithVelocity:(CGFloat) velocity;


@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSMutableArray *jsonArray;
-(void) populateTableView:(NSMutableArray *)myArray;
-(void) populateMapAnnotations: (NSMutableArray *)myArray;
@property (strong, nonatomic) IBOutlet UIButton *followedBeaconLeftOutlet;
@property (strong, nonatomic) IBOutlet UIButton *followedBeaconRightOutlet;
- (IBAction)followedBeaconLeftPressed:(id)sender;
- (IBAction)followedBeaconRightPressed:(id)sender;

@property (nonatomic, strong) NSMutableArray *followedBeaconsArray;
@property (nonatomic, strong) NSString *currentFollowedBeaconIndex;
@property (nonatomic, strong) CLLocation *discoverFollowedBeaconLocation;
@property (nonatomic, strong) NSNumber *beaconToSelect;

@property (nonatomic) BOOL initialLocationSet;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressCreateBeaconRecognizer;

@property (nonatomic) BOOL showSuggestions;


@end
