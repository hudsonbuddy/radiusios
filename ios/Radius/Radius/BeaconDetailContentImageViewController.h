//
//  BeaconDetailContentImageViewController.h
//  radius
//
//  Created by Hud on 9/6/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MFSideMenu/MFSideMenu.h"
#import "MFSlidingView.h"
#import "SlidingCommentView.h"
#import "RadiusAppDelegate.h"
#import "RadiusRequest.h"
#import "ShareToFacebookView.h"
#import "DateAndTimeHelper.h"
#import "RadiusViewController.h"
#import "ContentCreatorSettingsView.h"

@protocol BeaconDetailContentImageDelegate;

@interface BeaconDetailContentImageViewController : RadiusViewController <UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *DetailContentImageView;
@property (strong, nonatomic) IBOutlet UITableView *BeaconImageCommentTableViewOutlet;
@property (strong, nonatomic) IBOutlet UIButton *voteButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *commentButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *voteScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UIButton *beaconNameButton;
@property (weak, nonatomic) IBOutlet UIView *topInfoBarView;
@property (weak, nonatomic) IBOutlet UIView *bottomInfoBarView;
@property (strong, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *contentOwnerSettingsButton;
- (IBAction)contentOwnerSettingsButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UIView *commentView;

@property (nonatomic) BOOL contentVotedUp;
@property (nonatomic) BOOL contentVotedDown;
@property (nonatomic) BOOL contentNotVotedYet;
@property (nonatomic, strong) NSString *contentVoteScore;
@property (strong, nonatomic) NSString *contentString;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *contentID;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userNameString;
@property (strong, nonatomic) NSString *beaconIDString;
@property (strong, nonatomic) NSString *beaconNameString;
@property (strong, nonatomic) NSString *contentVoteStatus;
@property (strong, nonatomic) NSString *contentImageWidth;
@property (strong, nonatomic) NSString *contentImageHeight;
@property (strong, nonatomic) NSString *likeCountString;
@property (strong, nonatomic) NSString *commentCountString;
@property (strong, nonatomic) NSString *posterIDString;
@property (nonatomic) BOOL currentUserIsContentOwner;
@property (strong, nonatomic) NSString *initialContentIndex;
@property (strong, nonatomic) NSString *currentContentIndex;
@property (strong, nonatomic) UIImageView *currentImageView;




@property (nonatomic) double frameContentImageWidth;
@property (nonatomic) double frameContentImageHeight;
@property (nonatomic) double frameContentOriginX;
@property (nonatomic) double frameContentOriginY;

@property (nonatomic, assign) id <BeaconDetailContentImageDelegate> beaconDetailContentImageDelegate;

@property (strong, nonatomic) NSDictionary *beaconContentDictionary;
@property (strong, nonatomic) NSArray *imageArray;


- (IBAction)voteButtonPressed:(id)sender;
- (IBAction)commentButtonPressed:(id)sender;
- (void) initializeBeaconContentImage;


@end

@protocol BeaconDetailContentImageDelegate <NSObject>

-(void) populateBeaconContent;

@end

