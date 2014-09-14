//
//  BeaconDetailContentVideoViewController.h
//  radius
//
//  Created by Hud on 9/17/12.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu/MFSideMenu.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "SlidingCommentView.h"
#import "AsyncImageView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NotificationsFind.h"
#import "RadiusViewController.h"

@protocol BeaconDetailContentVideoDelegate;

@interface BeaconDetailContentVideoViewController : RadiusViewController
@property (strong, nonatomic) IBOutlet UIWebView *beaconDetailVideoWebViewOutlet;
@property (strong, nonatomic) IBOutlet UITableView *BeaconVideoCommentTableViewOutlet;
@property (strong, nonatomic) IBOutlet UIButton *voteButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *voteScoreLabel;
@property (strong, nonatomic) IBOutlet UIButton *commentButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *youtubeThumbnailImageViewOutlet;

@property (nonatomic) BOOL contentVotedUp;
@property (nonatomic) BOOL contentVotedDown;
@property (nonatomic) BOOL contentNotVotedYet;
@property (nonatomic, strong) NSString *contentVoteScore;
@property (strong, nonatomic) NSString *contentString;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *contentID;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userNameString;
@property (strong, nonatomic) NSString *likeCountString;
@property (strong, nonatomic) NSString *commentCountString;
@property (strong, nonatomic) NSString *beaconIDString;
@property (strong, nonatomic) NSString *beaconNameString;
@property (strong, nonatomic) NSDictionary *beaconContentDictionary;
- (IBAction)commentVideoButtonPressed:(id)sender;
- (IBAction)voteButtonPressed:(id)sender;

@property (nonatomic, assign) id <BeaconDetailContentVideoDelegate> beaconDetailContentVideoDelegate;

@end

@protocol BeaconDetailContentVideoDelegate <NSObject>

-(void) populateBeaconContent;

@end
