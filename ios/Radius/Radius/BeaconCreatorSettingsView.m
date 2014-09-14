//
//  BeaconCreatorSettingsView.m
//  radius
//
//  Created by Hud on 11/16/12.
//
//

#import "BeaconCreatorSettingsView.h"
#import "MFSlidingView.h"
#import "DescriptionChangeView.h"
#import "InviteFriendsViewController.h"

@implementation BeaconCreatorSettingsView

@synthesize beaconID;
@synthesize userTokenString;
@synthesize beaconName;
@synthesize beaconDictionary;
@synthesize beaconIsPrivate;
@synthesize beaconCreatorSettingsDelegate;


static const NSInteger BEACON_DELETE_ALERT_VIEW_TAG = 98212;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}






- (void) setupBeaconCreatorSettingsView {
    
    NSLog(@"setting up beacon creator settings view");
    
    [self.slideToShowDeleteBeaconLabel setText:@"Swipe To Delete Beacon >"];
    [self.slideToShowDeleteBeaconLabel setTextColor:[UIColor whiteColor]];
    [self.slideToShowDeleteBeaconLabel setFont:[UIFont fontWithName:@"Quicksand" size:14]];
    [self.slideToShowDeleteBeaconLabel setAlpha:1];
    [self.privateBeaconButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];

    self.deleteBeaconButtonOutlet.alpha = 0;
    self.deleteBeaconButtonOutlet.userInteractionEnabled = NO;
    
    UISwipeGestureRecognizer *swipeToDeleteBeaconGestureRecognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteBeaconButton)];
    [swipeToDeleteBeaconGestureRecognizerRight setDelegate:self];
    [swipeToDeleteBeaconGestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.swipeView addGestureRecognizer:swipeToDeleteBeaconGestureRecognizerRight];
    
    UISwipeGestureRecognizer *swipeToDeleteBeaconGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteBeaconButton)];
    [swipeToDeleteBeaconGestureRecognizerLeft setDelegate:self];
    [swipeToDeleteBeaconGestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.swipeView addGestureRecognizer:swipeToDeleteBeaconGestureRecognizerLeft];
    
    [self.privateBeaconTextLabel setText:@"With privacy on, only people you approve can view your beacon"];
    [self.privateBeaconTextLabel setFont:[UIFont fontWithName:@"Quicksand" size:12]];
    [self.privateBeaconTextLabel setNumberOfLines:3];
    
    [self.privateBeaconButtonOutlet.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:12]];
    [self.requestsButtonOutlet.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:16]];
    [self.requestsButtonOutlet setImage:[UIImage imageNamed:@"btn_bvp_manageprivacy"] forState:UIControlStateNormal];
    [self.requestsButtonOutlet setBackgroundColor:[UIColor clearColor]];

    if (beaconIsPrivate) {
        
        [self.privateBeaconButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
        [self.requestsButtonOutlet setHidden:NO];
        [self.requestsButtonOutlet setUserInteractionEnabled:YES];

        
    }else {
        
        [self.privateBeaconButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];
        [self.requestsButtonOutlet setHidden:YES];
        [self.requestsButtonOutlet setUserInteractionEnabled:NO];
        
    }
    
    
}

- (void) revealDeleteBeaconButton {
    
    [self.slideToShowDeleteBeaconLabel setAlpha:0];
    
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         self.deleteBeaconButtonOutlet.alpha = 1;
                         
                     }completion:^(BOOL finished) {
                         
                         self.deleteBeaconButtonOutlet.userInteractionEnabled = YES;
                         
                     }];
    

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)shareThisBeaconButtonPressed:(id)sender {
    
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


- (IBAction)requestsButtonPressed:(id)sender {
    [MFSlidingView slideOut];
    PrivacyManagerViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"PrivacyManagerID"];
    [newViewController setBeaconID:beaconID];
    [[MFSideMenuManager sharedManager].navigationController pushViewController:newViewController animated:YES];
}

- (IBAction)privateBeaconButtonPressed:(id)sender {
    
    if (beaconIsPrivate) {
        
        beaconIsPrivate = NO;
        [self.privateBeaconButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];
        [self.requestsButtonOutlet setHidden:YES];
        [self.requestsButtonOutlet setUserInteractionEnabled:NO];

        
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", @"false", @"private", nil] apiMethod:@"beacon/update" httpMethod:@"POST"];
        [self.privateBeaconButtonOutlet setUserInteractionEnabled:NO];
        
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
         {

             NSLog(@"%@", response);
             if (response) {
                 [self.privateBeaconButtonOutlet setUserInteractionEnabled:YES];
                 
                 
                 if([beaconCreatorSettingsDelegate respondsToSelector:@selector(updateBeaconPrivacy)]){
                     
                     [beaconCreatorSettingsDelegate updateBeaconPrivacy];
                 }

             }
             
         }];

        
    }else if (!beaconIsPrivate){
        
        beaconIsPrivate = YES;
        [self.privateBeaconButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
        [self.requestsButtonOutlet setHidden:NO];
        [self.requestsButtonOutlet setUserInteractionEnabled:YES];
        
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", @"true", @"private", nil] apiMethod:@"beacon/update" httpMethod:@"POST"];
        [self.privateBeaconButtonOutlet setUserInteractionEnabled:NO];
        
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
         {
             NSLog(@"%@", response);
             if (response) {
                 [self.privateBeaconButtonOutlet setUserInteractionEnabled:YES];
                 
                 if([beaconCreatorSettingsDelegate respondsToSelector:@selector(updateBeaconPrivacy)]){
                     
                     [beaconCreatorSettingsDelegate updateBeaconPrivacy];
                 }
                 
             }
             
         }];

    }
    
}

- (IBAction)inviteFriendsButtonPressed:(id)sender
{
    [MFSlidingView slideOut];
    
    InviteFriendsViewController *inviteVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"inviteFriendsID"];
    [inviteVC setBeaconID:beaconID];
    [inviteVC setBeaconName:beaconName];
    [inviteVC setJustCreated:NO];
    //NSArray *controllers = [NSArray arrayWithObject:inviteVC];
    //[MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    //[MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    [[MFSideMenuManager sharedManager].navigationController pushViewController:inviteVC animated:YES];
}
- (IBAction)takeAPhotoButtonPressed:(id)sender {
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" message:@"You will be able to change the beacon profile picture soon. Sit tight!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
    
}
- (IBAction)mediaLibraryButtonPressed:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" message:@"You will be able to change the beacon profile picture soon. Sit tight!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
}
- (IBAction)beaconDescriptionButtonPressed:(id)sender {
    
    [MFSlidingView slideOut];
    
    DescriptionChangeView *descriptionChangeViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"DescriptionChangeView" owner:self options:nil]objectAtIndex:0];
    
    [descriptionChangeViewInstance setBeaconID:beaconID];
    [descriptionChangeViewInstance setBeaconDictionary:beaconDictionary];
    [descriptionChangeViewInstance setupDescriptionChangeView];
    [descriptionChangeViewInstance setBackgroundColor:[UIColor clearColor]];
    [descriptionChangeViewInstance.descriptionTextViewOutlet setDelegate:descriptionChangeViewInstance];
    
    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    UIViewController *myController = [self firstAvailableUIViewController];

    
    [MFSlidingView slideView:descriptionChangeViewInstance intoView:myController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
}
- (IBAction)deleteBeaconButtonPressed:(id)sender {
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"This beacon will be gone forever" delegate:self cancelButtonTitle:@"Yes, delete" otherButtonTitles:@"Whoops!", nil];
    av.tag = BEACON_DELETE_ALERT_VIEW_TAG;
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag != BEACON_DELETE_ALERT_VIEW_TAG) {
        return;
    }
    
    if (buttonIndex == 0) {
        
        NSLog(@"Deleting Beacon");
        [NSDictionary dictionaryWithObject:beaconID forKey:@"beacon"];
        
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", userTokenString, @"token", nil] apiMethod:@"beacon/delete" httpMethod:@"POST"];
        
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
         {
             [MFSlidingView slideOut];
             NSLog(@"%@", response);
             
             UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                 instantiateViewControllerWithIdentifier:@"mapViewID"];
             demoController.title = [NSString stringWithFormat:@"Discover"];
             
             NSArray *controllers = [NSArray arrayWithObject:demoController];
             RadiusAppDelegate *appDelegate = (RadiusAppDelegate *)[[UIApplication sharedApplication]delegate];
             SideMenuViewController *svc = appDelegate.sideMenuController;
             
             [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
             [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
             
             [svc.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES];
             [svc tableView:svc.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
             
             [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
             [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
             
         }];
    }else if (buttonIndex == 1){
        
        NSLog(@"Going back to beacon settings");
        
    }
    
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    
    mediaUI.delegate = delegate;
    [mediaUI.navigationBar setBackgroundImage:[UIImage imageNamed:@"pnl_navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}


@end
