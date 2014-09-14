//
//  BeaconContentViewController.h
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <Twitter/Twitter.h>
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>

#import "Beacon.h"
#import "FindBeaconContent.h"
#import "MFSideMenu.h"
#import "CreateDetailViewController.h"
#import "FindBeaconInfo.h"
#import "BeaconDetailContentViewController.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "PostContentView.h"
#import "PostBeaconUploadImageContent.h"
#import "ProfileViewController.h"
#import "SlidingTableView.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "Cell.h"
#import "TextCell.h"
#import "BeaconDetailContentImageViewController.h"
#import "BeaconDetailContentVideoViewController.h"


@class SlidingTableView;

@interface BeaconContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGridViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    SlidingTableView *_customSlidingTableView;
}

@property (nonatomic, strong) Beacon * currentBeacon;
@property (strong, nonatomic) IBOutlet UILabel *beaconNameOutlet;
@property (strong, nonatomic) IBOutlet UILabel *beaconContentOutlet;
@property (strong, nonatomic) IBOutlet UILabel *beaconLocationOutlet;
@property (strong, nonatomic) IBOutlet MKMapView *contentMapView;
@property (nonatomic, retain) NSMutableArray *mapAnnotations;

@property (nonatomic, strong) FindBeaconContent *contentFinder;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSMutableArray *jsonArray;
@property (strong, nonatomic) IBOutlet UITableView *contentTableView;
@property (strong, nonatomic) NSString *currentTweetToDisplay;
@property (strong, nonatomic) __block NSMutableDictionary *twitterResponse;
@property (strong, nonatomic) NSDictionary *jsonInfoArray;
@property (strong, nonatomic) IBOutlet UIButton *beaconCreatorProfileButton;

- (IBAction)viewBeaconCreatorProfile:(id)sender;
- (IBAction)postContentButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *postContentButton;

- (IBAction)followBeaconButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *followBeaconButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *numberFollowingButton;

@property (nonatomic) BOOL currentBeaconisFollowed;
@property (nonatomic) BOOL currentBeaconisMeBeacon;
@property (nonatomic, retain) CLLocationManager* locationManager;

@property (strong, nonatomic) NSString *sendingBeaconID;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userNameString;

@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;

@property (nonatomic, strong) NSMutableArray *responseFollowedArray;
@property (nonatomic, strong) NSMutableDictionary *responseFollowedDictionary;

@property (weak, nonatomic) IBOutlet UITableView *convoTable;


- (IBAction)handleGesture;
@property (nonatomic) int swipeCount;


-(void) reloadBeaconContentDataTable;
-(void) reloadConversationTable;

@property (nonatomic, retain) IBOutlet UIGridView *myGridView;
@property (nonatomic, strong) NSMutableArray *convoArray;

@end
