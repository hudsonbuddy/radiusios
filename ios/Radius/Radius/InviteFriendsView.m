//
//  InviteFriendsView.m
//  radius
//
//  Created by Hud on 11/29/12.
//
//

#import "InviteFriendsView.h"

@implementation InviteFriendsView
@synthesize beaconID, beaconName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)inviteFriendsButtonPressed:(id)sender {
    
    [MFSlidingView slideOut];
    
    InviteFriendsViewController *inviteVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"inviteFriendsID"];
    [inviteVC setBeaconID:beaconID];
//    [inviteVC setBeaconName:@"poop"];
    [inviteVC setJustCreated:NO];
    //NSArray *controllers = [NSArray arrayWithObject:inviteVC];
    //[MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    //[MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    [[MFSideMenuManager sharedManager].navigationController pushViewController:inviteVC animated:YES];
}
- (IBAction)shareBeaconButtonPressed:(id)sender {
    
    PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
    [popupAlert setupWithDescriptionText:@"To share on Facebook, go to settings and connect your account!" andButtonText:@"OK"];
    ShareToFacebookView *shareToFBView = [[[NSBundle mainBundle]loadNibNamed:@"ShareToFacebookView" owner:self options:nil]objectAtIndex:0];
    [shareToFBView setupFBViewWithBeaconID:beaconID];
    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    RadiusRequest *radRequest = [RadiusRequest requestWithAPIMethod:@"me"];
    [radRequest startWithCompletionHandler:^(id result, RadiusError *error)
     {
         [MFSlidingView slideOut];
         NSString *fbID = [result objectForKey:@"fb_uid"];
         if (fbID != nil && !([fbID isKindOfClass:[NSNull class]]))
         {
             [MFSlidingView slideView:shareToFBView intoView:[MFSideMenuManager sharedManager].navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
         }
         else
         {
             [MFSlidingView slideView:popupAlert intoView:[MFSideMenuManager sharedManager].navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
         }
     }];
    
    
}
@end
