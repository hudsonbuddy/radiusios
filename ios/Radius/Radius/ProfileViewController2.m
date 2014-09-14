//
//  ProfileViewController2.m
//  Radius
//
//  Created by Fred Ehrsam on 9/15/12.
//
//

#import "ProfileViewController2.h"
#import "RadiusAppDelegate.h"
#import "MFSlidingView.h"
#import "SettingsViewController.h"
#import "ConvoThreadViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RadiusEvent.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "CreateBeaconAnnotation.h"
#import "RadiusEvent.h"
#import "BeaconCreateEvent.h"
#import <objc/runtime.h>
#import "ContentPostEvent.h"
#import "Flurry.h"

@interface ProfileViewController2 () <SettingsDelegate> {
    BOOL isCurrentUserProfile;
    BOOL isFriendOfCurrentUser;
    
    AsyncImageView *profilePictureView;

    RadiusUserData *_myUserData;

}

@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSDictionary  *jsonDictionary;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableDictionary *cache;
@end

@implementation ProfileViewController2
@synthesize followedBeaconsTableView, recentActivityTable;
@synthesize displayNameLabel, favoritePlacesLabel;
@synthesize profilePictureButton;

@synthesize jsonData = _jsonData;
@synthesize jsonDictionary = _jsonDictionary;
@synthesize connection;
@synthesize responseArray, responseDictionary, activityArray, activityDictionary;
@synthesize recentActivityButton, followedBeaconsButton, beaconMapButton;
@synthesize namePanel;
@synthesize settingsButton;
@synthesize userID;
@synthesize footprintMap;
@synthesize followedResponseArray, followedResponseDictionary;
@synthesize recentActivityTableIsEditing, indexPathToEditingCell, tapToStopEditingTapGestureRecognizer;
@synthesize suggestedResponseArray, suggestedResponseDictionary, indexPathToMoreButton;
@synthesize friendButtonOutlet;


RadiusProgressView *uploadProgressView;
NSDictionary *userInfoDict;
static const CGFloat DIMVIEW_BLOCKING_TAG = 100;

static const NSInteger ACTIVITY_LOADING_TAG = 4892;
static const NSInteger FOLLOWED_LOADING_TAG = 4893;
//static const char * INDEX_PATH_ASSOCIATION_KEY = "index_path";

static const CGFloat DELETE_CONVO_BUTTON_TAG = 1000;
static const CGFloat ACTIVITY_MORE_BUTTON_TAG = 2000;

static const NSInteger CELL_ASYNC_IMAGE_TAG = 849320;






-(void) initializeWithUserID:(NSUInteger)uid
{
    self.userID = uid;
}

-(void) setupLookAndFeel
{
    [self.displayNameLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.displayNameLabel.font.pointSize]];
//    self.displayNameLabel.textColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/;
    self.displayNameLabel.textColor = [UIColor whiteColor];
    self.favoritePlacesLabel.textColor = [UIColor whiteColor];
    if (_myUserData.followedBeacons && isCurrentUserProfile) {
        NSInteger numFollowed = _myUserData.followedBeacons.count;
        favoritePlacesLabel.text = [NSString stringWithFormat:@"%d followed beacon%@",numFollowed,numFollowed==1?@"":@"s"];
    }else{
        favoritePlacesLabel.text = @"";//[NSString stringWithFormat:@"followed beacons"];
    }


    UIImage *img = [UIImage imageNamed:@"iphone5_menubkgd@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    
    
    backgroundNotificationsView.alpha = 0.4;
    backgroundNotificationsView.frame = self.view.frame;

    [self.view addSubview:backgroundNotificationsView];
    [self.view sendSubviewToBack:backgroundNotificationsView ];
    
    self.recentActivityTable.backgroundColor = [UIColor clearColor];
    self.followedBeaconsTableView.backgroundColor = [UIColor clearColor];
    self.footprintMap.layer.cornerRadius = 5;
    
    UIImage *namePanelBackground = [UIImage imageNamed:@"pnl_profile@2x.png"];
    UIImageView *namePanelBackgroundView = [[UIImageView alloc] initWithImage:namePanelBackground];
    namePanelBackgroundView.frame = CGRectMake(namePanelBackgroundView.frame.origin.x, namePanelBackgroundView.frame.origin.y, 310, 110);
    [self.namePanel addSubview:namePanelBackgroundView];
    [self.namePanel sendSubviewToBack:namePanelBackgroundView];
    
    
    // Replace the profile picture button with an AsyncImageView
    profilePictureView = [[AsyncImageView alloc] initWithFrame:self.profilePictureButton.frame];
    [profilePictureButton.superview addSubview:profilePictureView];
    [profilePictureButton removeFromSuperview];
    profilePictureView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    profilePictureView.layer.cornerRadius = 5;
    profilePictureView.backgroundColor = [UIColor whiteColor];
}

-(void) loadMeInfo
{
    RadiusRequest *request = [RadiusRequest requestWithAPIMethod:@"me"];
    [request startWithCompletionHandler:^(id response, RadiusError *error) {
        userInfoDict = response;
        [self setUpUser];
    }];
}

-(void) loadUserInfo
{
    
    RadiusRequest *radRquest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.userID] forKey:@"user"] apiMethod:@"userinfo"];
    [radRquest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         userInfoDict = response;
         [self setUpUser];
         isFriendOfCurrentUser = [[userInfoDict objectForKey:@"friend"] boolValue];
         [self setupFriendButton];
        
     }];
        
}

-(void) setUpUser
{
    NSString *displayName = [userInfoDict objectForKey:@"display_name"];
    self.displayNameLabel.text = displayName;
    
    if ([displayName length] < 9 ) {
        
        self.title = displayName;

    }else
        self.title = @"Profile";
    
    
    NSURL *imageURL = [NSURL URLWithString:[userInfoDict objectForKey:@"picture"]];
    profilePictureView.imageURL = imageURL;
    [profilePictureView loadImage];
    
    
    [self loadUserActivity];
    [self findFollowedBeacons];
}

-(void) addLoadingViews
{
    UIActivityIndicatorView *activityLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityLoading.frame = CGRectMake(140, 90, 40, 40);
    activityLoading.tag = ACTIVITY_LOADING_TAG;
    activityLoading.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    activityLoading.layer.cornerRadius = 5;
    [activityLoading startAnimating];
    [self.recentActivityTable addSubview:activityLoading];
    
    UIActivityIndicatorView *followedLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    followedLoading.frame = CGRectMake(140,90,40,40);
    followedLoading.tag = FOLLOWED_LOADING_TAG;
    followedLoading.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    followedLoading.layer.cornerRadius = 5;
    [followedLoading startAnimating];
    if (_myUserData.followedBeacons == nil || !isCurrentUserProfile) {
        [self.followedBeaconsTableView addSubview:followedLoading];

    }
}


-(void) loadUserActivity
{
    RadiusRequest *activityRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.userID] forKey:@"user"] apiMethod:@"user/activity" httpMethod:@"GET"];
    [activityRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        if(![response isKindOfClass:[NSArray class]]) {
            return;
        }
        
        activityArray = [[NSMutableArray alloc] init];
        for(NSDictionary *eventDictionary in response) {
            RadiusEvent *event = [RadiusEvent eventWithDictionary:eventDictionary];
            if(event) {
                [activityArray addObject:event];
            }
        }
        
        [[recentActivityTable viewWithTag:ACTIVITY_LOADING_TAG] removeFromSuperview];
        [recentActivityTable reloadData];

    }];
}

- (void) setupFootPrint {
    if (followedResponseArray && !isCurrentUserProfile) {
        
        if ([followedResponseArray count] == 0) {
            
            footprintMap.frame = followedBeaconsTableView.frame;
            footprintMap.delegate = self;
            [footprintMap removeAnnotations:footprintMap.annotations];
            
            CreateBeaconAnnotation *blankAnnotation = [[CreateBeaconAnnotation alloc] init];
            [blankAnnotation setCoordinate:CLLocationCoordinate2DMake(37.331797,-122.02962)];
            
            if(isCurrentUserProfile) {
                blankAnnotation.title = @"Follow Some Beacons First!";
            }
            
            [footprintMap addAnnotation:blankAnnotation];
            
            MKCoordinateRegion region;
            
            region.center.latitude= blankAnnotation.coordinate.latitude;
            region.center.longitude = blankAnnotation.coordinate.longitude;
            region.span.longitudeDelta = 0.01149;
            region.span.latitudeDelta= 0.009863;
            [self.footprintMap setRegion:region animated:YES];
            
            
        }else
            
            if ([followedResponseArray count] == 1) {
                
                footprintMap.frame = followedBeaconsTableView.frame;
                footprintMap.delegate = self;
                [footprintMap removeAnnotations:footprintMap.annotations];
                
                
                BeaconAnnotation *annotation = [[BeaconAnnotation alloc] initWithBeaconInfo:[followedResponseArray objectAtIndex:0]];
                [footprintMap addAnnotation:annotation];
                
                MKCoordinateRegion region;
                
                region.center.latitude= annotation.coordinate.latitude;
                region.center.longitude = annotation.coordinate.longitude;
                region.span.longitudeDelta = 0.01149;
                region.span.latitudeDelta= 0.009863;
                [self.footprintMap setRegion:region animated:YES];
                
                
            }else
                
                if ([followedResponseArray count]>1) {
                    
                    
                    
                    footprintMap.frame = followedBeaconsTableView.frame;
                    footprintMap.delegate = self;
                    [footprintMap removeAnnotations:footprintMap.annotations];
                    
                    for (int i = 0; i < [followedResponseArray count]; i++) {
                        
                        BeaconAnnotation *annotation = [[BeaconAnnotation alloc] initWithBeaconInfo:[followedResponseArray objectAtIndex:i]];
                        [footprintMap addAnnotation:annotation];
                    };
                    
                    
                    double minLat=360.0f,minLon=360.0f;
                    double maxLat=-360.0f,maxLon=-360.0f;
                    
                    for (id <MKAnnotation> vu in [footprintMap annotations]) {
                        if ( vu.coordinate.latitude  < minLat ) minLat = vu.coordinate.latitude;
                        if ( vu.coordinate.latitude  > maxLat ) maxLat = vu.coordinate.latitude;
                        if ( vu.coordinate.longitude < minLon ) minLon = vu.coordinate.longitude;
                        if ( vu.coordinate.longitude > maxLon ) maxLon = vu.coordinate.longitude;
                    }
                    CLLocation *newCenter = [[CLLocation alloc] initWithLatitude: (maxLat+minLat)/2.0
                                                                       longitude: (maxLon+minLon)/2.0];
                    footprintMap.region = MKCoordinateRegionMake (newCenter.coordinate,
                                                                  MKCoordinateSpanMake( fabs(maxLat-minLat)*1.2, fabs(maxLon-minLon)*1.2) );
                    
                }

        
    }else if (_myUserData.followedBeacons && isCurrentUserProfile){
        
        if ([_myUserData.followedBeacons count] == 0) {
            
            footprintMap.frame = followedBeaconsTableView.frame;
            footprintMap.delegate = self;
            [footprintMap removeAnnotations:footprintMap.annotations];
            
            CreateBeaconAnnotation *blankAnnotation = [[CreateBeaconAnnotation alloc] init];
            [blankAnnotation setCoordinate:CLLocationCoordinate2DMake(37.331797,-122.02962)];
            
            if(isCurrentUserProfile) {
                blankAnnotation.title = @"Follow Some Beacons First!";
            }
            
            [footprintMap addAnnotation:blankAnnotation];
            
            MKCoordinateRegion region;
            
            region.center.latitude= blankAnnotation.coordinate.latitude;
            region.center.longitude = blankAnnotation.coordinate.longitude;
            region.span.longitudeDelta = 0.01149;
            region.span.latitudeDelta= 0.009863;
            [self.footprintMap setRegion:region animated:YES];
            
            
        }else
            
            if ([_myUserData.followedBeacons count] == 1) {
                
                footprintMap.frame = followedBeaconsTableView.frame;
                footprintMap.delegate = self;
                [footprintMap removeAnnotations:footprintMap.annotations];
                
                
                BeaconAnnotation *annotation = [[BeaconAnnotation alloc] initWithBeaconInfo:[_myUserData.followedBeacons objectAtIndex:0]];
                [footprintMap addAnnotation:annotation];
                
                MKCoordinateRegion region;
                
                region.center.latitude= annotation.coordinate.latitude;
                region.center.longitude = annotation.coordinate.longitude;
                region.span.longitudeDelta = 0.01149;
                region.span.latitudeDelta= 0.009863;
                [self.footprintMap setRegion:region animated:YES];
                
                
            }else
                
                if ([_myUserData.followedBeacons count]>1) {
                    
                    
                    
                    footprintMap.frame = followedBeaconsTableView.frame;
                    footprintMap.delegate = self;
                    [footprintMap removeAnnotations:footprintMap.annotations];
                    
                    for (int i = 0; i < [_myUserData.followedBeacons count]; i++) {
                        
                        BeaconAnnotation *annotation = [[BeaconAnnotation alloc] initWithBeaconInfo:[_myUserData.followedBeacons objectAtIndex:i]];
                        [footprintMap addAnnotation:annotation];
                    };
                    
                    
                    double minLat=360.0f,minLon=360.0f;
                    double maxLat=-360.0f,maxLon=-360.0f;
                    
                    for (id <MKAnnotation> vu in [footprintMap annotations]) {
                        if ( vu.coordinate.latitude  < minLat ) minLat = vu.coordinate.latitude;
                        if ( vu.coordinate.latitude  > maxLat ) maxLat = vu.coordinate.latitude;
                        if ( vu.coordinate.longitude < minLon ) minLon = vu.coordinate.longitude;
                        if ( vu.coordinate.longitude > maxLon ) maxLon = vu.coordinate.longitude;
                    }
                    CLLocation *newCenter = [[CLLocation alloc] initWithLatitude: (maxLat+minLat)/2.0
                                                                       longitude: (maxLon+minLon)/2.0];
                    footprintMap.region = MKCoordinateRegionMake (newCenter.coordinate,
                                                                  MKCoordinateSpanMake( fabs(maxLat-minLat)*1.2, fabs(maxLon-minLon)*1.2) );
                    
                }

        
    }
    
       
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (followedResponseArray) {
        if ([followedResponseArray count] >=1) {
            
            
            
            if([annotation isKindOfClass: [MKUserLocation class]]){
                
                return nil;
                
            }else {
                
                if(![annotation respondsToSelector:@selector(beaconInfo)]) {
                    NSLog(@"not a BeaconAnnotation");
                }
                
                MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Beacon"];
                if(!annotationView) {
                    annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Beacon"];
                }
                
                // Button
                UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                button.frame = CGRectMake(0, 0, 23, 23);
                annotationView.rightCalloutAccessoryView = button;
                
                annotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
                
                //annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, 60, 60);
                annotationView.frame = CGRectMake(0, 0, 60, 60);
                annotationView.centerOffset = CGPointMake(0, -30);
                //annotationView.image = [self imageWithColor:[UIColor clearColor] withSideLength:currBeaconOverlay.radius];
                annotationView.canShowCallout = YES;
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
            
        }else {
            
            MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BlankBeacon"];
            if(!annotationView) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BlankBeacon"];
            }
            annotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
            
            annotationView.frame = CGRectMake(0, 0, 60, 60);
            annotationView.centerOffset = CGPointMake(0, -30);
            annotationView.canShowCallout = YES;
            annotationView.draggable = NO;
        }
        
        return nil;

    }else if (_myUserData.followedBeacons && isCurrentUserProfile){
        
        if ([_myUserData.followedBeacons count] >=1) {
            
            
            
            if([annotation isKindOfClass: [MKUserLocation class]]){
                
                return nil;
                
            }else {
                
                if(![annotation respondsToSelector:@selector(beaconInfo)]) {
                    NSLog(@"not a BeaconAnnotation");
                }
                
                MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Beacon"];
                if(!annotationView) {
                    annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Beacon"];
                }
                
                // Button
                UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                button.frame = CGRectMake(0, 0, 23, 23);
                annotationView.rightCalloutAccessoryView = button;
                
                annotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
                
                //annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, 60, 60);
                annotationView.frame = CGRectMake(0, 0, 60, 60);
                annotationView.centerOffset = CGPointMake(0, -30);
                //annotationView.image = [self imageWithColor:[UIColor clearColor] withSideLength:currBeaconOverlay.radius];
                annotationView.canShowCallout = YES;
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
            
        }else {
            
            MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BlankBeacon"];
            if(!annotationView) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BlankBeacon"];
            }
            annotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
            
            annotationView.frame = CGRectMake(0, 0, 60, 60);
            annotationView.centerOffset = CGPointMake(0, -30);
            annotationView.canShowCallout = YES;
            annotationView.draggable = NO;
        }
        
        return nil;

        
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    //    UIAlertView *tappedAccessory = [[UIAlertView alloc] initWithTitle:@"tapped" message:@"accessory" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    //
    //    [tappedAccessory show];
    
    BeaconContentViewController2 *beaconViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [beaconViewController initializeWithBeaconDictionary:[(BeaconAnnotation *)view.annotation beaconInfo]];
    
    [self.navigationController pushViewController:beaconViewController animated:YES];
    
}

#pragma mark Profile Picture Handle


- (IBAction)profilePicturePressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Change your picture?" delegate:self
                                  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  @"Upload From Media Library", @"Take a Picture Now",
                                  nil];
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Take a Picture Now"]) {
        
        [self startCameraControllerFromViewController:self usingDelegate:self];
        
        
    }else if ([buttonTitle isEqualToString:@"Upload From Media Library"]){
        
        [self startMediaBrowserFromViewController: self
                                    usingDelegate: self];
        
    }else {
        
        NSLog(@"Nothing picked, error");
        
    }
    
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;

    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}


- (void) uploadImage:(UIImage *)imageToUse {
    
    if(self.modalViewController) {
        [self performSelector:@selector(uploadImage:) withObject:imageToUse afterDelay:0.1f];
        return;
    }
    
    uploadProgressView = [[[NSBundle mainBundle]loadNibNamed:@"RadiusProgressView" owner:self options:nil]objectAtIndex:0];
    uploadProgressView.description.text = @"Uploading Image";
    [self.view addSubview:uploadProgressView];
    
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        
        //        UIAlertView *picked = [[UIAlertView alloc] initWithTitle:@"Picked" message:@"Susan Coffey is awesome" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        //
        //        [picked show];
        
        
        [self uploadImage:imageToUse];
        [profilePictureButton setImage:imageToUse forState:UIControlStateNormal];
        // Do something with imageToUse
    }
    
    // Handle a movie picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"You tried to pick a movie, try picking an image" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        // Do something with the picked movie available at moviePath
    }
    
    //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setUploadProgress:(NSNumber *)progress {
    float p = [progress floatValue];
    
    if(p >= 1.0f) {
        [uploadProgressView removeFromSuperview];
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"Upload complete!" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        return;
    }
    
    [uploadProgressView.progressView setProgress:p animated:YES];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    float progress = totalBytesWritten/ (float)totalBytesExpectedToWrite;
    
    [self performSelectorOnMainThread:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    //    [self.navigationController popViewControllerAnimated:YES];
}

//-(void) loadUserInfo {
//
//    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"eddard", @"user",nil] apiMethod:@"userinfo" httpMethod:@"GET"];
//
//    [r startWithCompletionHandler:^(id response, RadiusError *error) {
//
//        // deal with response object
//        NSLog(@"working %@", response);
//        if ([response isKindOfClass:[NSArray class]]) {
//            responseArray = response;
//        }else if ([response isKindOfClass:[NSDictionary class]]){
//
//            responseDictionary = response;
//        }
//    }];
//
//}


#pragma mark Table View Setup

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == recentActivityTable){
        return 1;
    }else if (tableView == followedBeaconsTableView){
        if (isCurrentUserProfile) {
            return 2;
        }else{
            return 1;
        }
    }else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == followedBeaconsTableView)
    {
        if (section == 0) {
            
            if (responseArray != nil) {
                return [responseArray count];
            }else if (responseDictionary != nil) {
                return [responseDictionary count];
            }else if (_myUserData.followedBeacons != nil && isCurrentUserProfile){
                return [_myUserData.followedBeacons count];
            }
            
        }else if (section == 1){
            
            if (suggestedResponseArray != nil) {
                return [suggestedResponseArray count]+1;
            }else if (suggestedResponseDictionary != nil) {
                return [suggestedResponseDictionary count]+1;
            }

        }
    }
    else if (tableView == recentActivityTable)
    {
        return [activityArray count];
    }
    
    return 0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    
//    if (tableView == followedBeaconsTableView) {
//        if (isCurrentUserProfile) {
//            if (section == 0) {
//                return @"Followed Beacons";
//            }else if (section == 1){
//                return @"Suggested Beacons";
//            }
//        }else
//            return nil;
//
//    }else
//        return nil;
//}

//- (NSString *)titleForHeaderInSection:(NSInteger)section{
//    
//    if (tableView == followedBeaconsTableView) {
//        if (isCurrentUserProfile) {
//            if (section == 0) {
//                return @"Followed Beacons";
//            }else if (section == 1){
//                return @"Suggested Beacons";
//            }
//        }else
//            return nil;
//        
//    }else
//        return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view;
    if(NSClassFromString(@"UITableViewHeaderFooterView")) {
        view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    } else {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = [UIColor grayColor];
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
        bottomLine.backgroundColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
        [view addSubview:bottomLine];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    if (tableView == followedBeaconsTableView) {
        if (isCurrentUserProfile) {
            if (section == 0) {
                label.text = @"Followed Beacons";
            }else if (section == 1){
                label.text = @"Suggested Beacons";
            }
        }
    }
    [label sizeToFit];
    
    label.frame = CGRectOffset(label.frame, 0, 18-label.frame.size.height/2);
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = .5;
    label.layer.shadowRadius = 1.0;

    [view addSubview:label];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == followedBeaconsTableView) {
        if (isCurrentUserProfile) {
            return 30;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    if ([cell viewWithTag:CELL_ASYNC_IMAGE_TAG] || [cell.contentView viewWithTag:CELL_ASYNC_IMAGE_TAG]) {
        [[cell.contentView viewWithTag:CELL_ASYNC_IMAGE_TAG] removeFromSuperview];
        [[cell viewWithTag:CELL_ASYNC_IMAGE_TAG] removeFromSuperview];
    }
    cell.indentationLevel = 0;
    
    cell.imageView.image = nil;
    //Make it so cells are Radius maroon when highlighted
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
    [cell setSelectedBackgroundView:bgColorView];
    //Set font of cells
    cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    
    
    if (tableView == followedBeaconsTableView)
    {
        
        if (_myUserData.followedBeacons != nil && isCurrentUserProfile) {
            
            if (indexPath.section == 0) {
                
                NSDictionary *beaconDictionary = [_myUserData.followedBeacons objectAtIndex:indexPath.row];
                cell.textLabel.text = [beaconDictionary objectForKey:@"name"];
                int numFollowers = [[beaconDictionary objectForKey:@"num_followers"] intValue];
                cell.detailTextLabel.text = [NSString stringWithFormat: @"%d follower%@", numFollowers, numFollowers == 1 ? @"" : @"s"];
                UIButton *discoverFollowedBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
                [discoverFollowedBeaconButton setImage:[UIImage imageNamed:@"btn_mylocation_inverted.png"] forState:UIControlStateNormal];
                [discoverFollowedBeaconButton addTarget:self action:@selector(discoverFollowedBeacon:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = discoverFollowedBeaconButton;
                
                NSString *urlString = [beaconDictionary objectForKey:@"picture_thumb"];
                if([urlString isKindOfClass:[NSString class]]) {
                    AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,50,50) imageURL:[NSURL URLWithString:urlString] cache:self.cache];
                    aiv.tag = CELL_ASYNC_IMAGE_TAG;
                    cell.indentationLevel = 1;
                    cell.indentationWidth = 55;
                    [cell.contentView addSubview:aiv];
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"ico_defaultbeacon.png"];
                }
                
                
                return cell;
            
            }else if (indexPath.section == 1){
                
                if ((indexPath.row != [suggestedResponseArray count])) {
                
                    NSDictionary *beaconDictionary = [suggestedResponseArray objectAtIndex:indexPath.row];
                    cell.textLabel.text = [beaconDictionary objectForKey:@"name"];
                    int numFollowers = [[beaconDictionary objectForKey:@"num_followers"] intValue];
                    cell.detailTextLabel.text = [NSString stringWithFormat: @"%d follower%@", numFollowers, numFollowers == 1 ? @"" : @"s"];
                    UIButton *discoverFollowedBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
                    [discoverFollowedBeaconButton setImage:[UIImage imageNamed:@"btn_mylocation_inverted.png"] forState:UIControlStateNormal];
                    [discoverFollowedBeaconButton addTarget:self action:@selector(discoverFollowedBeacon:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = discoverFollowedBeaconButton;
                    
                    NSString *urlString = [beaconDictionary objectForKey:@"picture_thumb"];
                    if([urlString isKindOfClass:[NSString class]]) {
                        AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,50,50) imageURL:[NSURL URLWithString:urlString] cache:self.cache];
                        aiv.tag = CELL_ASYNC_IMAGE_TAG;
                        cell.indentationLevel = 1;
                        cell.indentationWidth = 55;
                        [cell.contentView addSubview:aiv];
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"ico_defaultbeacon.png"];
                    }
                    
                    
                    return cell;
                }else if (indexPath.row == [suggestedResponseArray count]){
                    
                    cell.textLabel.text = @"more...";
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = nil;
                    return cell;
                    
                }
            }
            
        }else if (followedResponseArray){
            
            if (indexPath.section == 0) {
                
                NSDictionary *beaconDictionary = [followedResponseArray objectAtIndex:indexPath.row];
                cell.textLabel.text = [beaconDictionary objectForKey:@"name"];
                int numFollowers = [[beaconDictionary objectForKey:@"num_followers"] intValue];
                cell.detailTextLabel.text = [NSString stringWithFormat: @"%d follower%@", numFollowers, numFollowers == 1 ? @"" : @"s"];
                UIButton *discoverFollowedBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
                [discoverFollowedBeaconButton setImage:[UIImage imageNamed:@"btn_mylocation_inverted.png"] forState:UIControlStateNormal];
                [discoverFollowedBeaconButton addTarget:self action:@selector(discoverFollowedBeacon:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = discoverFollowedBeaconButton;
                
                NSString *urlString = [beaconDictionary objectForKey:@"picture_thumb"];
                if([urlString isKindOfClass:[NSString class]]) {
                    AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,50,50) imageURL:[NSURL URLWithString:urlString] cache:self.cache];
                    aiv.tag = CELL_ASYNC_IMAGE_TAG;
                    cell.indentationLevel = 1;
                    cell.indentationWidth = 55;
                    [cell.contentView addSubview:aiv];
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"ico_defaultbeacon.png"];
                }
                
                
                return cell;
                
            }else if (indexPath.section == 1){
                
                if ((indexPath.row != [suggestedResponseArray count])) {
                    
                    NSDictionary *beaconDictionary = [suggestedResponseArray objectAtIndex:indexPath.row];
                    cell.textLabel.text = [beaconDictionary objectForKey:@"name"];
                    int numFollowers = [[beaconDictionary objectForKey:@"num_followers"] intValue];
                    cell.detailTextLabel.text = [NSString stringWithFormat: @"%d follower%@", numFollowers, numFollowers == 1 ? @"" : @"s"];
                    UIButton *discoverFollowedBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
                    [discoverFollowedBeaconButton setImage:[UIImage imageNamed:@"btn_mylocation_inverted.png"] forState:UIControlStateNormal];
                    [discoverFollowedBeaconButton addTarget:self action:@selector(discoverFollowedBeacon:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = discoverFollowedBeaconButton;
                    
                    NSString *urlString = [beaconDictionary objectForKey:@"picture_thumb"];
                    if([urlString isKindOfClass:[NSString class]]) {
                        AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,50,50) imageURL:[NSURL URLWithString:urlString] cache:self.cache];
                        aiv.tag = CELL_ASYNC_IMAGE_TAG;
                        cell.indentationLevel = 1;
                        cell.indentationWidth = 55;
                        [cell.contentView addSubview:aiv];
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"ico_defaultbeacon.png"];
                    }
                    
                    
                    return cell;
                }else if (indexPath.row == [suggestedResponseArray count]){
                    
                    cell.textLabel.text = @"more...";
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = nil;
                    return cell;
                    
                }
            }

        }
    }
    else if (tableView == recentActivityTable)
    {
        NSLog(@"activity is: %@", activityArray);
        if (activityArray != nil)
        {
            RadiusEvent *event = [activityArray objectAtIndex:indexPath.row];
            NSLog(@" the radius event is :%@", [activityArray objectAtIndex:indexPath.row]);
            if ([event isMemberOfClass:[BeaconCreateEvent class]])
            {
                [cell.imageView setImage:[UIImage imageNamed:@"ico_beaconpin_blank.png"]];
            }
            else if ([event isMemberOfClass:[ContentPostEvent class]])
            {
                //[self loadImage:[event eventImageURL] toCell:cell atIndexPath:indexPath];
                cell.indentationWidth = 65;
                cell.indentationLevel = 1;
                AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(5,5,55,55) imageURL:[NSURL URLWithString:event.eventImageURL] cache:self.cache];
                aiv.tag = CELL_ASYNC_IMAGE_TAG;
                [cell.contentView addSubview:aiv];
            }
            
            DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
            NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:event.timestamp];
            NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date
            
            cell.textLabel.text = [event recentActivityText];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 5;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"at %@ about %@", [event.beaconInfo objectForKey:@"name"], dateString];
            cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.detailTextLabel.numberOfLines = 2;
            
            UISwipeGestureRecognizer *swipeLeftToDeleteRecentActivity = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteRecentActivity:)];
            [swipeLeftToDeleteRecentActivity setDelegate:self];
            [swipeLeftToDeleteRecentActivity setDirection:UISwipeGestureRecognizerDirectionLeft];
            [cell addGestureRecognizer:swipeLeftToDeleteRecentActivity];
            
            UISwipeGestureRecognizer *swipeRightToDeleteRecentActivity = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteRecentActivity:)];
            [swipeRightToDeleteRecentActivity setDelegate:self];
            [swipeRightToDeleteRecentActivity setDirection:UISwipeGestureRecognizerDirectionRight];
            [cell addGestureRecognizer:swipeRightToDeleteRecentActivity];
            
            UIButton *deleteConvoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
            [deleteConvoPostButton addTarget:self action:@selector(deleteRecentActivity:) forControlEvents:UIControlEventTouchUpInside];
            [deleteConvoPostButton setImage:[UIImage imageNamed:@"btn_close_black@2x.png"] forState:UIControlStateNormal];
            [deleteConvoPostButton setTag:DELETE_CONVO_BUTTON_TAG];
            deleteConvoPostButton.alpha = 0;
            deleteConvoPostButton.userInteractionEnabled = NO;
            [cell addSubview:deleteConvoPostButton];
        }
        
        
        return cell;
    }
    else
    {
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        }
        cell.textLabel.text = @"no data";
    }
    
    return cell;
}


-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == followedBeaconsTableView)
    {
        if (indexPath.section == 0) {
            
            if (responseArray !=nil) {
                BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
                [createdBeaconInstance initializeWithBeaconDictionary:[responseArray objectAtIndex:indexPath.row]];
                
                [self.navigationController pushViewController:createdBeaconInstance animated:YES];
            }else if (_myUserData.followedBeacons !=nil){
                BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
                [createdBeaconInstance initializeWithBeaconDictionary:[_myUserData.followedBeacons objectAtIndex:indexPath.row]];
                
                [self.navigationController pushViewController:createdBeaconInstance animated:YES];
                
            }
        

            
        }else if (indexPath.section == 1){
            
            if (indexPath.row != [suggestedResponseArray count]) {
                
                BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
                [createdBeaconInstance initializeWithBeaconDictionary:[suggestedResponseArray objectAtIndex:indexPath.row]];
                
                [self.navigationController pushViewController:createdBeaconInstance animated:YES];
                
            }else if (indexPath.row == [suggestedResponseArray count]){
                
                NSLog(@"finding more beacons");
                [self.followedBeaconsTableView deselectRowAtIndexPath:indexPath animated:YES];
                [self findSuggestedBeaconsWithOffset:[NSString stringWithFormat:@"%u",[suggestedResponseArray count]] andLimit:[NSString stringWithFormat:@"10"]];
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [aiv setFrame:CGRectMake(144, 6, 32, 32)];
                [aiv setTag:ACTIVITY_MORE_BUTTON_TAG];
                [aiv startAnimating];
                self.indexPathToMoreButton = indexPath;
                [[self.followedBeaconsTableView cellForRowAtIndexPath:indexPath]addSubview:aiv];
                
                
            }
            

            
        }
    }
    else if (tableView == recentActivityTable)
    {
        RadiusEvent *event = [activityArray objectAtIndex:indexPath.row];
        
        UIViewController *next = [event linkViewController];
        
        if(next) {
            [self.navigationController pushViewController:next animated:YES];
        }
        
        return;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == recentActivityTable){
        
        RadiusEvent *event = [activityArray objectAtIndex:indexPath.row];

        NSString *cellText = [event recentActivityText];
        UIFont *cellFont = [UIFont fontWithName:@"Quicksand" size:15.0];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height +50;
        
    }
    
    return 50;
}


-(void) findFollowedBeacons {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.userID], @"user",nil] apiMethod:@"followed" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        // deal with response object
        //        NSLog(@"working %@", response);
        [[followedBeaconsTableView viewWithTag:FOLLOWED_LOADING_TAG] removeFromSuperview];
        if ([response isKindOfClass:[NSArray class]]) {
            responseArray = response;
            followedResponseArray = response;
            if (isCurrentUserProfile) {
                [_myUserData setFollowedBeacons:followedResponseArray];

            }
    
            [self setupFootPrint];
            [followedBeaconsTableView reloadData];
            
            NSInteger numFollowed = followedResponseArray.count;
            favoritePlacesLabel.text = [NSString stringWithFormat:@"%d followed beacon%@",numFollowed,numFollowed==1?@"":@"s"];


        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseDictionary = response;
            [followedBeaconsTableView reloadData];
            
            followedResponseDictionary = response;
            [self setupFootPrint];

        }
    }];
    
}

-(void) findSuggestedBeaconsWithOffset: (NSString *)offset andLimit: (NSString *)limit {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:offset, @"offset", limit, @"limit",nil] apiMethod:@"beacon/suggested" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        // deal with response object
        NSLog(@"working %@", response);
//        [[followedBeaconsTableView viewWithTag:FOLLOWED_LOADING_TAG] removeFromSuperview];
        if ([response isKindOfClass:[NSArray class]]) {
            
                if ([suggestedResponseArray count]==0) {
                    suggestedResponseArray = [response mutableCopy];
                    [followedBeaconsTableView reloadData];

                }else{
                    
                    if ([response count] == 0){
                        
                        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Finding More Beacons" message:@"We're trying to find some better beacons for you, in the meantime, why not try Discover?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [av show];
                        [[[self.followedBeaconsTableView cellForRowAtIndexPath:indexPathToMoreButton]viewWithTag:ACTIVITY_MORE_BUTTON_TAG]removeFromSuperview];
                        
                    }else {
                    
                        NSArray *myResponse = (NSArray *)response;
                        [suggestedResponseArray addObjectsFromArray:myResponse];
                        [followedBeaconsTableView reloadData];
                        [[[self.followedBeaconsTableView cellForRowAtIndexPath:indexPathToMoreButton]viewWithTag:ACTIVITY_MORE_BUTTON_TAG]removeFromSuperview];
                    
                    }
                    
                }
          
            
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            suggestedResponseDictionary = response;
            [followedBeaconsTableView reloadData];
            
        }
    }];
    
}

- (IBAction)recentActivityPressed:(id)sender
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Viewed Recent Activity"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.userID],@"user",[NSNumber numberWithBool:isCurrentUserProfile],@"self", nil];
    [Flurry logEvent:@"Profile_Activity_Pressed" withParameters:eventParameters];
    
    [self setStateRecentActivitySelected];
}
- (IBAction)followedBeaconsPressed:(id)sender
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Viewed Followed Beacons"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.userID],@"user",[NSNumber numberWithBool:isCurrentUserProfile],@"self", nil];
    [Flurry logEvent:@"Profile_Followed_Pressed" withParameters:eventParameters];
    
    [self setStateFollowedBeaconsSelected];
}
- (IBAction)beaconMapPressed:(id)sender
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Viewed Footprint"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.userID],@"user",[NSNumber numberWithBool:isCurrentUserProfile],@"self", nil];
    [Flurry logEvent:@"Profile_Footprint_Pressed" withParameters:eventParameters];
    
    [self setStateBeaconMapSelected];
}

-(void)setStateRecentActivitySelected
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [footprintMap setHidden:YES];
                         [followedBeaconsTableView setHidden:YES];
                         [recentActivityTable setHidden:NO];
                         
                         [recentActivityButton setAlpha:1];
                         [followedBeaconsButton setAlpha:.4];
                         [beaconMapButton setAlpha:.4];
                         
                         
//                         [recentActivityButton setSelected:YES];
//                         [followedBeaconsButton setSelected:NO];
//                         [beaconMapButton setSelected:NO];
                         
                         
                     }completion:^(BOOL finished) {
                         
                         
                         
                     }];
    

}

-(void)setStateFollowedBeaconsSelected
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [footprintMap setHidden:YES];
                         [followedBeaconsTableView setHidden:NO];
                         [recentActivityTable setHidden:YES];
                         
                         [recentActivityButton setAlpha:.4];
                         [followedBeaconsButton setAlpha:1];
                         [beaconMapButton setAlpha:.4];
                         
                         
                     }completion:^(BOOL finished) {
                         
                         
                         
                     }];
    
    


}

-(void)setStateBeaconMapSelected
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [footprintMap setHidden:NO];
                         [followedBeaconsTableView setHidden:YES];
                         [recentActivityTable setHidden:YES];
                         
                         [recentActivityButton setAlpha:.4];
                         [followedBeaconsButton setAlpha:.4];
                         [beaconMapButton setAlpha:1];
                         
                         
                     }completion:^(BOOL finished) {
                         
                         if(followedResponseArray.count == 0 && footprintMap.annotations.count>0) {
                             [footprintMap selectAnnotation:[footprintMap.annotations objectAtIndex:0] animated:YES];
                         }
                         
                         
                         
                     }];
    
//    [footprintMap setHidden:NO];
//    [followedBeaconsTableView setHidden:YES];
//    [recentActivityTable setHidden:YES];
//    [recentActivityButton setSelected:NO];
//    [followedBeaconsButton setSelected:NO];
//    [beaconMapButton setSelected:YES];
    

}

-(void) setupTabButtons
{
    [recentActivityButton setBackgroundImage:[UIImage imageNamed:@"btn_mp_recentactivity_highlight.png"] forState:UIControlStateSelected];
    [recentActivityButton setBackgroundImage:[UIImage imageNamed:@"btn_mp_recentactivity_highlight.png"] forState:UIControlStateHighlighted];
    [followedBeaconsButton setBackgroundImage:[UIImage imageNamed:@"btn_mp_followedbeacons_highlight.png"] forState:UIControlStateSelected];
    [followedBeaconsButton setBackgroundImage:[UIImage imageNamed:@"btn_mp_followedbeacons_highlight.png"] forState:UIControlStateHighlighted];
    [beaconMapButton setBackgroundImage:[UIImage imageNamed:@"btn_mp_footprint_highlight@2x.png"] forState:UIControlStateSelected];
    [beaconMapButton setBackgroundImage:[UIImage imageNamed:@"btn_mp_footprint_highlight@2x.png"] forState:UIControlStateHighlighted];
//    [recentActivityButton setSelected:YES];
}

- (IBAction)settingsPressed:(id)sender
{
    //Transition to the settings page
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewID"];
    [settingsVC setTitle:@"Settings"];
    settingsVC.theSettingsDelegate = self;
    [self.navigationController pushViewController:settingsVC animated:YES];
}

//Hides the settings button if not on the user's own Me page
-(void)setupSettingsButton
{
    settingsButton.hidden = !isCurrentUserProfile;
}

-(void) setupFriendButton {
    friendButtonOutlet.hidden = NO;
    if(isFriendOfCurrentUser) {
        [friendButtonOutlet setImage:[UIImage imageNamed:@"btn_mp_unfriend"] forState:UIControlStateNormal];
    } else {
        [friendButtonOutlet setImage:[UIImage imageNamed:@"btn_mp_addfriend"] forState:UIControlStateNormal];
    }    
    
}

- (IBAction)friendButtonPressed:(id)sender {
    
    friendButtonOutlet.enabled = NO;
    
    if (!isCurrentUserProfile) {
    
        if (isFriendOfCurrentUser) {
            
            isFriendOfCurrentUser = NO;
            [self setupFriendButton];
            
            [friendButtonOutlet setTitle:@"Add" forState:UIControlStateNormal];
            [friendButtonOutlet setUserInteractionEnabled:NO];
            NSString *stringForUserID = [NSString stringWithFormat:@"%u", self.userID];
            RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:stringForUserID, @"users",nil] apiMethod:@"me/friends/remove" httpMethod:@"POST"];
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                friendButtonOutlet.enabled = YES;
                
                if (response) {
                    NSLog(@"response: %@", response);
                    [friendButtonOutlet setUserInteractionEnabled:YES];
                    _myUserData.friends = nil;

                    
                }
                
                if (error) {
                    isFriendOfCurrentUser = YES;
                    [self setupFriendButton];
                }
                
            }];
            
        }else if (!isFriendOfCurrentUser){
            
            isFriendOfCurrentUser = YES;
            [self setupFriendButton];
            
            [friendButtonOutlet setTitle:@"Remove" forState:UIControlStateNormal];
            [friendButtonOutlet setUserInteractionEnabled:NO];
            NSString *stringForUserID = [NSString stringWithFormat:@"%u", self.userID];
            
            RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:stringForUserID, @"users",nil] apiMethod:@"me/friends/add" httpMethod:@"POST"];
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                friendButtonOutlet.enabled = YES;
                
                if (response) {
                    NSLog(@"response: %@", response);
                    [friendButtonOutlet setUserInteractionEnabled:YES];
                    _myUserData.friends = nil;
                }
                
                if (error) {
                    isFriendOfCurrentUser = NO;
                    [self setupFriendButton];
                }
                
            }];
            
        }
        
        
    }
}

-(void) changeProfilePictureToSelectedImage:(UIImage *)imageSelected {
    
//    [[profilePictureButton viewWithTag:PROFILE_PICTURE_TAG]removeFromSuperview];
//    [profilePictureButton setImage:imageSelected forState:UIControlStateNormal];
//    profilePictureButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [profilePictureButton setEnabled:NO];
//    [profilePictureButton setAlpha:1];
    
//    [self loadMeInfo];
    
    profilePictureView.imageView.image = imageSelected;
    
}

-(void) discoverFollowedBeacon: (id)sender {
    
    UITableViewCell *owningCell = (UITableViewCell*)[sender superview];
    NSIndexPath *pathToCell = [followedBeaconsTableView indexPathForCell:owningCell];
    
    NSLog(@" omgz button pressed row at %d and section %d", pathToCell.row, pathToCell.section);

    if (pathToCell.section == 0) {
        
        if (isCurrentUserProfile) {
            
            NSDictionary *currentFollowedBeaconInQuestion = [_myUserData.followedBeacons objectAtIndex:pathToCell.row];
            CLLocationDegrees nextFollowedBeaconLatitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:0]floatValue];;
            CLLocationDegrees nextFollowedBeaconLongitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:1]floatValue];;
            CLLocation *nextFollowedBeaconLocation = [[CLLocation alloc] initWithLatitude:nextFollowedBeaconLatitude longitude:nextFollowedBeaconLongitude];
            
            MapViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"mapViewID"];
            
            [newViewController setDiscoverFollowedBeaconLocation:nextFollowedBeaconLocation];
            [newViewController setBeaconToSelect:[currentFollowedBeaconInQuestion objectForKey:@"id"]];
            [newViewController setInitialLocationSet:YES];
            
            [[MFSideMenuManager sharedManager].navigationController pushViewController:newViewController animated:YES];
        }else if ([responseArray objectAtIndex:pathToCell.row]){
            
            NSDictionary *currentFollowedBeaconInQuestion = [_myUserData.followedBeacons objectAtIndex:pathToCell.row];
            CLLocationDegrees nextFollowedBeaconLatitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:0]floatValue];;
            CLLocationDegrees nextFollowedBeaconLongitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:1]floatValue];;
            CLLocation *nextFollowedBeaconLocation = [[CLLocation alloc] initWithLatitude:nextFollowedBeaconLatitude longitude:nextFollowedBeaconLongitude];
            
            MapViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"mapViewID"];
            
            [newViewController setDiscoverFollowedBeaconLocation:nextFollowedBeaconLocation];
            [newViewController setInitialLocationSet:YES];
            
            [[MFSideMenuManager sharedManager].navigationController pushViewController:newViewController animated:YES];
            
            
        }
    

        
    }else if (pathToCell.section == 1){
        
        NSDictionary *currentFollowedBeaconInQuestion = [suggestedResponseArray objectAtIndex:pathToCell.row];
        CLLocationDegrees nextFollowedBeaconLatitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:0]floatValue];;
        CLLocationDegrees nextFollowedBeaconLongitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:1]floatValue];;
        CLLocation *nextFollowedBeaconLocation = [[CLLocation alloc] initWithLatitude:nextFollowedBeaconLatitude longitude:nextFollowedBeaconLongitude];
        
        MapViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"mapViewID"];
        
        [newViewController setDiscoverFollowedBeaconLocation:nextFollowedBeaconLocation];
        [newViewController setInitialLocationSet:YES];
        
        [[MFSideMenuManager sharedManager].navigationController pushViewController:newViewController animated:YES];
        
    }
}


#pragma mark Apple Methods Handle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _myUserData = [RadiusUserData sharedRadiusUserData];

    self.cache = [[NSMutableDictionary alloc] init];
    [self setupTabButtons];
    [namePanel setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_profile.png"]]];
    
    
    NSUInteger uid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] integerValue];
    
    if(self.userID && self.userID!=uid) {
        isCurrentUserProfile = NO;
        friendButtonOutlet.hidden = YES;
        [self loadUserInfo];
#ifdef CONFIGURATION_TestFlight
        [TestFlight passCheckpoint:@"Looked at another User's Profile"];
#endif
    } else {
        // If the user ID property isn't set, this is the current user's profile
        self.userID = uid;
        isCurrentUserProfile = YES;
        friendButtonOutlet.hidden = YES;
        [self loadMeInfo];
#ifdef CONFIGURATION_TestFlight
        [TestFlight passCheckpoint:@"Looked at their Profile"];
#endif
    }
    
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.userID],@"user",[NSNumber numberWithBool:isCurrentUserProfile],@"self", nil];
    [Flurry logEvent:@"Profile_Viewed" withParameters:eventParameters];
    
    
    [self setupSettingsButton];
    [self addLoadingViews];
    [self setupLookAndFeel];
    [self setupSideMenuBarButtonItem];
    [self setStateFollowedBeaconsSelected];
    [self setupFootPrint];
    self.recentActivityTableIsEditing = NO;
    [self setupDismissCellEditing];
    
    self.suggestedResponseArray = [[NSMutableArray alloc]init];
    [self findSuggestedBeaconsWithOffset:[NSString stringWithFormat:@"0"] andLimit:[NSString stringWithFormat:@"10"]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
//    if (recentActivityTable.hidden) {
//        [followedBeaconsTableView setHidden:NO];
//        
//    }else if (recentActivityTable.hidden == NO){
//        [followedBeaconsTableView setHidden:YES];
//        
//        
//    }
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [self setStateFollowedBeaconsSelected];

    
	// Unselect the selected row if any in either table
	NSIndexPath*	activitySelection = [self.recentActivityTable indexPathForSelectedRow];
	if (activitySelection)
    {
        [self.recentActivityTable deselectRowAtIndexPath:activitySelection animated:YES];
        [self.recentActivityTable reloadData];
    }
    NSIndexPath*	favoriteBeaconSelection = [self.followedBeaconsTableView indexPathForSelectedRow];
	if (favoriteBeaconSelection)
    {
        [self.followedBeaconsTableView deselectRowAtIndexPath:favoriteBeaconSelection animated:YES];
        [self.followedBeaconsTableView reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"profile disappearing");
}

- (NSMutableData *)jsonData
{
    if (!_jsonData) _jsonData = [[NSMutableData alloc] init];
    return _jsonData;
}
- (NSDictionary *)jsonDictionary
{
    if (!_jsonDictionary) _jsonDictionary = [[NSDictionary alloc] init];
    return _jsonDictionary;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setFollowedBeaconsTableView:nil];
    [self setRecentActivityButton:nil];
    [self setFollowedBeaconsButton:nil];
    [self setBeaconMapButton:nil];
    [self setNamePanel:nil];
    [self setSettingsButton:nil];
    [self setFavoritePlacesLabel:nil];
    [self setFootprintMap:nil];
    [self setFriendButtonOutlet:nil];
    [super viewDidUnload];
}

-(void) revealDeleteRecentActivity: (UISwipeGestureRecognizer *)sender {
    
    
    
    if (sender.state == UIGestureRecognizerStateEnded && recentActivityTableIsEditing == NO) {
        
        recentActivityTableIsEditing = YES;

        
        CGPoint swipeLocation = [sender locationInView:self.recentActivityTable];
        indexPathToEditingCell = [self.recentActivityTable indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.recentActivityTable cellForRowAtIndexPath:indexPathToEditingCell];
        RadiusEvent *event = [activityArray objectAtIndex:indexPathToEditingCell.row];
        NSDictionary *myThreadDictionary = event.performerInfo;
        NSLog(@"%@", myThreadDictionary);
        NSString *convoPostAuthor = [NSString stringWithFormat:@"%@",[myThreadDictionary objectForKey:@"id"]];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *theCurrentUserID = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"id"]];
        
        if ([theCurrentUserID isEqualToString:convoPostAuthor]) {
            
            
            
            [UIView animateWithDuration:0.4
                                  delay:0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^ {
                                 
                                 swipedCell.textLabel.alpha = 0.5;
                                 swipedCell.detailTextLabel.alpha = 0.5;
                                 swipedCell.imageView.alpha = 0.5;
                                 [[swipedCell viewWithTag:CELL_ASYNC_IMAGE_TAG] setAlpha:0.5];
                                 [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setAlpha:1];
                                 
                             }completion:^(BOOL finished) {
                                 
                                 [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setUserInteractionEnabled:YES];
                                 tapToStopEditingTapGestureRecognizer.enabled = YES;
                                 self.recentActivityTable.scrollEnabled = NO;
                                 self.settingsButton.userInteractionEnabled = NO;
                                 self.followedBeaconsButton.userInteractionEnabled = NO;
                                 self.recentActivityButton.userInteractionEnabled = NO;
                                 self.beaconMapButton.userInteractionEnabled = NO;
                                 
                             }];
            
        }
        
    }else
        return;
}

-(void) setupDismissCellEditing {
    
    tapToStopEditingTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopTableEditing:)];
    tapToStopEditingTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapToStopEditingTapGestureRecognizer];
        
}

-(void) stopTableEditing: (UITapGestureRecognizer *) sender {
    
    if (sender.state == UIGestureRecognizerStateEnded && recentActivityTableIsEditing == YES && indexPathToEditingCell != nil) {
        
        UITableViewCell* swipedCell = [self.recentActivityTable cellForRowAtIndexPath:indexPathToEditingCell];
        
        
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             
                             swipedCell.textLabel.alpha = 1;
                             swipedCell.detailTextLabel.alpha = 1;
                             swipedCell.imageView.alpha = 0.5;
                             [[swipedCell viewWithTag:CELL_ASYNC_IMAGE_TAG] setAlpha:1];
                             [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setAlpha:0];
                             
                         }completion:^(BOOL finished) {
                             
                             [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setUserInteractionEnabled:NO];
                             recentActivityTableIsEditing = NO;
                             tapToStopEditingTapGestureRecognizer.enabled = NO;
                             self.recentActivityTable.scrollEnabled = YES;
                             indexPathToEditingCell = nil;
                             self.settingsButton.userInteractionEnabled = YES;
                             self.followedBeaconsButton.userInteractionEnabled = YES;
                             self.recentActivityButton.userInteractionEnabled = YES;
                             self.beaconMapButton.userInteractionEnabled = YES;

                             
                         }];
        
    }else
        return;
    
    
}

-(void) deleteRecentActivity: (id) sender {
    
    if (indexPathToEditingCell != nil) {
        
        RadiusEvent *event = [activityArray objectAtIndex:indexPathToEditingCell.row];
        NSString *postToDeleteID = [NSString stringWithFormat:@"%u", event.eventID];
        
        RadiusRequest *r;
        r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: postToDeleteID, @"event", nil] apiMethod:@"user/activity/hide" httpMethod:@"POST"];
        [self showLoadingOverlay];
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                [self dismissLoadingOverlay];
                
                NSLog(@"working on creating thread, response is: %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
                
                UITableViewCell* swipedCell = [self.recentActivityTable cellForRowAtIndexPath:indexPathToEditingCell];
                
                
                [UIView animateWithDuration:0.4
                                      delay:0
                                    options:UIViewAnimationCurveEaseInOut
                                 animations:^ {
                                     
                                     swipedCell.textLabel.alpha = 1;
                                     swipedCell.detailTextLabel.alpha = 1;
                                     [[swipedCell viewWithTag:CELL_ASYNC_IMAGE_TAG] setAlpha:1];
                                     [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setAlpha:0];
                                     
                                 }completion:^(BOOL finished) {
                                     
                                     [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setUserInteractionEnabled:NO];
                                     recentActivityTableIsEditing = NO;
                                     tapToStopEditingTapGestureRecognizer.enabled = NO;
                                     self.recentActivityTable.scrollEnabled = YES;
                                     indexPathToEditingCell = nil;
                                     self.settingsButton.userInteractionEnabled = YES;
                                     self.followedBeaconsButton.userInteractionEnabled = YES;
                                     self.recentActivityButton.userInteractionEnabled = YES;
                                     self.beaconMapButton.userInteractionEnabled = YES;
                                     
                                 }];
            }else {
                
                NSLog(@"%@", error);
                [self dismissLoadingOverlay];

                
            }
            
            
            
        }];
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[otherGestureRecognizer class]]) {
        return NO;
    }else
        return YES;
    
}


@end
