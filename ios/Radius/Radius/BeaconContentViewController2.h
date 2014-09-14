//
//  BeaconContentViewController2.h
//  Radius
//
//  Created by Fred Ehrsam on 9/18/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <Twitter/Twitter.h>
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <QuartzCore/QuartzCore.h>

#import "Beacon.h"
#import "FindBeaconContent.h"
#import "MFSideMenu.h"
#import "FindBeaconInfo.h"
#import "BeaconDetailContentViewController.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "PostContentView.h"
#import "ProfileViewController2.h"
#import "SlidingTableView.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "Cell.h"
#import "TextCell.h"
#import "BeaconDetailContentImageViewController.h"
#import "BeaconDetailContentVideoViewController.h"
#import "BeaconContentConversationTextFieldDelegate.h"
#import "PostThreadView.h"
#import "AddNewContentView.h"
#import "CreateBeaconAnnotation.h"
#import "BeaconFollowers.h"
#import "DescribeContentView.h"
#import "RadiusAppDelegate.h"
#import "InviteFriendsView.h"
#import "PrivacyView.h"
#import "RadiusViewController.h"

@class BeaconFollowers;
@class SlidingTableView;

@interface BeaconContentViewController2 : RadiusViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGridViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, PostThreadViewDelegate, MKMapViewDelegate>{
    
    SlidingTableView *_customSlidingTableView;
    NSMutableDictionary *imageCacheDictionary;
}

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



@property (strong, nonatomic) NSMutableArray *contentArray;


- (IBAction)viewBeaconCreatorProfile:(id)sender;
//- (IBAction)postContentButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *postContentButton;
- (IBAction)beaconCreatorSettingsButtonPressed:(id)sender;

- (IBAction)followBeaconButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *followBeaconButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *numberFollowingButton;

@property (nonatomic) BOOL currentBeaconisFollowed;
@property (nonatomic) BOOL currentBeaconisMeBeacon;
@property (nonatomic, retain) CLLocationManager* locationManager;

@property (strong, nonatomic) NSString *sendingBeaconID;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userNameString;
@property (strong, nonatomic) NSString *currentUserNameString;
@property (strong, nonatomic) NSString *beaconNameString;



@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;

@property (nonatomic, strong) NSMutableArray *responseFollowedArray;
@property (nonatomic, strong) NSMutableDictionary *responseFollowedDictionary;

@property (weak, nonatomic) IBOutlet UITableView *convoTable;


//- (IBAction)handleGesture;
@property (nonatomic) int swipeCount;


-(void) reloadBeaconContentDataTable;
-(void) reloadConversationTable;

@property (nonatomic, retain) IBOutlet UIGridView *myGridView;
@property (nonatomic, strong) NSMutableArray *convoArray;
@property (weak, nonatomic) IBOutlet UIButton *topContentButton;
@property (weak, nonatomic) IBOutlet UIButton *liveConversationButton;
@property (weak, nonatomic) IBOutlet UIButton *locationInfoButton;
@property (weak, nonatomic) IBOutlet UIView *beaconPanel;
@property (strong, nonatomic) IBOutlet UIButton *beaconCreatorSettingsButtonOutlet;
@property (weak, nonatomic) IBOutlet UITextView *locationInfoScrollView;
@property (strong, nonatomic) IBOutlet UITableView *beaconFollowersTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *creatorView;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (nonatomic) BOOL currentUserIsBeaconCreator;
@property (nonatomic) BOOL beaconIsPrivate;



@property (nonatomic) CGFloat animatedDistance;

@property (nonatomic) BOOL beaconJustCreated;

@property (nonatomic,strong) NSDictionary *beaconDictionary;

@property (strong, nonatomic) DescribeContentView *describeContentView;

-(void) initializeWithBeaconID:(NSString *)beaconID;
-(void) initializeWithBeaconDictionary:(NSDictionary *)beaconDictionary;

-(void) populateBeaconContent;

@property (nonatomic, retain) BeaconFollowers *beaconFollowersDataSourceInstance;
@property (strong, nonatomic) NSMutableArray *responseUserInfoArray;
@property (nonatomic, strong) NSMutableDictionary *responseUserInfoDictionary;


@property (strong, nonatomic) PostThreadView *postThreadView;
@property (strong, nonatomic) UITapGestureRecognizer *tapToEndTextViewEditingGestureRecognizer;

-(void) updateBeaconPrivacy;

#pragma mark New Design Stuff

@property (strong, nonatomic) IBOutlet UIView *happeningNowViewOutlet;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *noContentMessageOutlet;



@end
