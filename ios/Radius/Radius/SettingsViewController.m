//
//  SettingsViewController.m
//  Radius
//
//  Created by Hud on 7/23/12.
//
//

#import "SettingsViewController.h"
#import "RadiusAppDelegate.h"
#import "RadiusRequest.h"
#import "LoginViewController.h"
#import "MFSideMenu.h"
#import "TourViewController.h"
#import "ChangeInfoViewController.h"
#import "MFSlidingView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Scale.h"
#import "PopupView.h"
#import "Flurry.h"
#import "UIViewController+MFSideMenu.h"

@interface SettingsViewController () <ChangeInfoDelegate> {
    NSDictionary *meInfo;
}

@end

@implementation SettingsViewController
@synthesize accountSettingsLabel;
@synthesize profilePictureLabel, profilePictureImageView;
@synthesize displayNameHeaderLabel, displayNameLabel;
@synthesize passwordHeaderLabel, passwordLabel;
@synthesize emailHeaderLabel, emailLabel;

@synthesize notificationSettingsLabel;
@synthesize pushNotificationsView, pushNotificationsLabel, pushNotificationsSwitch;
@synthesize contentOnFollowedBeaconView, contentOnFollowedBeaconLabel;
@synthesize threadView, threadLabel;
@synthesize commentOnYourPostView, commentOnYourPostLabel;

@synthesize privacySettingsLabel;
@synthesize keepLoggedInView, keepLoggedInLabel;
@synthesize othersSeeRecentActivityView, othersSeeRecentActivityLabel;
@synthesize othersSeeFollowedBeaconsView, othersSeeFollowedBeaconsLabel;
@synthesize othersSeeHomeBaseView, othersSeeHomeBaseLabel;
@synthesize theSettingsDelegate;
@synthesize scrollViewOutlet, shareBeaconFollowsButtonOutlet, shareBeaconFollowsLabelOutlet, takeATourButtonOutlet;

@synthesize logOutButton;
RadiusProgressView *uploadProgressView;
static const CGFloat ACTIVITY_INDICATOR_TAG = 100;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Opened Settings"];
#endif
    [Flurry logEvent:@"User_Settings_Viewed"];
    
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"SettingsScrollView" owner:self options:nil];
    
    [self setupSideMenuBarButtonItem];
    [self setupLookAndFeel];
    [self setSwitchPositions];
    [self showLoadingOverlay];
    [self loadUserInfo];
    [self setupScrollView];


}

-(void) viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setSwitchPositions
{
    
}

-(void)loadUserInfo
{
    
    RadiusRequest *meInfoRequest = [RadiusRequest requestWithAPIMethod:@"me"];
    [meInfoRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        NSURL *imageURL = [NSURL URLWithString:[response objectForKey:@"picture"]];
        
        AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,profilePictureImageView.frame.size.width,profilePictureImageView.frame.size.height) imageURL:imageURL cache:nil];
        aiv.layer.cornerRadius = 5;
        [profilePictureImageView addSubview:aiv];
        profilePictureImageView.layer.cornerRadius = 5;
        
        [displayNameLabel setText:[response objectForKey:@"display_name"]];
        [emailLabel setText:[response objectForKey:@"email"]];
        
        if ([[response objectForKey:@"fb_uid"] integerValue] == 0)
        {
            [self.connectFacebookButton setBackgroundImage:[UIImage imageNamed:@"btn_set_connectfacebook.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.connectFacebookButton setBackgroundImage:[UIImage imageNamed:@"btn_set_facebookdone.png"] forState:UIControlStateNormal];
            [self.connectFacebookButton setEnabled:NO];
            
            [self moveTourAndLogOutButtons];

        }
        
        [self dismissLoadingOverlay];
    }];
}


-(void) setupLookAndFeel
{
    //Account Settings panel
    [accountSettingsLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:accountSettingsLabel.font.pointSize]];
    [profilePictureLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:profilePictureLabel.font.pointSize]];
    [displayNameHeaderLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:displayNameHeaderLabel.font.pointSize]];
    [displayNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:displayNameLabel.font.pointSize]];
    [passwordHeaderLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:passwordHeaderLabel.font.pointSize]];
    [passwordLabel setFont:[UIFont fontWithName:@"Quicksand" size:passwordLabel.font.pointSize]];
    [emailHeaderLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:emailHeaderLabel.font.pointSize]];
    [emailLabel setFont:[UIFont fontWithName:@"Quicksand" size:emailLabel.font.pointSize]];
    
    //Notification Settings panel
    [notificationSettingsLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:notificationSettingsLabel.font.pointSize]];
    [pushNotificationsView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normhigh.png"]]];
    [contentOnFollowedBeaconView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]]];
    [threadView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]]];
    [commentOnYourPostView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normlow.png"]]];
    [pushNotificationsLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:notificationSettingsLabel.font.pointSize]];
    [contentOnFollowedBeaconLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:contentOnFollowedBeaconLabel.font.pointSize]];
    [threadLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:threadLabel.font.pointSize]];
    [commentOnYourPostLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:commentOnYourPostLabel.font.pointSize]];
    
    //Privacy Settings panel
    [privacySettingsLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:privacySettingsLabel.font.pointSize]];
    [keepLoggedInView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normhigh.png"]]];
    [othersSeeRecentActivityView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]]];
    [othersSeeFollowedBeaconsView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]]];
    [othersSeeHomeBaseView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normlow.png"]]];
    [keepLoggedInLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:keepLoggedInLabel.font.pointSize]];
    [othersSeeRecentActivityLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:othersSeeRecentActivityLabel.font.pointSize]];
    [othersSeeFollowedBeaconsLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:othersSeeFollowedBeaconsLabel.font.pointSize]];
    [othersSeeHomeBaseLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:othersSeeHomeBaseLabel.font.pointSize]];
    
    [logOutButton.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:logOutButton.titleLabel.font.pointSize]];
}

- (IBAction)connectFacebookPressed:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //If the user flips the switch to ON, prompt to connect a FB account
    if (1 == 1)//facebookConnectedSwitch.on = YES)
    {
        FBSession *s = [[FBSession alloc] initWithAppID:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"] permissions:[NSArray arrayWithObjects:@"email",@"publish_actions",nil] defaultAudience:FBSessionDefaultAudienceFriends urlSchemeSuffix:nil tokenCacheStrategy:nil];
        
        [FBSession setActiveSession:s];
        
        [s openWithCompletionHandler:^(FBSession *session,
                                       FBSessionState status,
                                       NSError *error)
         {
             
             // session might now be open.
             if (session.isOpen)
             {
                 NSLog(@"session is open");
                 FBRequest *me = [FBRequest requestForMe];
                 [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                   NSDictionary<FBGraphUser> *my,
                                                   NSError *error)
                  {
                      // Save the FB login token
                      [defaults setObject:session.accessToken forKey:@"fb_access_token"];
                      
                      //Now tie that FB Access token to the Radius account
                      RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"token"], @"token", session.accessToken, @"fb_access_token", nil] apiMethod:@"connect_facebook" httpMethod:@"POST"];
                      [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
                          
                          if(error) {
                              NSString *errorMessage = @"Something went wrong.";
                              if(error.type == RadiusErrorFbAlreadyConnected) {
                                  errorMessage = @"It looks like you already have a Radius account connected to your Facebook account.";
                              }
                              
                              PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
                              [popupAlert setupWithDescriptionText:errorMessage andButtonText:@"OK"];
                              SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                              void (^cancelOrDoneBlock)() = ^{
                                  // we must manually slide out the view out if we specify this block
                                  [MFSlidingView slideOut];
                              };
                              [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                       
                          }
                          
                      }];
                  }];
             }
         }];
    }
    else
    {
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"token"], @"token", nil] apiMethod:@"disconnect_facebook" httpMethod:@"POST"];
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        }];
    }
    
}


- (IBAction)logOutPressed
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Logged Out"];
#endif
    [Flurry logEvent:@"Logged_Out"];
    
    //Send log out request to API
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:nil apiMethod:@"logout" httpMethod:@"POST"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         // Remove the Radius stored data
         [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
         [RadiusUserData resetRadiusUserData];
         [RadiusRequest setToken:nil];
         [UIViewController clearNotifications];
         
         // Close FB Session
         [[FBSession activeSession] closeAndClearTokenInformation];
         
         RadiusAppDelegate *appDelegate = (RadiusAppDelegate *)
         [[UIApplication sharedApplication] delegate];
         if ([appDelegate.session isOpen])
         {
             [appDelegate closeSession];
         }
         
         // Unregister Push Notifications
         [[UIApplication sharedApplication] unregisterForRemoteNotifications];
         [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
         
         LoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewID"];
         [self.navigationController pushViewController:loginController animated:YES];
     }];
}

- (IBAction)tourButtonPressed:(id)sender
{
    TourViewController *tourController = [self.storyboard instantiateViewControllerWithIdentifier:@"TourViewID"];
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:tourController animated:YES];
}

#pragma mark Profile Picture Handle
- (IBAction)profilePictureButtonPressed:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Change your picture?" delegate:self
                                  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  @"Upload From Media Library", @"Take a Picture Now", @"Remove Profile Picture",
                                  nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Take a Picture Now"]) {
        
        [self startCameraControllerFromViewController:self usingDelegate:self];
        
        
    }else if ([buttonTitle isEqualToString:@"Upload From Media Library"]){
        
        [self startMediaBrowserFromViewController: self
                                    usingDelegate: self];
        
    }else if ([buttonTitle isEqualToString:@"Remove Profile Picture"]){
        
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Hold on!" message:@"We haven't implemented this yet, check back for updates, it'll be soon!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [av show];
        
        [self removeProfilePictureWithRequest];
        
    }else{
        
        NSLog(@"Nothing picked, error");
        
    }
    
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                            UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    
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


- (void) uploadImage:(UIImage *)imageToUse {
    
    if(self.modalViewController) {
        [self performSelector:@selector(uploadImage:) withObject:imageToUse afterDelay:0.1f];
        return;
    }
    
    uploadProgressView = [[[NSBundle mainBundle]loadNibNamed:@"RadiusProgressView" owner:self options:nil]objectAtIndex:0];
    uploadProgressView.description.text = @"Uploading Image";
    uploadProgressView.progressView.layer.cornerRadius = 2;
    [self.view addSubview:uploadProgressView];
    
    UIImage *resizedImage = [imageToUse scaleToSize:CGSizeMake(1200, 900)];
    
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.9f);
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:nil apiMethod:@"me/update" multipartData:imageData,@"image/jpeg",@"image.jpg",@"picture",nil];
    
    r.dataDelegate = self;
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        [uploadProgressView removeFromSuperview];
        
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"Upload complete!" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        return;
        
        [self loadUserInfo];
        
    }];
    
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        
        //        UIAlertView *picked = [[UIAlertView alloc] initWithTitle:@"Picked" message:@"Susan Coffey is awesome" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        //
        //        [picked show];
        
            
        [self uploadImage:imageToUse];
        for (int i = 0; i < [[profilePictureImageView subviews] count]; i++) {
            
            [[[profilePictureImageView subviews]objectAtIndex:i]removeFromSuperview];

        }
        [profilePictureImageView setImage:imageToUse];
        profilePictureImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if ([theSettingsDelegate respondsToSelector:@selector(changeProfilePictureToSelectedImage:)]) {
            [theSettingsDelegate changeProfilePictureToSelectedImage:imageToUse];
        }
        
        // Do something with imageToUse
    }
    
    // Handle a movie picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"You tried picking a movie, try picking an image." andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        // Do something with the picked movie available at moviePath
    }
    
    //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setUploadProgress:(NSNumber *)progress {
    float p = [progress floatValue];
    
    [uploadProgressView.progressView setProgress:p animated:YES];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    float progress = totalBytesWritten/ (float)totalBytesExpectedToWrite;
    
    [self performSelectorOnMainThread:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    //    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)displayNameButtonPressed:(id)sender {
    ChangeInfoViewController *changeInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"changeInfoViewID"];
    changeInfoVC.fieldToChange = @"display_name";
    changeInfoVC.changeInfoDelegateProperty = self;
    [self.navigationController pushViewController:changeInfoVC animated:YES];
}
- (IBAction)passwordButtonPressed:(id)sender {
    ChangeInfoViewController *changeInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"changeInfoViewID"];
    changeInfoVC.fieldToChange = @"password";
    changeInfoVC.changeInfoDelegateProperty = self;

    [self.navigationController pushViewController:changeInfoVC animated:YES];
}
- (IBAction)emailButtonPressed:(id)sender {
    ChangeInfoViewController *changeInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"changeInfoViewID"];
    changeInfoVC.fieldToChange = @"email";
    changeInfoVC.changeInfoDelegateProperty = self;

    [self.navigationController pushViewController:changeInfoVC animated:YES];
}

- (void) changeInfoBasedOnString:(NSString *)changedString withFieldToChange:(NSString *)fieldToChangeArgument {
    
    if ([fieldToChangeArgument isEqualToString:@"display_name"]) {
        
        displayNameLabel.text = changedString;
    }else if ([fieldToChangeArgument isEqualToString:@"email"]) {
        
        emailLabel.text = changedString;

        
    }
}

-(void) removeProfilePictureWithRequest {
    
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"remove",@"picture" , nil] apiMethod:@"me/update" httpMethod:@"POST"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        [self loadUserInfo];
        
        NSURL *myImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [response objectForKey:@"picture_thumb"]]];
        
        NSData *imageData = [NSData dataWithContentsOfURL:myImageURL];
        
        UIImage *myImageToUse = [UIImage imageWithData:imageData];
        
        if ([theSettingsDelegate respondsToSelector:@selector(changeProfilePictureToSelectedImage:)]) {
            [theSettingsDelegate changeProfilePictureToSelectedImage:myImageToUse];
        }
        
    }];
    

    
    
}

-(void) setupScrollView {
    
    [self.scrollViewOutlet setContentSize:CGSizeMake(self.view.frame.size.width, 568)];

    [self.scrollViewOutlet setUserInteractionEnabled:YES];
    [self.scrollViewOutlet setScrollEnabled:YES];
    
    
}

-(void) setupShareBeaconFollowViews{
    
    self.shareBeaconFollowsButtonOutlet.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:14];
    self.shareBeaconFollowsButtonOutlet.titleLabel.textColor = [UIColor blackColor];
    self.shareBeaconFollowsButtonOutlet.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.shareBeaconFollowsButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
    self.shareBeaconFollowsButtonOutlet.alpha = .7;
    [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:NO];
    
    UIActivityIndicatorView *myAIV= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [self.shareBeaconFollowsButtonOutlet addSubview:myAIV];
    myAIV.color = [UIColor blackColor];
    myAIV.tag = ACTIVITY_INDICATOR_TAG;
    [myAIV startAnimating];


    self.shareBeaconFollowsLabelOutlet.font = [UIFont fontWithName:@"Quicksand" size:12];
    self.shareBeaconFollowsLabelOutlet.numberOfLines = 2;
    self.shareBeaconFollowsLabelOutlet.textAlignment = NSTextAlignmentRight;
    
}

-(void) setupShareCreateViews{
    
    
    self.shareCreateButtonOutlet.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:14];
    self.shareCreateButtonOutlet.titleLabel.textColor = [UIColor blackColor];
    self.shareCreateButtonOutlet.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.shareCreateButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
    self.shareCreateButtonOutlet.alpha = .7;
    [self.shareCreateButtonOutlet setUserInteractionEnabled:NO];
    
    UIActivityIndicatorView *myAIV= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    [self.shareCreateButtonOutlet addSubview:myAIV];
    myAIV.color = [UIColor blackColor];
    myAIV.tag = ACTIVITY_INDICATOR_TAG;
    [myAIV startAnimating];
    
    
    self.shareCreateLabelOutlet.font = [UIFont fontWithName:@"Quicksand" size:12];
    self.shareCreateLabelOutlet.numberOfLines = 2;
    self.shareCreateLabelOutlet.textAlignment = NSTextAlignmentRight;
    
    
}

- (IBAction)shareBeaconFollowsButtonPressed:(id)sender {
    
    if ([self.shareBeaconFollowsButtonOutlet.titleLabel.text isEqualToString:@"ON"]) {
        
        [self.shareBeaconFollowsButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];
        
        [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:NO];
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"false", @"follow_actions", nil] apiMethod:@"me/settings/fb" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
                [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:YES];
                
            }
            
        }];
        
        

    }else if ([self.shareBeaconFollowsButtonOutlet.titleLabel.text isEqualToString:@"OFF"]){
        
        [self.shareBeaconFollowsButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
        
        [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:NO];
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"follow_actions", nil] apiMethod:@"me/settings/fb" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
                [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:YES];
                
            }
            
        }];

    }
    
}

- (IBAction)shareCreateButtonPressed:(id)sender {
    
    if ([self.shareCreateButtonOutlet.titleLabel.text isEqualToString:@"ON"]) {
        
        [self.shareCreateButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];
        
        [self.shareCreateButtonOutlet setUserInteractionEnabled:NO];
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"false", @"create_actions", nil] apiMethod:@"me/settings/fb" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
                [self.shareCreateButtonOutlet setUserInteractionEnabled:YES];
                
            }
            
        }];
        
        
        
    }else if ([self.shareCreateButtonOutlet.titleLabel.text isEqualToString:@"OFF"]){
        
        [self.shareCreateButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
        
        [self.shareCreateButtonOutlet setUserInteractionEnabled:NO];
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"create_actions", nil] apiMethod:@"me/settings/fb" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
                [self.shareCreateButtonOutlet setUserInteractionEnabled:YES];
                
            }
            
        }];
        
    }
}

-(void) findUserFacebookSettings {
    
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] apiMethod:@"me/settings/fb" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if (response) {
            
            if ([[response objectForKey:@"follow_actions"]integerValue] == 1) {
                [self.shareBeaconFollowsButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
                [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:YES];
                [[self.shareBeaconFollowsButtonOutlet viewWithTag:ACTIVITY_INDICATOR_TAG]removeFromSuperview];
                self.shareBeaconFollowsButtonOutlet.alpha = 1;



            }else if ([[response objectForKey:@"follow_actions"]integerValue] == 0){
                [self.shareBeaconFollowsButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];
                [self.shareBeaconFollowsButtonOutlet setUserInteractionEnabled:YES];
                [[self.shareBeaconFollowsButtonOutlet viewWithTag:ACTIVITY_INDICATOR_TAG]removeFromSuperview];
                self.shareBeaconFollowsButtonOutlet.alpha = 1;


            }
            
            if ([[response objectForKey:@"create_actions"]integerValue] == 1) {
                [self.shareCreateButtonOutlet setTitle:@"ON" forState:UIControlStateNormal];
                [self.shareCreateButtonOutlet setUserInteractionEnabled:YES];
                [[self.shareCreateButtonOutlet viewWithTag:ACTIVITY_INDICATOR_TAG]removeFromSuperview];
                self.shareCreateButtonOutlet.alpha = 1;
                
                
                
            }else if ([[response objectForKey:@"create_actions"]integerValue] == 0){
                [self.shareCreateButtonOutlet setTitle:@"OFF" forState:UIControlStateNormal];
                [self.shareCreateButtonOutlet setUserInteractionEnabled:YES];
                [[self.shareCreateButtonOutlet viewWithTag:ACTIVITY_INDICATOR_TAG]removeFromSuperview];
                self.shareCreateButtonOutlet.alpha = 1;
                
                
            }
            
            
        }
        
    }];
    
    
    
    
}

-(void) moveTourAndLogOutButtons{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         
                         [self.logOutButton setFrame:CGRectMake(self.logOutButton.frame.origin.x, self.logOutButton.frame.origin.y + 100, self.logOutButton.frame.size.width, self.logOutButton.frame.size.height)];
                         
                        [self.takeATourButtonOutlet setFrame:CGRectMake(self.takeATourButtonOutlet.frame.origin.x, self.takeATourButtonOutlet.frame.origin.y + 100, self.takeATourButtonOutlet.frame.size.width, self.takeATourButtonOutlet.frame.size.height)];

                         
                     }completion:^(BOOL finished) {
                         
                         [self.shareBeaconFollowsButtonOutlet setHidden:NO];
                         [self.shareBeaconFollowsLabelOutlet setHidden:NO];
                         [self.shareCreateButtonOutlet setHidden:NO];
                         [self.shareCreateLabelOutlet setHidden:NO];
                         [self setupShareBeaconFollowViews];
                         [self setupShareCreateViews];
                         [self findUserFacebookSettings];
                         
                         
                     }];
    
    
    

    
    
}

- (void)viewDidUnload {
    [self setLogOutButton:nil];
    [self setLogOutButton:nil];
    [self setProfilePictureImageView:nil];
    [self setProfilePictureLabel:nil];
    [self setDisplayNameLabel:nil];
    [self setDisplayNameHeaderLabel:nil];
    [self setDisplayNameLabel:nil];
    [self setPasswordHeaderLabel:nil];
    [self setPasswordLabel:nil];
    [self setEmailHeaderLabel:nil];
    [self setEmailLabel:nil];
    [self setAccountSettingsLabel:nil];
    [self setNotificationSettingsLabel:nil];
    [self setPrivacySettingsLabel:nil];
    [self setPushNotificationsView:nil];
    [self setPushNotificationsLabel:nil];
    [self setPushNotificationsSwitch:nil];
    [self setContentOnFollowedBeaconView:nil];
    [self setContentOnFollowedBeaconLabel:nil];
    [self setCommentOnYourPostView:nil];
    [self setCommentOnYourPostLabel:nil];
    [self setThreadView:nil];
    [self setThreadLabel:nil];
    [self setKeepLoggedInLabel:nil];
    [self setKeepLoggedInView:nil];
    [self setOthersSeeRecentActivityLabel:nil];
    [self setOthersSeeRecentActivityView:nil];
    [self setOthersSeeFollowedBeaconsLabel:nil];
    [self setOthersSeeFollowedBeaconsView:nil];
    [self setOthersSeeHomeBaseView:nil];
    [self setOthersSeeHomeBaseLabel:nil];
    profilePictureImageView = nil;
    [self setConnectFacebookButton:nil];
    [self setScrollViewOutlet:nil];
    [self setShareBeaconFollowsLabelOutlet:nil];
    [self setShareBeaconFollowsButtonOutlet:nil];
    [self setTakeATourButtonOutlet:nil];
    [self setShareCreateButtonOutlet:nil];
    [self setShareCreateButtonOutlet:nil];
    [super viewDidUnload];
}


@end
