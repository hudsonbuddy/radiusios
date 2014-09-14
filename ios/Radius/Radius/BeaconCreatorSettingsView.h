//
//  BeaconCreatorSettingsView.h
//  radius
//
//  Created by Hud on 11/16/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusAppDelegate.h"
#import "RadiusRequest.h"
#import "MFSideMenu.h"
#import "MFSlidingView.h"
#import "SideMenuViewController.h"
#import "NotificationsFind.h"
#import "PrivacyManagerViewController.h"
#import "ShareToFacebookView.h"

@protocol BeaconCreatorSettingsDelegate;


@interface BeaconCreatorSettingsView : UIView <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *beaconID;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *beaconName;
@property (strong, nonatomic) NSDictionary *beaconDictionary;
@property (nonatomic) BOOL beaconIsPrivate;
@property (nonatomic, assign) id <BeaconCreatorSettingsDelegate> beaconCreatorSettingsDelegate;



@property (strong, nonatomic) IBOutlet UIButton *inviteFriendsButtonOutlet;
- (IBAction)inviteFriendsButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *takeAPhotoButtonOutlet;
- (IBAction)takeAPhotoButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *mediaLibraryButtonOutlet;
- (IBAction)mediaLibraryButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *beaconDescriptionButtonOutlet;
- (IBAction)beaconDescriptionButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *deleteBeaconButtonOutlet;
- (IBAction)deleteBeaconButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *slideToShowDeleteBeaconLabel;
@property (strong, nonatomic) IBOutlet UIView *swipeView;
@property (strong, nonatomic) IBOutlet UILabel *privateBeaconTextLabel;
@property (strong, nonatomic) IBOutlet UIButton *privateBeaconButtonOutlet;
- (IBAction)privateBeaconButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *requestsButtonOutlet;
- (IBAction)requestsButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *shareThisBeaconButtonOutlet;
- (IBAction)shareThisBeaconButtonPressed:(id)sender;

-(void) setupBeaconCreatorSettingsView;

@end


@protocol BeaconCreatorSettingsDelegate <NSObject>


@optional

-(void)updateBeaconPrivacy;

@end
