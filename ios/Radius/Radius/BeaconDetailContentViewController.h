//
//  BeaconDetailContentViewController.h
//  Radius
//
//  Created by Hud on 8/2/12.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu/MFSideMenu.h"
#import "FindComments.h"
#import "PostContentComment.h"
#import "ProfileViewController2.h"
#import "PostContentView.h"
#import "MFSlidingView.h"
#import "RadiusRequest.h"
#import "SlidingCommentView.h"
#import "RadiusViewController.h"

@interface BeaconDetailContentViewController : RadiusViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>


@property (strong, nonatomic) IBOutlet UIWebView *contentWebView;
@property (strong, nonatomic) IBOutlet UILabel *contentTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) IBOutlet UIButton *profilePictureButton;
@property (strong, nonatomic) IBOutlet UIButton *voteOnCommentButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *contentVoteScoreLabel;
@property (strong, nonatomic) NSMutableArray *jsonArray;
@property (strong, nonatomic) NSDictionary *beaconContentDictionary;
@property (strong, nonatomic) NSString *contentString;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) IBOutlet UITableView *commentTableView;
@property (strong, nonatomic) NSString *contentID;
- (IBAction)contentCreatorProfileButton:(id)sender;
- (IBAction)voteOnContentButtonPressed:(id)sender;
-(void)populateCommentsTable:(NSMutableArray *)myArray;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (nonatomic) CGFloat animatedDistance;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userNameString;
@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;
@property (nonatomic) BOOL contentVotedUp;
@property (nonatomic) BOOL contentVotedDown;
@property (nonatomic) BOOL contentNotVotedYet;
@property (nonatomic, strong) NSString *contentVoteScore;


@end
