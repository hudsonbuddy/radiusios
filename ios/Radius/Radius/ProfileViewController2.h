//
//  ProfileViewController2.h
//  Radius
//
//  Created by Hud on 7/23/12.
//
//

#import <UIKit/UIKit.h>
#import "SBJson.h"
#import "RadiusRequest.h"
#import "BeaconContentViewController2.h"
#import "MFSlidingView.h"
#import <Twitter/Twitter.h>
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>
#import "PostContentView.h"
#import "MFSideMenu/MFSideMenu.h"
#import "RadiusProgressView.h"
#import "DateAndTimeHelper.h"
#import "BeaconAnnotation.h"
#import <MapKit/MapKit.h>
#import "SettingsViewController.h"
#import "RadiusViewController.h"
#import "AsyncImageView.h"
#import "MapViewController.h"



@interface ProfileViewController2 : RadiusViewController <UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIButton *profilePictureButton;
    IBOutlet UILabel *displayNameLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *profilePictureButton;
@property (nonatomic, retain) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;
@property (nonatomic, strong) NSMutableArray *activityArray;
@property (nonatomic, strong) NSMutableDictionary *activityDictionary;
- (IBAction)profilePicturePressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *followedBeaconsTableView;
@property (nonatomic) NSUInteger userID;
@property (weak, nonatomic) IBOutlet UITableView *recentActivityTable;
@property (weak, nonatomic) IBOutlet UIButton *recentActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *followedBeaconsButton;
@property (weak, nonatomic) IBOutlet UIButton *beaconMapButton;
@property (weak, nonatomic) IBOutlet UIView *namePanel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *favoritePlacesLabel;
@property (strong, nonatomic) IBOutlet MKMapView *footprintMap;
@property (strong, nonatomic) IBOutlet UIButton *friendButtonOutlet;
@property (nonatomic, strong) NSMutableDictionary *followedResponseDictionary;
@property (nonatomic, strong) NSMutableArray *followedResponseArray;
@property (nonatomic, strong) NSMutableArray *suggestedResponseArray;
@property (nonatomic, strong) NSMutableDictionary *suggestedResponseDictionary;

@property (nonatomic) BOOL recentActivityTableIsEditing;
@property (nonatomic, strong) NSIndexPath *indexPathToEditingCell;
@property (nonatomic, strong) NSIndexPath *indexPathToMoreButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapToStopEditingTapGestureRecognizer;

- (IBAction)friendButtonPressed:(id)sender;

-(void) initializeWithUserID:(NSUInteger)uid;

@end
