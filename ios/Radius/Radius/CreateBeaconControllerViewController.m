//
//  CreateBeaconControllerViewController.m
//  Radius
//
//  Created by Hudson Duan on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateBeaconControllerViewController.h"
#import "SBJson.h"
#import "MFSideMenu.h"
#import "InviteFriendsViewController.h"
#import "RadiusRequest.h"
#import "BeaconContentViewController2.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "Flurry.h"

@interface CreateBeaconControllerViewController () <CLLocationManagerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate, UITextViewDelegate> {
    BOOL locationSet;
    
    BOOL placeholderSet;
}

@end

@implementation CreateBeaconControllerViewController
@synthesize beaconName;
@synthesize createMap;
@synthesize locationManager;
@synthesize connection, jsonData, jsonArray;
@synthesize createdBeacon;
@synthesize createBeaconButton;
@synthesize beaconDescriptionTextView;
@synthesize beaconTagString, userTokenString;
@synthesize inputBeaconCenter, beaconNameString;
@synthesize googleRefToken;
@synthesize switchMapTypeButton;
@synthesize location = _location;

static NSString *const DESCRIPTION_PLACEHOLDER_TEXT = @"Enter a short description!";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = location;
    locationSet = YES;
}

-(void)initializeWithLocation:(CLLocationCoordinate2D)loc
{
    self.location = loc;
}

-(void)initializeWithLocation:(CLLocationCoordinate2D)loc name:(NSString *)name googlePlaceReference:(NSString *)ref
{
    self.googleRefToken = ref;
    self.beaconNameString = name;
    self.location = loc;
}

-(void) setupMapLocation {
    MKCoordinateRegion plugregion;
    
    plugregion.center = self.location;
    
    plugregion.span.longitudeDelta = 0.005;
    plugregion.span.latitudeDelta= 0.005;
    [self.createMap setRegion: plugregion animated:YES];

    NSLog(@"%f,%f,%f,%f",self.createMap.region.center.latitude,self.createMap.region.center.longitude,self.createMap.region.span.latitudeDelta,self.createMap.region.span.longitudeDelta);
    
    createMap.showsUserLocation = YES; 
}

- (void) changeMapLocationBasedOnDragAndDrop {
    
    MKCoordinateRegion newRegion;
    newRegion.center = self.location;
    newRegion.span = createMap.region.span;
    [self.createMap setRegion: newRegion animated:YES];
    
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    
    static NSString *annotationIdentifier=@"MyAnnotationIdentifier";
        
        if([annotation isKindOfClass: [MKUserLocation class]]){
            return nil;
        }else{
            
            MKAnnotationView *draggingAnnotationView = [createMap dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
            
            if (!draggingAnnotationView) {
                draggingAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
                draggingAnnotationView.draggable = YES;
                draggingAnnotationView.canShowCallout = YES;
                draggingAnnotationView.centerOffset = CGPointMake(0, -30);
                draggingAnnotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
                draggingAnnotationView.frame = CGRectMake(draggingAnnotationView.frame.origin.x, draggingAnnotationView.frame.origin.y, 50, 50);
            }
            
            return draggingAnnotationView;
        }
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateStarting)
    {
        
        CGPoint endPoint = CGPointMake(annotationView.center.x,annotationView.center.y-40);
        [UIView animateWithDuration:0.2
                         animations:^{ annotationView.center = endPoint; }
                         completion:^(BOOL finished){
             annotationView.dragState = MKAnnotationViewDragStateDragging;
         }];
    }
    else if (newState == MKAnnotationViewDragStateEnding)
    {
        
        CGPoint endPoint = CGPointMake(annotationView.center.x,annotationView.center.y);
        [UIView animateWithDuration:0.2
                         animations:^{ annotationView.center = endPoint; }
                         completion:^(BOOL finished){
            annotationView.dragState = MKAnnotationViewDragStateNone;
            self.location = annotationView.annotation.coordinate;
            [self changeMapLocationBasedOnDragAndDrop];
            }];
        
        annotationView.canShowCallout = NO;

    }
    else if (newState == MKAnnotationViewDragStateCanceling)
    {
        
        CGPoint endPoint = CGPointMake(annotationView.center.x,annotationView.center.y);
        [UIView animateWithDuration:0.2
                         animations:^{ annotationView.center = endPoint; }
                         completion:^(BOOL finished){
             annotationView.dragState = MKAnnotationViewDragStateNone;
         }];
    }
        
    if (newState == MKAnnotationViewDragStateEnding)
    {
//        dragAndDroppedLocation = annotationView.annotation.coordinate;
//        NSLog(@"dropped at %f,%f", dragAndDroppedLocation.latitude, dragAndDroppedLocation.longitude);
//        [annotationView setDragState:MKAnnotationViewDragStateNone];
//        [self changeMapOverlay];
//        [self changeMapLocationBasedOnDragAndDrop];
    }
    
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
//    if(!self.googleRefToken) {
//        for(MKAnnotationView *v in views) {
//            if(![v.annotation isKindOfClass:[MKUserLocation class]]) {
//                [mapView selectAnnotation:v.annotation animated:YES];
//                break;
//            }
//        }
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    // select annotation if custom location
    if(!self.googleRefToken) {
        for(id<MKAnnotation> a in createMap.annotations) {
            if(![a isKindOfClass:[MKUserLocation class]]) {
                [createMap selectAnnotation:a animated:YES];
                break;
            }
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    
    [self setupTextView];
    
	[createMap setDelegate:self];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if(!locationSet && locationManager.location) {
        self.location = locationManager.location.coordinate;
    }
    
    [locationManager startUpdatingLocation];
    
    [self setupSideMenuBarButtonItem];
    [self setupBackgroundViews];
    [self setupFonts];
    [self setNameIfInputPlace];
    [self setupSwitchMapTypeButton];
    [self setupMapLocation];
    [self setupMapAnnotations];
    self.title = @"Create";
    
	// Do any additional setup after loading the view.
    //Initialize the single tap recognizer
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(!locationSet) {
        self.location = [[locations objectAtIndex:0] coordinate];
        [self setupMapLocation];
    }
}


-(void) setupSwitchMapTypeButton {
    
    
    if (createMap.mapType == MKMapTypeStandard) {
        [self.switchMapTypeButton setTitle:@"Satellite" forState:UIControlStateNormal];
        [self.switchMapTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.switchMapTypeButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:14]];

    }
    
    if (createMap.mapType == MKMapTypeSatellite) {
        [self.switchMapTypeButton setTitle:@"Standard" forState:UIControlStateNormal];
        [self.switchMapTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.switchMapTypeButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:14]];

    }
    
    self.switchMapTypeButton.layer.cornerRadius = 5;
    
}

-(void) setupMapAnnotations {
    CreateBeaconAnnotation *annotation = [[CreateBeaconAnnotation alloc] init];
    [annotation setCoordinate:self.location];
    annotation.title = beaconNameString?beaconNameString:@"Drag Me Around!";
    [createMap addAnnotation:annotation];
    
}

-(void) setNameIfInputPlace
{
    if (beaconNameString == (id)[NSNull null] || beaconNameString.length == 0)
    {
        return;
    }
    else
    {
        beaconName.text = beaconNameString;
        
    }
}

- (void)viewDidUnload
{
    [self setCreateMap:nil];
    [self setBeaconName:nil];
    [locationManager stopUpdatingLocation];
    
    [self setBeaconDescriptionTextView:nil];
    [self setCreateBeaconButton:nil];
    [self setSwitchMapTypeButton:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setupBackgroundViews
{
    self.beaconNameBackgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_cbp_namebeacon.png"]];
    self.descriptionBackgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_cbp_describe.png"]];
    
    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    
    if([UIScreen mainScreen].bounds.size.height <= 480) {
        self.adjustSizeBackgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_cbp_adjustposition.png"]];
    } else {
        self.adjustSizeBackgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"iphone5_pnl_cbp_adjustposition.png"]];
    }
}

-(void) setupFonts
{
    [beaconName setFont:[UIFont fontWithName:@"Quicksand" size:beaconName.font.pointSize]];
    [beaconDescriptionTextView setFont:[UIFont fontWithName:@"Quicksand" size:beaconDescriptionTextView.font.pointSize]];
}

// Handle single taps such that they hide the keyboard
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.beaconName) {
        [theTextField resignFirstResponder];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your beacon name is too long!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    if (newLength >40) {
        
        [av show];

        
        return NO;
    }else {
        
        return YES;
    }
    
    
//    return (newLength > 40) ? NO : YES;
}

-(void)createNewBeacon
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Created a Beacon"];
#endif
        
    //    NSDictionary *createBeaconParamsDict = [NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", beaconName.text, @"name", [NSString stringWithFormat:@"%f", createMap.userLocation.location.coordinate.latitude], @"lat", [NSString stringWithFormat:@"%f", createMap.userLocation.location.coordinate.longitude], @"lng", [NSString stringWithFormat:@"%f", beaconSliderValue.value], @"radius", beaconDescriptionTextView.text, @"description", nil];
    //If we were still using Radius
//    NSMutableDictionary *createBeaconWithDragAndDropParamsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", beaconName.text, @"name", [NSString stringWithFormat:@"%f", dragAndDroppedLocation.latitude], @"lat", [NSString stringWithFormat:@"%f", dragAndDroppedLocation.longitude], @"lng", [NSString stringWithFormat:@"%f", beaconSliderValue.value], @"radius", beaconDescriptionTextView.text, @"description", @"test", @"google_place", nil];
    
    NSString *description = placeholderSet ? @"" : beaconDescriptionTextView.text;
    
    NSMutableDictionary *createBeaconWithDragAndDropParamsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", beaconName.text, @"name", [NSString stringWithFormat:@"%f",self.location.latitude], @"lat", [NSString stringWithFormat:@"%f", self.location.longitude], @"lng", description, @"description", nil];

    if (googleRefToken != (id)[NSNull null] && googleRefToken.length != 0)
    {
        [createBeaconWithDragAndDropParamsDict setObject:googleRefToken forKey:@"google_place"];
    }
    //By default, share the new beacon on FB for now
    [createBeaconWithDragAndDropParamsDict setObject:@"true" forKey:@"fb_share"];
    [self showLoadingOverlay];
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:createBeaconWithDragAndDropParamsDict apiMethod:@"beacon_create" httpMethod:@"POST"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         //If create was successful, we will get the new beacon's ID back
         if ([response objectForKey:@"beacon_id"])
         {
             [self dismissLoadingOverlay];
             //The creator should automatically follow it
             InviteFriendsViewController *inviteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"inviteFriendsID"];
             [inviteVC setBeaconID:[response objectForKey:@"beacon_id"]];
             [inviteVC setBeaconName:beaconName.text];
             [inviteVC setJustCreated:YES];
             NSArray *controllers = [NSArray arrayWithObject:inviteVC];
             [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
             [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
             
             NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:[response objectForKey:@"beacon_id"] forKey:@"beacon"];
             [Flurry endTimedEvent:@"Beacon_Created" withParameters:eventParameters];
             
             //[self.navigationController pushViewController:inviteVC animated:YES];
//             BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
//             [createdBeaconInstance setSendingBeaconID:[response objectForKey:@"beacon_id"]];
//             [createdBeaconInstance setTitle:beaconName.text];
//             [createdBeaconInstance setBeaconJustCreated:YES];
//             NSArray *controllers = [NSArray arrayWithObject:createdBeaconInstance];
//             [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//             [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
             
//             [self addBeaconTags:[response objectForKey:@"beacon_id"] tags:beaconTagString];
         }
         
     }];
}

- (IBAction)createDetailButton:(id)sender {
    
    if ([beaconName.text length] != 0) {
        [createBeaconButton setEnabled:NO];
        [createBeaconButton setSelected:YES];

        [self createNewBeacon];
        //[self showBeaconCongrats];

    } else {
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"Give your beacon a name!" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    }
    
}

- (IBAction)switchMapTypeButtonPressed:(id)sender {
    
    if (createMap.mapType == MKMapTypeStandard) {
        
        createMap.mapType = MKMapTypeSatellite;
        [self setupSwitchMapTypeButton];
        
    }else if (createMap.mapType == MKMapTypeSatellite){
        
        createMap.mapType = MKMapTypeStandard;
        [self setupSwitchMapTypeButton];


    }
    
}


#pragma mark TextView Delegate methods

-(void)setupTextView
{
    [beaconDescriptionTextView setDelegate:self];
    [beaconDescriptionTextView setReturnKeyType:UIReturnKeyDone];
    [self setPlaceholderText];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (placeholderSet) {
        [self clearPlaceholderText];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(beaconDescriptionTextView.text.length == 0) {
        [self setPlaceholderText];
    }
}

- (void)setPlaceholderText
{
    [beaconDescriptionTextView setText:DESCRIPTION_PLACEHOLDER_TEXT];
    [beaconDescriptionTextView setTextColor:[UIColor lightGrayColor]];
    placeholderSet = YES;
}

- (void)clearPlaceholderText
{
    [beaconDescriptionTextView setText:@""];
    [beaconDescriptionTextView setTextColor:[UIColor blackColor]];
    placeholderSet = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
}




@end
