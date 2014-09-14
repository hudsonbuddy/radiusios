//
//  MapViewController.m
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "MFSideMenu.h"
#import "SBJson.h"
#import "BeaconContentViewController2.h"
#import "Beacon.h"
#import "BeaconAnnotation.h"
#import "RadiusRequest.h"
#import "RadiusAppDelegate.h"
#import "CreateBeaconControllerViewController.h"
#import "NotificationsWindow.h"
#import "CreateCheckExistingViewController.h"
#import "BeaconSuggestionsView.h"


@interface MapViewController () {
    CLAuthorizationStatus lastAuthorizationStatus;
    UIView *warningView;
    
    NSDate *lastRefresh;
    NSDate *lastMove;
    NSCache *pinCache;
    RadiusRequest *lastRefreshRequest;
    
    NSDate *locationStartDate;
    NSString *cityStateString;

    BOOL firstTimeLoadingMap;
    UIView *noResultsView;
    
    MKAnnotationView *createPin;
    RadiusUserData *userData;
}

@end

@implementation MapViewController


@synthesize mapDragButton;
@synthesize createNewBeaconButton;
@synthesize mapDragTableView;
@synthesize locationManager;
@synthesize radiusmap;
@synthesize mapAnnotations;
@synthesize jsonData, jsonArray;
@synthesize refreshButton;
@synthesize followedBeaconLeftOutlet, followedBeaconRightOutlet;
@synthesize followedBeaconsArray;
@synthesize currentFollowedBeaconIndex;
@synthesize discoverFollowedBeaconLocation;
@synthesize initialLocationSet;
@synthesize cityStateLabel;
@synthesize longPressCreateBeaconRecognizer;
@synthesize showSuggestions;

static const double MOVING_REFRESH_PERIOD = 2.0; // number of seconds between map refreshes while the map is being dragged
static const double IDLE_THRESHOLD = 0.5; // number of seconds of no map movement that indicate the map is idle

static const CLLocationAccuracy DESIRED_ACCURACY = 10;
static const CLLocationAccuracy ALLOWED_ACCURACY = 20;
static const NSTimeInterval MAX_LOCATE_TIME = 5;

static const CGRect ANNOTATION_FRAME = (CGRect){.size={60,60}};
static const CGFloat BEACON_PIN_ANNOTATION_VIEW = 678;
static const CGFloat CREATE_PIN_ANNOTATION_VIEW = 876;
static const CGFloat NO_RESULTS_VIEW_TAG = 1000;

static const NSInteger SUGGESTION_LIST_TAG = 12412;

static const CLLocationDegrees DEFAULT_LATITUDE = 36.005507;
static const CLLocationDegrees DEFAULT_LONGITUDE = -78.914366;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self setupSideMenuBarButtonItem];
    firstTimeLoadingMap = YES;
    [self setupNoResultsView];

    userData = [RadiusUserData sharedRadiusUserData];

    [self.radiusmap setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = DESIRED_ACCURACY;

    lastAuthorizationStatus = [CLLocationManager authorizationStatus];
    if (lastAuthorizationStatus != kCLAuthorizationStatusAuthorized) {
        [self showNoLocationServicesWarning];
        
        if (lastAuthorizationStatus == kCLAuthorizationStatusNotDetermined) {
            [locationManager startUpdatingLocation];
        }
        
        //return;
    } else {
        [self dismissNoLocationServicesWarning];
    }
    
    [radiusmap setDelegate:self];

    UIPanGestureRecognizer *mapDragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mapDragged)];
    mapDragRecognizer.delegate = self;
    [self.radiusmap addGestureRecognizer:mapDragRecognizer];
    
    
    UIPinchGestureRecognizer *mapZoomRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(mapDragged)];
    mapZoomRecognizer.delegate = self;
    [self.radiusmap addGestureRecognizer:mapZoomRecognizer];
    
    
    UIPanGestureRecognizer *tableDragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tableDragged:)];
	[tableDragRecognizer setMinimumNumberOfTouches:1];
	[tableDragRecognizer setMaximumNumberOfTouches:1];
	[tableDragRecognizer setDelegate:nil];
	[mapDragButton addGestureRecognizer:tableDragRecognizer];
    
    [self initializeTableView];
    [self setupLongPressCreateBeacon];
    self.mapDragTableView.alpha = 1;
        
    [self moveTableMiddleWithVelocity:3];
    
    imageCache = [[NSMutableDictionary alloc] init];
    //    [self.view bringSubviewToFront:mapDragButton];
    //    [self.view bringSubviewToFront:mapDragTableView];
    //    SFAnnotation *sfAnnotation = [[SFAnnotation alloc] init];
    //    [self.mapAnnotations insertObject:sfAnnotation atIndex:0];
    //    [self.radiusmap addAnnotations:self.mapAnnotations];
    if (discoverFollowedBeaconLocation) {
        
        [self setLocation:discoverFollowedBeaconLocation animated:YES];
        
    }else{
        if(locationManager.location) {
            [self setLocation:locationManager.location animated:NO];
            initialLocationSet = YES;
            [self findBeaconsInBounds:YES];
        } else {
            [self setLocation:[[CLLocation alloc] initWithLatitude:DEFAULT_LATITUDE longitude:DEFAULT_LONGITUDE] animated:NO showLocation:NO];
        }
    }
        
    [locationManager startUpdatingLocation];
    locationStartDate = [NSDate date];
    
    [self setupFollowedCycleButtons];
        
    if(self.showSuggestions) {
    
        BeaconSuggestionsView *suggestionsPopup = [[BeaconSuggestionsView alloc] init];
        
        // create a container for the popup that includes the height of the nav bar
        // so that popup is vertically centered and belongs to current view controller
        // (so it doesn't stay on top of newly pushed VCs)
        UIView *container = [[UIView alloc] initWithFrame:CGRectOffset([UIScreen mainScreen].bounds, 0, -self.navigationController.navigationBar.frame.size.height)];
        [self.view addSubview:container];
        
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
            [container removeFromSuperview];
        };
        
        [MFSlidingView slideView:suggestionsPopup intoView:container onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
    }

    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if(!initialLocationSet) {
        CLLocation *l = newLocation;
        
        // Check if we have an accurate reading yet, as defined by ALLOWED_ACCURACY.
        // If this process takes longer than MAX_LOCATE_TIME, just use whatever value we have.
        if(l.horizontalAccuracy > ALLOWED_ACCURACY &&
           [[NSDate date] timeIntervalSinceDate:locationStartDate] <= MAX_LOCATE_TIME) {
            NSLog(@"not accurate enough yet");
            return;
        }
        
        [self setLocation:l animated:NO];
        [self findBeaconsInBounds];
        initialLocationSet = YES;
    }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(!initialLocationSet) {
        CLLocation *l = [locations objectAtIndex:0];
        
        // Check if we have an accurate reading yet, as defined by ALLOWED_ACCURACY.
        // If this process takes longer than MAX_LOCATE_TIME, just use whatever value we have.
        if(l.horizontalAccuracy > ALLOWED_ACCURACY &&
           [[NSDate date] timeIntervalSinceDate:locationStartDate] <= MAX_LOCATE_TIME) {
            NSLog(@"not accurate enough yet");
            return;
        }
        
        [self setLocation:l animated:NO];
        [self findBeaconsInBounds];
        initialLocationSet = YES;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    if(error.code == kCLErrorDenied) {
        [self showNoLocationServicesWarning];
    }
}

-(void)showNoLocationServicesWarning {
    
    
    //[self setLocation:[[CLLocation alloc] initWithLatitude:DEFAULT_LATITUDE longitude:DEFAULT_LONGITUDE] animated:NO showLocation:NO];
    
//    if(warningView) return;
//    
//    UIImageView *warningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgd_enablelocation.png"]];
//    
//    warningView = warningImageView;
//    
//    [self.view addSubview:warningView];
    
}

-(void)dismissNoLocationServicesWarning {
    if(!warningView) return;
    
    [warningView removeFromSuperview];
    warningView = nil;
}
           
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(status!=lastAuthorizationStatus) {
        initialLocationSet = NO;
        [self viewDidLoad];
    }
}

-(void) setupAddBeaconButton
{
    UIImage *addImage = [UIImage imageNamed:@"ico_create.png"];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.bounds = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.height);
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(transitionToAddBeacon) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addButtonItem;
}
-(void) createTableHeader
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    label.backgroundColor = [UIColor redColor];
    label.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
    //label.shadowColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.text = @"Create a beacon!";
    mapDragTableView.tableHeaderView = label;
}

-(void) transitionToAddBeacon
{
    CreateCheckExistingViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"createCheckExistingID"];
    [demoController setTitle:@"Create"];
    [self.navigationController pushViewController:demoController animated:YES];
}

-(void) setLocation:(CLLocation *)location animated:(BOOL)animated
{
    [self setLocation:location animated:animated showLocation:YES];
}

-(void) setLocation:(CLLocation *)location animated:(BOOL)animated showLocation:(BOOL)showLabel
{
    
    
    MKCoordinateRegion region;
    region.center.latitude= location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.longitudeDelta = 0.01149;
    region.span.latitudeDelta= 0.009863;
    [self.radiusmap setRegion:region animated:animated];
    radiusmap.showsUserLocation = YES;
    [self findAndSelectBeaconAtCenter];
    
    if(showLabel) {
        [self reverseGeocodeFollowedBeaconCenterWithLocation:location];
    }

}

-(void) findBeaconsInBounds {
    [self findBeaconsInBounds:NO];
}

-(void) findBeaconsInBounds:(BOOL)sensor {
    
    MKCoordinateRegion r = radiusmap.region;
    
    // offset to include beacons whose symbols extend into the viewport
    CGFloat pixelsPerLatitudeDegree = radiusmap.frame.size.height / r.span.latitudeDelta;
    CGFloat pixelsPerLongitudeDegree = radiusmap.frame.size.width / r.span.longitudeDelta;
    
    CGFloat latOffset = ANNOTATION_FRAME.size.height / pixelsPerLatitudeDegree; // only apply to south boundary
    CGFloat lngOffset = (ANNOTATION_FRAME.size.width / pixelsPerLongitudeDegree)/2; // apply to east and west boundaries
    
    NSString *bbox = [NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", r.center.longitude-r.span.longitudeDelta/2-lngOffset,
                                                                        r.center.latitude-r.span.latitudeDelta/2-latOffset,
                                                                        r.center.longitude+r.span.longitudeDelta/2+lngOffset,
                                                                        r.center.latitude+r.span.latitudeDelta/2];
    
    NSString *sensorString = sensor?@"true":@"false";
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:bbox, @"bbox",sensorString,@"sensor",nil] apiMethod:@"beacon/in_bbox"];
    NSDate *myStartDate = [NSDate date];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         
         if(error || radRequest != lastRefreshRequest) return;
         
         firstTimeLoadingMap = NO;
         self.jsonArray = response;
         [self populateTableView:jsonArray];
         [self populateMapAnnotations:jsonArray];
         
         if ([response count]>0) {
             [self hideNoResultsView];
             
             if(([mapDragTableView numberOfSections] > 0) && ([mapDragTableView numberOfRowsInSection:0] > 0)) {
                 NSIndexPath *myPath = [NSIndexPath indexPathForRow:0 inSection:0];
                 [mapDragTableView selectRowAtIndexPath:myPath animated:NO scrollPosition:UITableViewScrollPositionTop];
             }
             NSTimeInterval myTime = [[NSDate date] timeIntervalSinceDate:myStartDate];
             NSLog(@"my timer: %f", myTime);
         }else{             
             [self showNoResultsView];
         }

         
     }];
    lastRefreshRequest = radRequest;
}



-(void) populateMapAnnotations: (NSMutableArray *)myArray; {
    
    self.jsonArray = myArray;
    
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] init];
    NSMutableIndexSet *beaconIndexesAlreadyAnnotated = [[NSMutableIndexSet alloc] init];
    
    for(BeaconAnnotation *b in radiusmap.annotations) {
        if(![b isKindOfClass:[BeaconAnnotation class]]) continue;
        
        BOOL keep = NO;
        for(int i = 0; i < [jsonArray count]; i++) {
            NSDictionary *beaconInfo = [jsonArray objectAtIndex:i];
            if([[b.beaconInfo objectForKey:@"id"] isEqual:[beaconInfo objectForKey:@"id"]]) {
                keep = YES;
                [beaconIndexesAlreadyAnnotated addIndex:i];
                break;
            }
        }
        if(!keep) {
            [annotationsToRemove addObject:b];
        }
    }
    [radiusmap removeAnnotations:annotationsToRemove];
    
    
    dispatch_queue_t async_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    for (int i = 0; i < [jsonArray count]; i++) {
        
        if([beaconIndexesAlreadyAnnotated containsIndex:i]) continue;
        
        NSDictionary *beaconInfo = [jsonArray objectAtIndex:i];
        
        dispatch_async(async_queue, ^{
            BeaconAnnotation *annotation = [[BeaconAnnotation alloc] initWithBeaconInfo:beaconInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                [radiusmap addAnnotation:annotation];
            });
        });
    }
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    

    
    if([annotation isKindOfClass: [MKUserLocation class]]){
        
        return nil;
        
    }else if (![annotation isKindOfClass:[CreateBeaconAnnotation class]]) {
        
        if(![annotation respondsToSelector:@selector(beaconInfo)]) {
            NSLog(@"not a BeaconAnnotation");
        }
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Beacon"];
        if(!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Beacon"];
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.frame = CGRectMake(0, 0, 23, 23);
        annotationView.rightCalloutAccessoryView = button;
        
        if(!pinCache) pinCache = [[NSCache alloc] init];
        
        BeaconAnnotation *beaconAnnotation = (BeaconAnnotation *)annotation;
        NSString * urlString = [beaconAnnotation.beaconInfo valueForKey:@"pin"];
        UIImage *pinImage = [pinCache objectForKey:urlString];
        if(pinImage) {
            annotationView.image = pinImage;
        } else {
            annotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(queue, ^{
                
                NSURL *imageURL = [NSURL URLWithString:urlString];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:imageData];
                
                if(image) {
                    [pinCache setObject:image forKey:urlString];
                    CGRect oldFrame = annotationView.frame;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        annotationView.image = image;
                        annotationView.frame = oldFrame;
                    });
                }
                
            });
            
        }
        annotationView.frame = ANNOTATION_FRAME;
        annotationView.centerOffset = CGPointMake(0, -30);
        annotationView.tag = BEACON_PIN_ANNOTATION_VIEW;
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;   
                
        return annotationView;
    }else{
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Create"];
        if(!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Create"];
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.frame = CGRectMake(0, 0, 23, 23);
        annotationView.rightCalloutAccessoryView = button;
        annotationView.tag = CREATE_PIN_ANNOTATION_VIEW;
        annotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
        annotationView.centerOffset = CGPointMake(0, -30);
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        
        createPin = annotationView;
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeCreatePin)];
        tgr.numberOfTapsRequired=2;
        [createPin addGestureRecognizer:tgr];
        
        return annotationView;
    }
    
}

-(void)removeCreatePin
{
    if(createPin) {
        [self.radiusmap removeAnnotation:createPin.annotation];
        createPin = nil;
    }
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *aV in views) {
        CGRect endFrame = aV.frame;
        aV.frame = CGRectOffset(endFrame, 0, -230);
        NSTimeInterval delay = .5 * ((rand()%1000) / 999.0f);
        [UIView animateWithDuration:0.45 delay:delay options:UIViewAnimationOptionCurveEaseOut  animations:^{
            aV.frame = endFrame;
        } completion:^(BOOL finished){
            
            [self findAndSelectBeaconAtCenter];
        
        }];
    }
}


-(UIImage*)imageWithImage:(UIImage*)image
             scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)squareImageWithColor:(UIColor *)color withSideLength:(CLLocationDistance)sideLength{
    CGRect rect = CGRectMake(0.0, 0.0, sideLength, sideLength);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if (view.tag == BEACON_PIN_ANNOTATION_VIEW) {
    
    BeaconContentViewController2 *beaconViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [beaconViewController initializeWithBeaconDictionary:[(BeaconAnnotation *)view.annotation beaconInfo]];
    
    [self.navigationController pushViewController:beaconViewController animated:YES];
        
    }else if (view == createPin){
        
//        CreateBeaconControllerViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewID"];
//        [newViewController setTitle:@"Create"];
//        newViewController.hasGoogleFacebookLocation = NO;
////        newViewController.inputBeaconCenter = MKMapPointForCoordinate([view.annotation coordinate]);
//        newViewController.inputBeaconCenter = MKMapPointMake([view.annotation coordinate].latitude, [view.annotation coordinate].longitude);
//        newViewController.sendingGoogleFacebookLocation = [view.annotation coordinate];
//        newViewController.hasGoogleFacebookLocation = YES;
//        [self.navigationController pushViewController:newViewController animated:YES];
        CreateCheckExistingViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createCheckExistingID"];
        newViewController.location = [[CLLocation alloc] initWithCoordinate:[view.annotation coordinate] altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
        [self.navigationController pushViewController:newViewController animated:YES];
        
        
    }
    
}



#pragma Table View Stuff

-(void) initializeTableView {
//    self.mapDragTableView = [mapDragTableView initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    self.mapDragTableView.backgroundColor = [UIColor clearColor];
    self.mapDragTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture60.png"]];
    mapDragTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    mapDragTableView.delegate = self;
    mapDragTableView.dataSource = self;
}


-(void) populateTableView:(NSMutableArray *)myArray {
    self.jsonArray = myArray;
    [mapDragTableView reloadData];
    //[self createTableHeader];
    
    //    [self populateMapAnnotations];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return [jsonArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// params should contain two key/value pairs: "cell", the cell to load the image to, and "urlString", the URL of the image to load
- (void)loadImage:(NSDictionary *)params
{
    NSString *urlString = [params objectForKey:@"urlString"];
    UITableViewCell *cell = [params objectForKey:@"cell"];
    UIActivityIndicatorView *activityIndicatorView = [params objectForKey:@"activityIndicatorView"];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:(CGRect){.size={60, 60}}];
    if(![urlString isEqualToString:@""]) {
        UIImage *image = [imageCache objectForKey:urlString];
        if(!image) {
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            NSLog(@"downloading cell image");
            
            image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
            if(!image) {
                NSLog(@"null image");
                
            }
            if(image) {
                [imageCache setObject:image forKey:urlString];
            }
        }
        iv.image = image;
    } else {
        iv.image = [UIImage imageNamed:@"ico_defaultbeacon.png"];
    }
    iv.contentMode =  UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    
    dispatch_async(dispatch_get_main_queue(),^{
        [activityIndicatorView removeFromSuperview];
        [cell.contentView addSubview:iv];
    });
}

- (void)loadImage:(NSString *)urlString toCell:(UITableViewCell *)cell andStopActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView
{
    
    [self performSelectorInBackground:@selector(loadImage:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"cell",urlString,@"urlString",activityIndicatorView,@"activityIndicatorView",nil]];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:(CGRect){.size={60, 60}}];
    iv.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:iv];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.frame = iv.frame;
    [cell.contentView addSubview:aiv];
    [aiv startAnimating];
    
    cell.textLabel.text = [[jsonArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13.0];
    NSUInteger numFollowers = [[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"num_followers"] integerValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d follower%@",numFollowers,numFollowers!=1?@"s":@""];
    cell.indentationWidth = 60.0;
    cell.indentationLevel = 1;
    
    NSMutableString *urlString = nil;
    if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"picture_thumb"] isKindOfClass:[NSString class]])
    {
        urlString = [[jsonArray objectAtIndex:indexPath.row] objectForKey:@"picture_thumb"];
    } else {
        urlString = [NSMutableString stringWithString:@""];
    }

    [self loadImage:urlString toCell:cell andStopActivityIndicatorView:aiv];
        
    //    //Request the most recent content posted in each beacon to populate that information in each cell
    //    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"id"], @"beacon", @"1", @"num_results", nil] apiMethod:@"beacon_content"];
    //    [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
    //     {
    //         if ([response count]>0)
    //         {
    //             NSDictionary *beaconDict = [response objectAtIndex:0];
    //             NSLog(@"returning: %@", beaconDict);
    //             NSMutableString *sublabelText = [NSMutableString stringWithString:@""];
    //             if ([[beaconDict objectForKey:@"type"] isEqualToString:@"text"])
    //             {
    //                 [sublabelText appendString:[NSString stringWithFormat:@"%@ ",[[beaconDict objectForKey:@"content"] objectForKey:@"text"]]];
    //                 cell.imageView.image = [UIImage imageNamed:@"ico_text.png"];
    //             }
    //             else if ([[beaconDict objectForKey:@"type"] isEqualToString:@"image"])
    //             {
    //                 //TODO - add some kind of intelligent title for images
    //                 NSMutableString *urlString = [[[beaconDict objectForKey:@"content"] objectForKey:@"url"] mutableCopy];
    //                 [urlString replaceCharactersInRange:[urlString rangeOfString:@".us/"] withString:@".us/th_"];
    //                 NSURL *url = [NSURL URLWithString:urlString];
    //                 cell.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    //             }
    //             else if ([[beaconDict objectForKey:@"type"] isEqualToString:@"video_ext"])
    //             {
    //                 if ([[[beaconDict objectForKey:@"content"] objectForKey:@"site"] isEqualToString:@"youtube"])
    //                 {
    //                     NSLog(@"getting to video logic");
    //                     //Constructing the YouTube thumbnail URL
    //                     //The second parameter lets you get one of a few thumbnails, #2 is default
    //                     NSString *urlString = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/%@.jpg", [[beaconDict objectForKey:@"content"] objectForKey:@"video_id"], @"2"];
    //                     NSLog(@"youtube url is: %@", urlString);
    //                     NSURL *url = [NSURL URLWithString:urlString];
    //                     cell.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    //                     NSString *urlTitleString = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@?v=2", [[beaconDict objectForKey:@"content"] objectForKey:@"video_id"] ];
    //                     NSURLRequest *youTubeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlTitleString]];
    //                     [NSURLConnection sendAsynchronousRequest:youTubeRequest queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    //                     {
    //                         NSLog(@"sweet bro youtube response: %@", response);
    //                         NSLog(@"sweet bro youtube data: %@", data);
    //                         NSLog(@"sweet bro youtube error: %@", error);
    //                     }];
    //                 }
    //             }
    //             //Append the poster name to the subtext
    //             if ([beaconDict objectForKey:@"poster"])
    //             {
    //                 [sublabelText appendString:[NSString stringWithFormat:@"posted by %@",[beaconDict objectForKey:@"poster"]]];
    //             }
    //             cell.detailTextLabel.text = sublabelText;
    //             [cell.detailTextLabel setFont: [UIFont fontWithName:@"Quicksand" size:13]];
    //         }
    //     }];
    
    
    return cell;
}

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BeaconContentViewController2 *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];    
    [demoController initializeWithBeaconDictionary:[jsonArray objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:demoController animated:YES];
    
    
}


#pragma mark Table Movement


-(void) tableDragged: (id)sender {
    self.mapDragTableView.alpha = 1;
    CGPoint point = [(UIPanGestureRecognizer*)sender locationInView:self.view];
    if (point.y>=0 && point.y<=self.view.frame.size.height) {
        mapDragButton.frame = CGRectMake(mapDragButton.frame.origin.x,
                                         point.y,
                                         mapDragButton.frame.size.width,
                                         mapDragButton.frame.size.height);
        createNewBeaconButton.frame = CGRectMake(createNewBeaconButton.frame.origin.x,
                                                 point.y+mapDragButton.frame.size.height-createNewBeaconButton.frame.size.height,
                                                 createNewBeaconButton.frame.size.width,
                                                 createNewBeaconButton.frame.size.height);
        
        followedBeaconLeftOutlet.frame = CGRectMake(followedBeaconLeftOutlet.frame.origin.x,
                                                 point.y+mapDragButton.frame.size.height-followedBeaconLeftOutlet.frame.size.height,
                                                 followedBeaconLeftOutlet.frame.size.width,
                                                 followedBeaconLeftOutlet.frame.size.height);
        
        followedBeaconRightOutlet.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width+refreshButton.frame.size.width,
                                                    point.y+mapDragButton.frame.size.height-followedBeaconRightOutlet.frame.size.height,
                                                    followedBeaconRightOutlet.frame.size.width,
                                                    followedBeaconRightOutlet.frame.size.height);
        
        refreshButton.frame = CGRectMake(refreshButton.frame.origin.x,
                                         point.y+mapDragButton.frame.size.height-refreshButton.frame.size.height,
                                         refreshButton.frame.size.width,
                                         refreshButton.frame.size.height);
        
        mapDragTableView.frame = CGRectMake(0, (mapDragButton.frame.size.height+point.y), self.view.frame.size.width, 460);
    }
    CGFloat navHeight = self.navigationController.navigationBarHidden ? 0 :
    self.navigationController.navigationBar.frame.size.height;
    CGFloat middleHeight = [UIScreen mainScreen].applicationFrame.size.height - navHeight-(60*2.6);
    NSLog(@"%f", middleHeight);
    barVelocity = [(UIPanGestureRecognizer*)sender velocityInView:self.view].y;
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if (point.y<=self.view.frame.size.height - 120 && point.y>=120) {
            [self moveTableMiddleWithVelocity:barVelocity];
        }
        else {
            
            if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
                if(barVelocity<0) {
                    [self moveTableUpWithVelocity:barVelocity];
                }else if(barVelocity>0){
                    [self moveTableDownWithVelocity:barVelocity];
                }else if(barVelocity==0 && point.y<150) {
                    [self moveTableUpWithVelocity:0];
                }else{
                    [self moveTableDownWithVelocity:0];
                }
            }
        }
    }
    
}



- (IBAction)tableTouchUp:(id)sender withEvent:(UIEvent *) event{
    self.mapDragTableView.alpha = 1;
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    mapDragButton = sender;
    if(point.y<200) {
        [self moveTableDownWithVelocity:0];
    }else{
        [self moveTableUpWithVelocity:0];
    }
    
}

-(void) moveTableUpWithVelocity:(CGFloat)velocity{
    float animationTime;
    float distance = mapDragButton.frame.origin.y;
    if((velocity==0) || (distance/fabs(velocity))>0.5) {
        animationTime = 0.5;
    }else{
        animationTime = distance/fabs(velocity);
    }
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:animationTime];

    mapDragButton.frame = CGRectMake(self.view.frame.size.width-mapDragButton.frame.size.width, 0, mapDragButton.frame.size.width, mapDragButton.frame.size.height);
    refreshButton.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width,mapDragButton.frame.size.height-refreshButton.frame.size.height,refreshButton.frame.size.width,refreshButton.frame.size.height);
    createNewBeaconButton.frame = CGRectMake(refreshButton.frame.size.width, mapDragButton.frame.size.height-createNewBeaconButton.frame.size.height, createNewBeaconButton.frame.size.width, createNewBeaconButton.frame.size.height);
    followedBeaconLeftOutlet.frame = CGRectMake(0, mapDragButton.frame.size.height-followedBeaconLeftOutlet.frame.size.height, followedBeaconLeftOutlet.frame.size.width, followedBeaconLeftOutlet.frame.size.height);
    followedBeaconRightOutlet.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width+refreshButton.frame.size.width, mapDragButton.frame.size.height-followedBeaconRightOutlet.frame.size.height, followedBeaconRightOutlet.frame.size.width, followedBeaconRightOutlet.frame.size.height);
    
    
    
    self.mapDragTableView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
    
    self.mapDragButton.alpha = 1;
    self.createNewBeaconButton.alpha = 1;
    self.refreshButton.alpha = 1;
    self.followedBeaconLeftOutlet.alpha = 1;
    self.followedBeaconRightOutlet.alpha = 1;
    //[mapDragButton setTitle:@"Drag Down to Hide Beacons" forState:UIControlStateNormal];
    [UIView commitAnimations];
    //    [NSTimer scheduledTimerWithTimeInterval:animationTime target:self
    //                                   selector:@selector(changeToArrow:)
    //                                   userInfo:nil repeats:NO];
}

-(void) moveTableMiddleWithVelocity:(CGFloat)velocity{
    float animationTime;
    float distance = mapDragButton.frame.origin.y;
    if((velocity==0) || (distance/fabs(velocity))>0.5) {
        animationTime = 0.5;
    }else{
        animationTime = distance/fabs(velocity);
    }
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:animationTime];
    //    mapDragButton.frame = CGRectMake(0, 244, mapDragButton.frame.size.width, mapDragButton.frame.size.height);
    CGFloat navHeight = self.navigationController.navigationBarHidden ? 0 :
    self.navigationController.navigationBar.frame.size.height;
    CGFloat middleHeight = [UIScreen mainScreen].applicationFrame.size.height - navHeight-(60*2.6);
    
    
    
    mapDragButton.frame = CGRectMake(self.view.frame.size.width-mapDragButton.frame.size.width, middleHeight-mapDragButton.frame.size.height, mapDragButton.frame.size.width, mapDragButton.frame.size.height);
    refreshButton.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width, middleHeight-refreshButton.frame.size.height, refreshButton.frame.size.width, refreshButton.frame.size.height);
    createNewBeaconButton.frame = CGRectMake(refreshButton.frame.size.width, middleHeight-createNewBeaconButton.frame.size.height, createNewBeaconButton.frame.size.width, createNewBeaconButton.frame.size.height);
    followedBeaconLeftOutlet.frame = CGRectMake(0, middleHeight-followedBeaconLeftOutlet.frame.size.height, followedBeaconLeftOutlet.frame.size.width, followedBeaconLeftOutlet.frame.size.height);
    followedBeaconRightOutlet.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width+refreshButton.frame.size.width, middleHeight-followedBeaconRightOutlet.frame.size.height, followedBeaconRightOutlet.frame.size.width, followedBeaconRightOutlet.frame.size.height);
    
    
    self.mapDragTableView.frame = CGRectMake(0, middleHeight, self.view.frame.size.width, self.view.frame.size.height-middleHeight);
    self.mapDragButton.alpha = 1;
    self.createNewBeaconButton.alpha = 1;
    self.refreshButton.alpha = 1;
    self.followedBeaconLeftOutlet.alpha = 1;
    self.followedBeaconRightOutlet.alpha = 1;

    
    //[mapDragButton setTitle:@"Drag Up to Show More Beacons" forState:UIControlStateNormal];
    [UIView commitAnimations];
    //    [NSTimer scheduledTimerWithTimeInterval:animationTime target:self
    //                                   selector:@selector(changeToArrow:)
    //                                   userInfo:nil repeats:NO];
}

-(void) moveTableDownWithVelocity:(CGFloat)velocity {
    float animationTime;
    float distance = fabs(mapDragButton.frame.origin.y - self.view.frame.size.height);
    if((velocity==0) || (distance/fabs(velocity))>0.5) {
        animationTime = 0.5;
    }else{
        animationTime = distance/fabs(velocity);
    }
    
    [UIView beginAnimations:@"tableDown" context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(tableDownDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:animationTime];
    
    refreshButton.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width, self.view.frame.size.height-refreshButton.frame.size.height, refreshButton.frame.size.width, refreshButton.frame.size.height);
    createNewBeaconButton.frame = CGRectMake(refreshButton.frame.size.width, self.view.frame.size.height-createNewBeaconButton.frame.size.height, createNewBeaconButton.frame.size.width, createNewBeaconButton.frame.size.height);
    mapDragButton.frame = CGRectMake(self.view.frame.size.width-mapDragButton.frame.size.width, self.view.frame.size.height-mapDragButton.frame.size.height, mapDragButton.frame.size.width, mapDragButton.frame.size.height);
    followedBeaconLeftOutlet.frame = CGRectMake(0, self.view.frame.size.height-followedBeaconLeftOutlet.frame.size.height, followedBeaconLeftOutlet.frame.size.width, followedBeaconLeftOutlet.frame.size.height);
    followedBeaconRightOutlet.frame = CGRectMake(followedBeaconLeftOutlet.frame.size.width+refreshButton.frame.size.width, self.view.frame.size.height-followedBeaconRightOutlet.frame.size.height, followedBeaconRightOutlet.frame.size.width, followedBeaconRightOutlet.frame.size.height);
    
//    self.mapDragTableView.frame = CGRectMake(0, 416, self.view.frame.size.width, self.view.frame.size.width-84);
    self.mapDragTableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-84);
    self.mapDragButton.alpha = 0.35;
    self.createNewBeaconButton.alpha = 0.35;
    self.refreshButton.alpha = 0.35;
    self.followedBeaconLeftOutlet.alpha = 0.35;
    self.followedBeaconRightOutlet.alpha = 0.35;
    //[mapDragButton setTitle:@"Drag Up to Show Beacons" forState:UIControlStateNormal];
    [UIView commitAnimations];
    //    UIImage *img = [UIImage imageNamed:@"notificationsBar.png"];
    //    [mapDragButton setImage:img forState:UIControlStateNormal];
}
- (IBAction)createNewBeaconPressed:(id)sender
{
    [self transitionToAddBeacon];
}

- (IBAction)refreshPressed:(id)sender {
    //[self findBeaconsInBounds];
    
    if(locationManager.location) {
        [self setLocation:locationManager.location animated:YES];
    } else {
        
        // Tell the user to enable location services
        
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        NSString *path = @"Settings";
        if(version >= 4 && version < 6) {
            path = @"Settings > Location Services";
        } else if(version >= 6) {
            path = @"Settings > Privacy > Location Services";
        }
        
        NSString *message = [NSString stringWithFormat:@"To discover beacons near you, enable location services for Radius in %@.",path];
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:message andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    }
}

-(void) tableDownDidStop:(NSString*)animationID finished:(BOOL)finished context:(void*)context {
    mapDragTableView.alpha = .35;
}

// Do any additional setup after loading the view.

- (void)viewDidUnload
{
    [self setMapDragButton:nil];
    [self setMapDragTableView:nil];
    [locationManager stopUpdatingLocation];
    [self setCreateNewBeaconButton:nil];
    [self setFollowedBeaconLeftOutlet:nil];
    [self setFollowedBeaconRightOutlet:nil];
    [self setCityStateLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}



-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // this should only get called when the my location button is tapped
    
    [self findBeaconsInBounds:YES];
    [self findAndSelectBeaconAtCenter];
    
    // if the map bounds no longer contain the create pin, remove it
    if(createPin && !MKMapRectContainsPoint(radiusmap.visibleMapRect,MKMapPointForCoordinate([createPin.annotation coordinate]))) {
        [self removeCreatePin];
    }
}


-(void)mapDragged
{
    // refresh if map moves, but only a maximum of once per MOVING_REFRESH_PERIOD
    // also refresh if map has been stopped for IDLE_THRESHOLD
    
    NSDate *now = [NSDate date];

    lastMove = now;
    
    // in half a second, we're going to check if the map has been idle between now and then
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (IDLE_THRESHOLD * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSTimeInterval timeSinceLastMove = [[NSDate date] timeIntervalSinceDate:lastMove];
        if(timeSinceLastMove >= IDLE_THRESHOLD) {
            [self findBeaconsInBounds];
        }
    });
    
    if(!lastRefresh) {
        lastRefresh = now;
        return;
    }
    
    if([now timeIntervalSinceDate:lastRefresh] >= MOVING_REFRESH_PERIOD) {
        [self findBeaconsInBounds];
        lastRefresh = now;
    }
    
    // if the map bounds no longer contain the create pin, remove it
    if(createPin && !MKMapRectContainsPoint(radiusmap.visibleMapRect,MKMapPointForCoordinate([createPin.annotation coordinate]))) {
        [self removeCreatePin];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void) setupFollowedCycleButtons {
    
    if (userData.followedBeacons == nil) {
        followedBeaconLeftOutlet.userInteractionEnabled = NO;
        followedBeaconRightOutlet.userInteractionEnabled = NO;
        
        
        NSString *userIDString = [NSString stringWithFormat:@"%i",[[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] integerValue]];
        
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userIDString, @"user",nil] apiMethod:@"followed" httpMethod:@"GET"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            NSLog(@"%@", response);
            
            followedBeaconLeftOutlet.userInteractionEnabled = YES;
            followedBeaconRightOutlet.userInteractionEnabled = YES;
            followedBeaconsArray = response;
            userData.followedBeacons = response;
            currentFollowedBeaconIndex = [NSString stringWithFormat:@"0"];
            
        }];
    }else {
        
        followedBeaconsArray = userData.followedBeacons;
        followedBeaconLeftOutlet.userInteractionEnabled = YES;
        followedBeaconRightOutlet.userInteractionEnabled = YES;
        currentFollowedBeaconIndex = [NSString stringWithFormat:@"0"];

    }
    

    
    
}

- (IBAction)followedBeaconLeftPressed:(id)sender {
    
    if ([followedBeaconsArray count] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Followed Beacons" message:@"Follow some beacons that you like to cycle through them" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }else if ([followedBeaconsArray count] ==1){
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not enough beacons" message:@"Follow some more beacons that you like to cycle through them" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }else{
    
        NSString *arrayCountToIndex = [NSString stringWithFormat:@"%i", ([followedBeaconsArray count] -1)];
        
        if ([currentFollowedBeaconIndex isEqualToString:@"0"]) {
            currentFollowedBeaconIndex = arrayCountToIndex;
        }else {
        currentFollowedBeaconIndex = [NSString stringWithFormat:@"%i", ([currentFollowedBeaconIndex integerValue]-1)];
        }
        
        NSDictionary *nextFollowedBeacon = [followedBeaconsArray objectAtIndex:[currentFollowedBeaconIndex integerValue]];
        CLLocationDegrees nextFollowedBeaconLatitude = [[[nextFollowedBeacon objectForKey:@"center"]objectAtIndex:0]floatValue];;
        CLLocationDegrees nextFollowedBeaconLongitude = [[[nextFollowedBeacon objectForKey:@"center"]objectAtIndex:1]floatValue];;
        CLLocation *nextFollowedBeaconLocation = [[CLLocation alloc] initWithLatitude:nextFollowedBeaconLatitude longitude:nextFollowedBeaconLongitude];
        self.beaconToSelect = [nextFollowedBeacon objectForKey:@"id"];
        [self setLocation:nextFollowedBeaconLocation animated:YES];
//        [self reverseGeocodeFollowedBeaconCenterWithLocation:nextFollowedBeaconLocation];
    
    }
    
}


- (IBAction)followedBeaconRightPressed:(id)sender {
    
    if ([followedBeaconsArray count] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Followed Beacons" message:@"Follow some beacons that you like to cycle through them" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }else if ([followedBeaconsArray count] ==1){
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not enough beacons" message:@"Follow some more beacons that you like to cycle through them" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }else{
    
        NSString *arrayCountToIndex = [NSString stringWithFormat:@"%i", ([followedBeaconsArray count] -1)];
        
        if ([currentFollowedBeaconIndex isEqualToString:arrayCountToIndex]) {
            currentFollowedBeaconIndex = @"0";
        }else {
            currentFollowedBeaconIndex = [NSString stringWithFormat:@"%i", ([currentFollowedBeaconIndex integerValue]+1)];
        }
        
        NSDictionary *nextFollowedBeacon = [followedBeaconsArray objectAtIndex:[currentFollowedBeaconIndex integerValue]];
        CLLocationDegrees nextFollowedBeaconLatitude = [[[nextFollowedBeacon objectForKey:@"center"]objectAtIndex:0]floatValue];;
        CLLocationDegrees nextFollowedBeaconLongitude = [[[nextFollowedBeacon objectForKey:@"center"]objectAtIndex:1]floatValue];;
        CLLocation *nextFollowedBeaconLocation = [[CLLocation alloc] initWithLatitude:nextFollowedBeaconLatitude longitude:nextFollowedBeaconLongitude];
        self.beaconToSelect = [nextFollowedBeacon objectForKey:@"id"];
        [self setLocation:nextFollowedBeaconLocation animated:YES];
//        [self reverseGeocodeFollowedBeaconCenterWithLocation:nextFollowedBeaconLocation];

    }
}

-(void) findAndSelectBeaconAtCenter {
    
//    for (int ii = 0; [[self.radiusmap selectedAnnotations] count] > ii; ii++) {
//
//        [self.radiusmap deselectAnnotation:[[self.radiusmap selectedAnnotations]objectAtIndex:ii] animated:YES];
//
//    }
    
    if(!self.beaconToSelect) return;
    
    for (int i = 0; [[self.radiusmap annotations] count] > i; i++) {
        
        BeaconAnnotation *myAnnotation = (BeaconAnnotation *)[[self.radiusmap annotations]objectAtIndex:i];
        
        if(![myAnnotation isKindOfClass:[BeaconAnnotation class]]) continue;
        
        if(self.beaconToSelect && [[myAnnotation.beaconInfo objectForKey:@"id"] isEqualToNumber:self.beaconToSelect]) {
            [self.radiusmap selectAnnotation:myAnnotation animated:YES];
            self.beaconToSelect = nil;
            break;
        }
        
    }
    
}

-(void) reverseGeocodeFollowedBeaconCenterWithLocation: (CLLocation *)beaconLocation {
    
    CLGeocoder *reverseGeocodeFollowedBeacon = [[CLGeocoder alloc] init];
    [reverseGeocodeFollowedBeacon reverseGeocodeLocation:beaconLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
        [self setupCityStateViewWithPlacemark:newPlacemark];
    
        
    }];
}

-(void) setupCityStateViewWithPlacemark: (CLPlacemark *)placemark {
    
    [cityStateLabel setHidden:NO];
    [cityStateLabel setAlpha:0];
    cityStateLabel.font = [UIFont fontWithName:@"Quicksand" size:15];
    cityStateLabel.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha: .8];
    cityStateLabel.textColor = [UIColor whiteColor];
    cityStateLabel.layer.cornerRadius = 5;
    

    if ([cityStateString isEqualToString:[NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea]]) {
        return;
    }else{
        if (placemark.administrativeArea != nil) {
                    cityStateString = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
        }else if (placemark.country != nil){
                    cityStateString = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.country];
        }

        [cityStateLabel setText:cityStateString];
        
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             
                             [cityStateLabel setAlpha:1];
                             
                             
                         }completion:^(BOOL finished) {
                             
                                 [UIView animateWithDuration:0.4
                                                       delay:1
                                                     options:UIViewAnimationCurveEaseInOut
                                                  animations:^ {
                                                      
                                                      [cityStateLabel setAlpha:0];
                                                      
                                                      
                                                  }completion:^(BOOL finished) {
                                                    
                                                  }];
                             
                         }];
    }
    
    
    
}

-(void) setupLongPressCreateBeacon {
    
    longPressCreateBeaconRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dropPinAtLongPressLocation:)];
    [self.radiusmap addGestureRecognizer:longPressCreateBeaconRecognizer];
    
}

-(void) dropPinAtLongPressLocation: (UILongPressGestureRecognizer *) sender {
    
    if (sender.state == UIGestureRecognizerStateBegan){
        
        if (createPin) {
            // remove existing pin and drop new one
            [self removeCreatePin];
        }
        
        CGPoint longPressLocation = [sender locationInView:self.radiusmap];
        CLLocationCoordinate2D locationOfLongPress = [self.radiusmap convertPoint:longPressLocation toCoordinateFromView:self.radiusmap];
        CreateBeaconAnnotation *longPressAnnotation = [[CreateBeaconAnnotation alloc] init];
        [longPressAnnotation setCoordinate:locationOfLongPress];
        longPressAnnotation.title = @"Create a Beacon here?";
        [self.radiusmap addAnnotation:longPressAnnotation];
    }


}

-(void) setupNoResultsView {
    
    firstTimeLoadingMap = NO;
//    PopupView *noResultsView = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
//    [noResultsView setupWithDescriptionText:@"There aren't any beacons nearby, tap anywhere on the map to create a new one!" andButtonText:@"OK"];
//    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//    void (^cancelOrDoneBlock)() = ^{
//        // we must manually slide out the view out if we specify this block
//        [MFSlidingView slideOut];
//    };
//    [MFSlidingView slideView:noResultsView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
    noResultsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.mapDragTableView.frame.size.width, 1000)];
    noResultsView.tag = NO_RESULTS_VIEW_TAG;
    noResultsView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, noResultsView.frame.size.width - 20, 100)];
    noResultsLabel.textColor = [UIColor blackColor];
    noResultsLabel.text = [NSString stringWithFormat:@"There aren't any beacons nearby.  Hold down anywhere on the map to create a new one!"];
    noResultsLabel.textAlignment = UITextAlignmentCenter;
    noResultsLabel.font = [UIFont fontWithName:@"Quicksand" size:16.0];
    noResultsLabel.backgroundColor = [UIColor clearColor];
    noResultsLabel.numberOfLines = 5;
    
    [noResultsView addSubview:noResultsLabel];

    
    
}

-(void) showNoResultsView {
    
    [[self.mapDragTableView viewWithTag:NO_RESULTS_VIEW_TAG]removeFromSuperview];
    noResultsView.frame = CGRectMake(0, 0, self.mapDragTableView.frame.size.width, 1000);
    [self.mapDragTableView addSubview:noResultsView];

    
    
    
}

-(void) hideNoResultsView {
    
    [[self.mapDragTableView viewWithTag:NO_RESULTS_VIEW_TAG]removeFromSuperview];



    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self findBeaconsInBounds];
}

-(void)refresh
{
    [self findBeaconsInBounds];
}

@end
