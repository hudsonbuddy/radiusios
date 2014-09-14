//
//  LoginViewController.m
//  Radius
//
//  Created by Hud on 7/17/12.
//
//

#import "LoginViewController.h"
#import "MFSideMenu.h"
#import "RadiusAppDelegate.h"
#import "RadiusRequest.h"
#import "TwitterLoginViewController.h"
#import "RegisterViewController.h"
#import "NSString+URLEncoding.h"
#import "SideMenuViewController.h"
#import "Flurry.h"
#import "MapViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *lognButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@end

@implementation LoginViewController
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize loginMessageLabel;
@synthesize lognButton;
@synthesize registerButton;

static const CGFloat DIMVIEW_BLOCKING_TAG = 100;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self LoginIfValidToken];
    [self.navigationController setNavigationBarHidden:YES];
//    RadiusAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
//    SideMenuViewController *svc = appDelegate.sideMenuController;
//    [svc.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES];
//
//    [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setupSideMenuBarButtonItem];
    [self.navigationController setNavigationBarHidden:YES];
    [self setupTextLook];
//    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"iphone5_bkgd_login@2x.png"]];
    
    UIImage *img = [UIImage imageNamed:@"iphone5_bkgd_login@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    backgroundNotificationsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    backgroundNotificationsView.alpha = 1;
    
    [self.view addSubview:backgroundNotificationsView];
    [self.view sendSubviewToBack:backgroundNotificationsView];
    
	// Do any additional setup after loading the view.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    // Check if we already have a FB session open
//    FBSession *facebookSession = [[[FBSession alloc] init]];
//    [FBSession sessionOpenWithPermissions:nil
//                        completionHandler:^(FBSession *session,
//                                            FBSessionState status,
//                                            NSError *error) {
//                            // session might now be open.
//                        }];
//    if (facebookSession.isOpen)
//    {
//        // if we don't have a cached token, a call to open here would cause UX for login to
//        // occur; we don't want that to happen unless the user clicks the login button, and so
//        // we check here to make sure we have a token before calling open
//        if (facebookSession.state == FBSessionStateCreatedTokenLoaded)
//        {
//            // even though we had a cached token, we need to login to make the session usable
//            [facebookSession openWithCompletionHandler:^(FBSession *session,
//                                                            FBSessionState status,
//                                                            NSError *error)
//             {
//                 NSLog(@"fb session token is: %@", facebookSession.accessToken);
//            }];
//      }
//    }
//    
//   // David's sample code
//   NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"name, picture, email", @"fields", nil];
//   
//    FBRequest *fbr = [[FBRequest alloc] initWithSession:facebookSession graphPath:@"me" parameters:params HTTPMethod:@"GET"];
//    [fbr startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        NSLog(@"Result of /me call: %@",result);
//    }];
    
    
    //Initialize the single tap recognizer
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
    emailTextField.delegate = self;
    passwordTextField.delegate = self;    
    //Populate the text fields with user defaults if they exist
    NSString *emailFromDefault = [userDefaults objectForKey:@"email"];
    emailTextField.text = emailFromDefault;
    
    //Check if we already have a valid token
    //NSString *userToken = [userDefaults objectForKey:@"token"];
    
//    // Create the FB Login button
//    facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGFloat xFacebookLoginButtonOffset = self.view.center.x - (159/2);
//    CGFloat yFacebookLoginButtonOffset = self.view.bounds.size.height - (150);
//    facebookLoginButton.frame = CGRectMake(xFacebookLoginButtonOffset, yFacebookLoginButtonOffset ,159,29);
//    [facebookLoginButton addTarget:self
//                            action:@selector(FBLoginPressed)
//                  forControlEvents:UIControlEventTouchUpInside];
//    
//    [facebookLoginButton setImage:
//     [UIImage imageNamed:@"LoginWithFacebookNormal.png"]
//                         forState:UIControlStateNormal];
//    [facebookLoginButton sizeToFit];
//    [self.view addSubview:facebookLoginButton];
    [loginMessageLabel setHidden:YES];
    
}

-(void)LoginIfValidToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"token"])
    {
        NSString *token = [defaults objectForKey:@"token"];
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:token, @"token", nil] apiMethod:@"token_status"];
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
            if ([[response objectForKey:@"valid"] integerValue] == 1)
            {
                [RadiusRequest setToken:token];
//                [self transitionToStoryboardNamed:@"MainStoryboard" withIdentifier:@"mapViewID"];
                

            }
        }];
    }
}

-(void)setupTextLook
{
    [loginMessageLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:16.0]];
    self.emailTextField.font = [UIFont fontWithName:@"Quicksand" size:18.0];
    self.passwordTextField.font = [UIFont fontWithName:@"Quicksand" size:18.0];
    [lognButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:lognButton.titleLabel.font.pointSize]];
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:registerButton.titleLabel.font.pointSize]];
    [loginMessageLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:loginMessageLabel.font.pointSize]];
    loginMessageLabel.textColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/;
    [loginMessageLabel setBackgroundColor:[UIColor clearColor]];
    
    emailTextField.frame = CGRectMake(emailTextField.frame.origin.x, emailTextField.frame.origin.y, emailTextField.frame.size.width, 38);
    passwordTextField.frame = CGRectMake(passwordTextField.frame.origin.x, passwordTextField.frame.origin.y, passwordTextField.frame.size.width, 38);
    
    
    self.forgotPasswordButton.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:self.forgotPasswordButton.titleLabel.font.pointSize];
    
    self.lognButton.layer.cornerRadius = 10;
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

- (void)viewDidUnload {
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginMessageLabel:nil];
    [self setLognButton:nil];
    [self setRegisterButton:nil];
    registerButton = nil;
    lognButton = nil;
    [self setForgotPasswordButton:nil];
    [super viewDidUnload];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}


//- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
//{
//    NSLog(@"token extended");
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
//    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
//    [defaults synchronize];
//}

// Handle single taps such that they hide the keyboard
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}
// Handles actions upon pressing return in text fields
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == self.passwordTextField)
    {
        [self submitCredentialsButton:nil];
        [theTextField resignFirstResponder];
    }
    else if (theTextField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (void)requestTokenForEmail:(NSString *)email password:(NSString *)password
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password" ,nil] apiMethod:@"login" httpMethod:@"POST"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        [self loginCompletionMethodWithResponse:response error:error];
        
    }];
    
}


- (IBAction)submitCredentialsButton:(id)sender
{
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Attempted to Log In with Email and Password"];
#endif
    
    
    NSString *email = emailTextField.text;
    NSString *password = passwordTextField.text;
    //Check to make sure the user has filled out the login fields
    if (email.length == 0)
    {
        loginMessageLabel.text = @"Enter your email address!";
        [loginMessageLabel setHidden:NO];
    }
    else if (password.length == 0)
    {
        loginMessageLabel.text = @"Enter your password!";
        [loginMessageLabel setHidden:NO];
    }
    //If so, request a unique token for the user
    else
    {
        [self requestTokenForEmail:email password:password];
        
        [self showLoadingOverlay];
        
        [loginMessageLabel setHidden:YES];
//        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil] apiMethod:@"login" httpMethod:@"POST"];
//        [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
//            if (response)
//            {
//                
//            }
//        }];
    }
}

- (IBAction)FBLoginPressed:(id)sender
{
    //    RadiusAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //    [appDelegate openSessionCheckCache:NO];
    //    if (session)
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Attempted to Log In with Facebook"];
#endif
    
    
    [self showLoadingOverlay];
    
    NSString *facebookAppID = [[NSBundle mainBundle].infoDictionary objectForKey:@"FacebookAppID"];
    FBSession *s = [[FBSession alloc] initWithAppID:facebookAppID permissions:[NSArray arrayWithObjects:@"email",@"publish_actions",nil] defaultAudience:FBSessionDefaultAudienceFriends urlSchemeSuffix:nil tokenCacheStrategy:nil];
    
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
                  NSLog(@"my first name is: %@",my.first_name);
                  // Save the FB login token
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  [defaults setObject:session.accessToken forKey:@"fb_access_token"];
                  NSLog(@"fb token is: %@",session.accessToken);
                  // Log in to Radius with the FB token just generated from logging in
                  
                  RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:session.accessToken, @"access_token", nil] apiMethod:@"login/facebook" httpMethod:@"POST"];
                  [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
                      
                      [self loginCompletionMethodWithResponse:response error:error];

                  }];
                  
              }];
         }
     }];
    
    NSLog(@"started to open session");
}

- (IBAction)forgotPasswordPressed:(id)sender {
    
}



- (IBAction)TwitterLoginPressed
{
    TwitterLoginViewController *twitterController = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterLogin"];
    twitterController.title = @"Twitter Login";
    //[twitterController setCurrentBeacon:createdBeaconInstance];
    [self.navigationController pushViewController:twitterController animated:YES];
}

- (IBAction)registerButtonPressed:(id)sender
{
    RegisterViewController *registerController = [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
    [registerController setTitle:@"Register"];
//    RadiusAppDelegate *appDelegate = (RadiusAppDelegate *)[[UIApplication sharedApplication]delegate];
//    SideMenuViewController *svc = appDelegate.sideMenuController;
//    
//    [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
//    [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
//    
//    [svc.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES];
//    [svc tableView:svc.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self.navigationController pushViewController:registerController animated:YES];
}

- (void)transitionToStoryboardNamed:(NSString *) storyboard withIdentifier:(NSString *) identifier
{
    UIViewController *demoController = [[UIStoryboard storyboardWithName:storyboard bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:identifier];
    //demoController.title = [NSString stringWithFormat:@"Map"];
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (void) loginCompletionMethodWithResponse: (id)responseData error:(RadiusError *)error {
    
    [self dismissLoadingOverlay];
    
    //NSString *d = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"got to connection");
    id jsonObject = responseData;
    
    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
    NSLog(@"jsonDictionary - %@",jsonDictionary);
    //If we successfully get a token, save the user's data in NSUserDefaults
    
    //If the user logs in successfully, save token, expiration, and username, then transition to the map screen
    if (!error)
    {
        NSString *token = [jsonDictionary objectForKey:@"token"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:token forKey:@"token"];
        [userDefaults setObject:[jsonDictionary objectForKey:@"expiration"] forKey:@"expiration"];
        
        NSNumber *userID = [[jsonDictionary objectForKey:@"user"] objectForKey:@"id"];
        [userDefaults setObject:userID forKey:@"id"];
        [Flurry setUserID:[NSString stringWithFormat:@"%@",userID]];
        
        [userDefaults setObject:[[jsonDictionary objectForKey:@"user"] objectForKey:@"display_name"] forKey:@"display_name"];
        [userDefaults setObject:emailTextField.text forKey:@"email"];
        [userDefaults setObject:[[jsonDictionary objectForKey:@"user"] objectForKey:@"picture"] forKey:@"picture"];
//        [userDefaults setObject:@"YES" forKey:@"facebook_share"];
        [loginMessageLabel setHidden:YES];
        [RadiusRequest setToken:token];
        //        [self transitionToStoryboardNamed:@"MainStoryboard" withIdentifier:@"mapViewID"];
        RadiusAppDelegate *appDelegate = (RadiusAppDelegate *)[[UIApplication sharedApplication]delegate];
        SideMenuViewController *svc = appDelegate.sideMenuController;
        
        [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [svc.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [svc.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES];
        [svc tableView:svc.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        
        MapViewController *v = (MapViewController *)[MFSideMenuManager sharedManager].navigationController.topViewController;
        v.showSuggestions = YES;
        
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge)];
    }
    //If login wasn't successful, print the error msg
    else
    {
        if (error.type == RadiusErrorNotFbConnected)
        {
            //[self transitionToStoryboardNamed:@"MainStoryboard" withIdentifier:@"Register"];
            RegisterViewController *registerController = [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
            [self.navigationController pushViewController:registerController animated:YES];
        }
        else
        {
            loginMessageLabel.text = @"Login failed.  Check your credentials.";
            [loginMessageLabel setHidden:NO];
        }
    }
}

-(void)findNotifications
{
    // Do nothing
}


@end
