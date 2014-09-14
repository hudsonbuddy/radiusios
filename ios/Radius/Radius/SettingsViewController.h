//
//  SettingsViewController.h
//  Radius
//
//  Created by Hud on 7/23/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusProgressView.h"
#import "PostContentView.h"
#import "RadiusViewController.h"

@protocol SettingsDelegate;

@interface SettingsViewController : RadiusViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,NSURLConnectionDataDelegate>
{
    IBOutlet UIImageView *profilePictureImageView;
}

@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
//Account settings
@property (weak, nonatomic) IBOutlet UILabel *accountSettingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *profilePictureLabel;
@property (nonatomic,retain) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectFacebookButton;

//Notification Settings
@property (weak, nonatomic) IBOutlet UILabel *notificationSettingsLabel;
@property (weak, nonatomic) IBOutlet UIView *pushNotificationsView;
@property (weak, nonatomic) IBOutlet UILabel *pushNotificationsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationsSwitch;
@property (weak, nonatomic) IBOutlet UIView *contentOnFollowedBeaconView;
@property (weak, nonatomic) IBOutlet UILabel *contentOnFollowedBeaconLabel;
@property (weak, nonatomic) IBOutlet UIView *threadView;
@property (weak, nonatomic) IBOutlet UILabel *threadLabel;
@property (weak, nonatomic) IBOutlet UIView *commentOnYourPostView;
@property (weak, nonatomic) IBOutlet UILabel *commentOnYourPostLabel;
//Privacy Settings
@property (weak, nonatomic) IBOutlet UILabel *privacySettingsLabel;
@property (weak, nonatomic) IBOutlet UIView *keepLoggedInView;
@property (weak, nonatomic) IBOutlet UILabel *keepLoggedInLabel;
@property (weak, nonatomic) IBOutlet UIView *othersSeeRecentActivityView;
@property (weak, nonatomic) IBOutlet UILabel *othersSeeRecentActivityLabel;
@property (weak, nonatomic) IBOutlet UIView *othersSeeFollowedBeaconsView;
@property (weak, nonatomic) IBOutlet UILabel *othersSeeFollowedBeaconsLabel;
@property (weak, nonatomic) IBOutlet UIView *othersSeeHomeBaseView;
@property (weak, nonatomic) IBOutlet UILabel *othersSeeHomeBaseLabel;
@property (strong, nonatomic) IBOutlet UILabel *shareBeaconFollowsLabelOutlet;
@property (strong, nonatomic) IBOutlet UIButton *shareBeaconFollowsButtonOutlet;
- (IBAction)shareBeaconFollowsButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *shareCreateLabelOutlet;
@property (strong, nonatomic) IBOutlet UIButton *shareCreateButtonOutlet;
- (IBAction)shareCreateButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *takeATourButtonOutlet;


@property (nonatomic, assign) id <SettingsDelegate> theSettingsDelegate;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;

@end

@protocol SettingsDelegate <NSObject>

@optional
-(void) changeProfilePictureToSelectedImage: (UIImage *)imageSelected;

@end
