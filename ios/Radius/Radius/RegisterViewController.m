//
//  RegisterViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 8/3/12.
//
//

#import "RegisterViewController.h"
#import "RadiusAppDelegate.h"
#import "MFSideMenu.h"
#import "RadiusRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Scale.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "Flurry.h"

@interface RegisterViewController () {
    NSUInteger attempts;
}
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *profilePictureLabel;

@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@property (nonatomic) CGFloat animatedDistance;
@property (weak, nonatomic) IBOutlet UIButton *profilePictureButton;
@property (strong, nonatomic) NSString *profilePictureURL;
@property (strong, nonatomic) UIImage *profilePicture;
@property (strong, nonatomic) NSString *facebookAccessToken;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) NSDictionary *initialValues;

@property (weak, nonatomic) IBOutlet UIView *displayNameView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *profilePictureView;

@end

@implementation RegisterViewController
@synthesize passwordTextField, emailTextField, displayNameTextField;
@synthesize errorMessageLabel;
@synthesize animatedDistance;
@synthesize profilePictureButton;
@synthesize profilePictureURL = _profilePictureURL;
@synthesize displayNameLabel, emailAddressLabel, passwordLabel, profilePictureLabel;
@synthesize registerButton;
@synthesize initialValues;
@synthesize twitterLoginInfo;
@synthesize displayNameView, emailView, passwordView, profilePictureView;
@synthesize termsOfServiceButton, privacyPolicyButton;

RegistrationCompleteView *registrationCompleteView;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat DIMVIEW_BLOCKING_TAG = 100;


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
    [TestFlight passCheckpoint:@"Started to Register"];
#endif
    [Flurry logEvent:@"Registered" timed:YES];
    
    [super viewDidLoad];
	[self setupLookandFeel];
    [self setupSideMenuBarButtonItem];
    [self.navigationController setNavigationBarHidden:YES];
    self.title = @"Register!";
    [self populateFieldsWithInitialValues:initialValues counter:0 parent:nil];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture_new.png"]];
    //Initialize the single tap recognizer
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
    passwordTextField.delegate = self;
    emailTextField.delegate = self;
    displayNameTextField.delegate = self;
    [displayNameLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:displayNameLabel.font.pointSize]];
    
    [self setupFieldBackgrounds];
    
    [errorMessageLabel setHidden:YES];
    
    FBSession *currFBSession = FBSession.activeSession;
    // If we already have a FB session open, pre-populate user fields from FB data
    if (currFBSession.isOpen)
    {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"name, picture, email, username", @"fields", nil];
        FBRequest *graphRequest = [[FBRequest alloc] initWithSession:currFBSession graphPath:@"me" parameters:params HTTPMethod:@"GET"];
        [graphRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             NSLog(@"result is: %@", result);
             displayNameTextField.text = [result objectForKey:@"name"];
             emailTextField.text = [result objectForKey:@"email"];
             self.profilePictureURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=1600&height=1200",[result objectForKey:@"id"]];
             NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=300&height=300",[result objectForKey:@"id"]]];
             NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
             UIImage *profilePic = [UIImage imageWithData:imageData];
             [profilePictureButton setImage:profilePic forState:UIControlStateNormal];
             self.facebookAccessToken = currFBSession.accessToken;
             
         }];

    }
}

-(void)setInitialValues:(NSDictionary *)initial
{
    initialValues = initial;
}

-(void) setupFieldBackgrounds
{
    displayNameView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normhigh.png"]];
    emailView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]];
    passwordView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]];
    profilePictureView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_largelow.png"]];
}

-(void)populateFieldsWithInitialValues:(NSDictionary *)dict counter: (int*) i parent:(NSString *) parent
{
    for (NSString* key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        NSLog(@"%@ -> %@", parent, key);
        if ([value isKindOfClass:[NSMutableDictionary class]]) {
            i++;
            NSDictionary* newDict = (NSDictionary*)value;
            [self populateFieldsWithInitialValues:newDict counter:i parent:key];
            i--;
        } else {
            if ([key isEqualToString:@"name"]){
                displayNameTextField.text = value;
            }
            else if ([key isEqualToString:@"profile_image_url"]){
                self.profilePictureURL = value;
                NSURL *imageURL = [NSURL URLWithString:value];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *profilePic = [UIImage imageWithData:imageData];
                [profilePictureButton setImage:profilePic forState:UIControlStateNormal];
            }
        }
    }
    
}

-(void)setupLookandFeel
{
    [displayNameLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:displayNameLabel.font.pointSize]];
    [displayNameTextField setFont:[UIFont fontWithName:@"Quicksand" size:displayNameTextField.font.pointSize]];
    [emailAddressLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:emailAddressLabel.font.pointSize]];
    [emailTextField setFont:[UIFont fontWithName:@"Quicksand" size:emailTextField.font.pointSize]];
    [passwordLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:passwordLabel.font.pointSize]];
    [passwordTextField setFont:[UIFont fontWithName:@"Quicksand" size:passwordTextField.font.pointSize]];
    [profilePictureLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:profilePictureLabel.font.pointSize]];
    [errorMessageLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:errorMessageLabel.font.pointSize]];
    errorMessageLabel.textColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/;
    [errorMessageLabel setBackgroundColor:[UIColor clearColor]];
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:registerButton.titleLabel.font.pointSize]];
    //Make the profile picture button have rounded edges
    CALayer *layer = [profilePictureButton layer];
    profilePictureButton.contentMode = UIViewContentModeScaleAspectFill;
    profilePictureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10.0];
    [termsOfServiceButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:termsOfServiceButton.titleLabel.font.pointSize]];
    [privacyPolicyButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:privacyPolicyButton.titleLabel.font.pointSize]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPasswordTextField:nil];
    [self setEmailTextField:nil];
    [self setDisplayNameTextField:nil];
    [self setErrorMessageLabel:nil];
    [self setProfilePictureButton:nil];
    [self setDisplayNameLabel:nil];
    [self setDisplayNameLabel:nil];
    [self setEmailAddressLabel:nil];
    [self setPasswordLabel:nil];
    [self setProfilePictureLabel:nil];
    [self setRegisterButton:nil];
    [self setTermsOfServiceButton:nil];
    [self setPrivacyPolicyButton:nil];
    [super viewDidUnload];
}

//Handle single taps such that they hide the keyboard
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

// Code to move the view focus down with each text field
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

// Handles actions upon pressing return in text fields
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == self.passwordTextField)
    {
        [theTextField resignFirstResponder];
//        [self attemptToRegister];
    }
    else if (theTextField == self.displayNameTextField)
    {
        [self.emailTextField becomeFirstResponder];
    }
    else if (theTextField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (void)transitionToMap
{
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"mapViewID"];
    //demoController.title = [NSString stringWithFormat:@"Map"];
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (IBAction)RegisterPressed
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Attempted to Register"];
#endif
    attempts++;
    
    [self attemptToRegister];
}

- (void)attemptToRegister
{    
    
    [self showLoadingOverlay];
    
    
    // Try and create account
    NSString *password = passwordTextField.text;
    NSString *email = emailTextField.text;
    NSString *displayName = displayNameTextField.text;
    
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", displayName, @"display_name", nil];
    

    //If we have Twitter login info, append that
    if (twitterLoginInfo)
    {
        [paramsDictionary setObject:[twitterLoginInfo objectForKey:@"access_token"] forKey:@"twitter_access_token"];
        [paramsDictionary setObject:[twitterLoginInfo objectForKey:@"access_token_secret"] forKey:@"twitter_access_token_secret"];
    }
    
    //Same for facebook
    if (self.facebookAccessToken) {
        [paramsDictionary setObject:self.facebookAccessToken forKey:@"fb_access_token"];
    }
    
    RadiusRequest *radRequest;
    
    //If we have selected a picture, upload it as multipart data.  Else, submit with profile pic URL (if there is one) as normal POST request.
    if (self.profilePicture) {
        UIImage *resizedPic = [self.profilePicture scaleToSize:CGSizeMake(1200, 900)];
        NSData *profilePicData = UIImageJPEGRepresentation(resizedPic, 0.9);
        radRequest = [RadiusRequest requestWithParameters:paramsDictionary apiMethod:@"register" multipartData:profilePicData,@"image/jpeg",@"image.jpg",@"picture", nil];
    } else {
        if (self.profilePictureURL)
        {
            NSLog(@"profile picture url is: %@", self.profilePictureURL);
            [paramsDictionary setObject:self.profilePictureURL forKey:@"picture"];
        }
        radRequest = [RadiusRequest requestWithParameters:paramsDictionary apiMethod:@"register" httpMethod:@"POST"];
    }

    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        [self dismissLoadingOverlay];
        
        NSLog(@"response - %@",response);

        //If registration is successful, save user info in NSDefaults
        if (!error)
        {
#ifdef CONFIGURATION_TestFlight
            [TestFlight passCheckpoint:@"Successfully Registered"];
#endif
            
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [RadiusRequest setToken:[response objectForKey:@"token"]];
            [userDefaults setObject:[response objectForKey:@"token"] forKey:@"token"];
            [userDefaults setObject:[response objectForKey:@"expiration"] forKey:@"expiration"];
            [userDefaults setObject:[[response objectForKey:@"user"] objectForKey:@"username"] forKey:@"username"];
            
            NSNumber *userID = [[response objectForKey:@"user"] objectForKey:@"id"];
            [userDefaults setObject:userID forKey:@"id"];
            [userDefaults setObject:[[response objectForKey:@"user"] objectForKey:@"picture"] forKey:@"picture"];
            [errorMessageLabel setHidden:YES];
            
            [Flurry setUserID:[NSString stringWithFormat:@"%@",userID]];
            NSDictionary *eventParameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",userID],@"user",[NSNumber numberWithInteger:attempts],@"attempts", nil];
            [Flurry endTimedEvent:@"Registered" withParameters:eventParameters];
            
            //Present the Registration Complete popup
            registrationCompleteView = [[[NSBundle mainBundle]loadNibNamed:@"RegistrationCompleteView" owner:self options:nil]objectAtIndex:0];
            registrationCompleteView.frame = CGRectMake(registrationCompleteView.frame.origin.x, registrationCompleteView.frame.origin.y, registrationCompleteView.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:registrationCompleteView];
            
            
            UIView *dimViewForNavBar = [[UIView alloc] init];
            dimViewForNavBar.frame= CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
            dimViewForNavBar.backgroundColor = [UIColor blackColor];
            dimViewForNavBar.alpha = 0.6;
            [self.navigationController.navigationBar addSubview:dimViewForNavBar];
            
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge)];
        }
        //If login wasn't successful, print the error msg
        else
        {
#ifdef CONFIGURATION_TestFlight
            [TestFlight passCheckpoint:@"Encountered an Error During Registration"];
#endif
            
            errorMessageLabel.text = [self getErrorDisplayForErrorDict:error.errors];
            [errorMessageLabel setHidden:NO];
        }
        
    }];
}

//Only needs to return one error message at a time
-(NSString *) getErrorDisplayForErrorDict:(NSDictionary *)errorDict
{
    //NSMutableString *errorMsg;
    NSString *firstField = [[errorDict allKeys] objectAtIndex:0];
    NSString *errorCode = [errorDict objectForKey:firstField];
    if ([firstField isEqualToString:@"display_name"])
    {
        return @"Please enter a valid username";
    }
    else if ([firstField isEqualToString:@"email"])
    {
        if ([errorCode isEqualToString:@"6"]) return @"That email is already registered with Radius";
        if ([errorCode isEqualToString:@"7"]) return @"Please enter a valid email address";
    }
    else if ([firstField isEqualToString:@"password"])
    {
        return @"Password must be at least 6 characters";
    }
    else if ([firstField isEqualToString:@"image"])
    {
        return @"Please select a valid image";
    }
    return @"Some fields have errors";
}

- (IBAction)chooseProfilePicture:(id)sender {
    
    [self startMediaBrowserFromViewController: self
                                usingDelegate: self];
    
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
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Chose a Profile Picture during Registration"];
#endif
    
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

        self.profilePicture = imageToUse;
        
        [profilePictureButton setImage:imageToUse forState:UIControlStateNormal];
        [self dismissModalViewControllerAnimated:YES];
        // Do something with imageToUse
    }
    
    // Handle a movie picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"You tried to pick a movie, try picking an image" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        // Do something with the picked movie available at moviePath
    }
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    //    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backButtonPressed:(id)sender
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Abandoned Registration"];
#endif
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)termsOfServicePressed
{
    UITextView *termsView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 280, 300)];
    [termsView setEditable:NO];
    [termsView setText:termsText];
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:termsView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Terms of Service" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
}
- (IBAction)privacyPolicyPressed
{
    UITextView *termsView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 280, 300)];
    [termsView setEditable:NO];
    [termsView setText:privacyText];
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:termsView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Privacy Policy" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
}

NSString *termsText = @"Radius Location Technologies, Inc. Terms and Conditions of Use.  1. Terms - By accessing any offering of Radius Location Technologies, Inc, you are agreeing to be bound by these Terms and Conditions of Use, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing this product. The materials contained in this web site are protected by applicable copyright and trade mark law.  2. Use License - Permission is granted to temporarily download one copy of the materials (information or software) on Radius Location Technologies, Inc's web site for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not: modify or copy the materials; use the materials for any commercial purpose, or for any public display (commercial or non-commercial); attempt to decompile or reverse engineer any software contained on Radius Location Technologies, Inc's services; remove any copyright or other proprietary notations from the materials; or transfer the materials to another person or 'mirror' the materials on any other server.  This license shall automatically terminate if you violate any of these restrictions and may be terminated by Radius Location Technologies, Inc at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic or printed format.  3. Disclaimer - The materials on Radius Location Technologies, Inc’s services are provided 'as is'. Radius Location Technologies, Inc makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties, including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights. Further, Radius Location Technologies, Inc does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its services or otherwise relating to such materials or on any services linked to this service.  4. Limitations - In no event shall Radius Location Technologies, Inc or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption,) arising out of the use or inability to use the materials on Radius Location Technologies, Inc's services, even if Radius Location Technologies, Inc or a Radius Location Technologies, Inc authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.  5. Revisions and Errata.  The materials appearing on Radius Location Technologies, Inc's services could include technical, typographical, or photographic errors. Radius Location Technologies, Inc does not warrant that any of the materials on its web site are accurate, complete, or current. Radius Location Technologies, Inc may make changes to the materials contained on its service at any time without notice. Radius Location Technologies, Inc does not, however, make any commitment to update the materials.  6. Content and Links - Radius Location Technologies, Inc has not reviewed all of the content linked to its services and is not responsible for the contents of any such linked content. The inclusion of content does not imply endorsement by Radius Location Technologies, Inc of the content. Use of any such linked web site or content is at the user's own risk.  7. Site Terms of Use Modifications - Radius Location Technologies, Inc may revise these terms of use for its services at any time without notice. By using this web site you are agreeing to be bound by the then current version of these Terms and Conditions of Use.  8. Governing Law - Any claim relating to Radius Location Technologies, Inc's web site shall be governed by the laws of the State of Delaware without regard to its conflict of law provisions.";

NSString *privacyText = @"Privacy Policy:  Your privacy is very important to us. Accordingly, we have developed this Policy in order for you to understand how we collect, use, communicate and disclose and make use of personal information. The following outlines our privacy policy.  Before or at the time of collecting personal information, we will identify the purposes for which information is being collected.  We will collect and use of personal information solely with the objective of fulfilling those purposes specified by us and for other compatible purposes, unless we obtain the consent of the individual concerned or as required by law.  We will only retain personal information as long as necessary for the fulfillment of those purposes.  We will collect personal information by lawful and fair means and, where appropriate, with the knowledge or consent of the individual concerned.  Personal data should be relevant to the purposes for which it is to be used, and, to the extent necessary for those purposes, should be accurate, complete, and up-to-date.  We will make best efforts to protect personal information by reasonable security safeguards against loss or theft, as well as unauthorized access, disclosure, copying, use or modification.  We will strive to make readily available to customers information about our policies and practices relating to the management of personal information.  We are committed to conducting our business in accordance with these principles in order to ensure that the confidentiality of personal information is protected and maintained. ";
@end
