//
//  InviteFriendsView.h
//  radius
//
//  Created by Hud on 11/29/12.
//
//

#import <UIKit/UIKit.h>
#import "InviteFriendsViewController.h"
#import "MFSlidingView.h"
#import "MFSideMenu.h"

@interface InviteFriendsView : UIView
@property (strong, nonatomic) IBOutlet UIButton *inviteFriendsButtonOutlet;
- (IBAction)inviteFriendsButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *shareThisBeaconOutlet;
- (IBAction)shareBeaconButtonPressed:(id)sender;

@property (strong, nonatomic) NSString *beaconID;
@property (strong, nonatomic) NSString *beaconName;


@end
