//
//  RadiusAppDelegate.m
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RadiusAppDelegate.h"
#import "MFSideMenuManager.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "NotificationsWindow.h"
#import "PopupView.h"
#import "NSData+Conversion.h"
#import "UIViewController+MFSideMenu.h"
#import "Flurry.h"

@interface RadiusAppDelegate() {
    NSDate *lastBecameActive;
}

@end

@implementation RadiusAppDelegate

@synthesize window = _window;
@synthesize sideMenuController;
@synthesize session = _session;

NSString *const FBSessionStateChangedNotification = @"FBSessionStateChangedNotification";

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    lastBecameActive = [NSDate date];
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TestFlightTeamToken"]];
#endif

    [Flurry startSession:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlurryAPIKey"]];
    
    [self setNavBarAppearance];
    
    self.sideMenuController = [[SideMenuViewController alloc] init];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    [self.window makeKeyAndVisible];
    //SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
    
    [MFSideMenuManager configureWithNavigationController:navigationController sideMenuController:self.sideMenuController];
    
    
    [RadiusRequest setRequestDelegate:self];

    // Override point for customization after application launch.
    return YES;

}
//Customizes UINavigationBar appearance for all nav bars
-(void) setNavBarAppearance
{


    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor clearColor],
      UITextAttributeTextColor,
      [UIColor whiteColor],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"QuicksandBold-Regular" size:24.0],
      UITextAttributeFont,
      nil]];
    
}

-(void)hideNavBarMinusButton
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor clearColor],
      UITextAttributeTextColor,
      [UIColor whiteColor],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"QuicksandBold-Regular" size:6.0],
      UITextAttributeFont,
      nil]];
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // this means the user switched back to this app without completing
    // a login in Safari/Facebook App
    if (self.session.state == FBSessionStateCreatedOpening) {
        [self.session close]; // so we close our session and start over
    }
    
    [[MFSideMenuManager sharedManager].navigationController.topViewController findNotifications];
    
//    RadiusViewController *currentViewController = (RadiusViewController *)[MFSideMenuManager sharedManager].navigationController.topViewController;
//    [currentViewController refresh];
    
    lastBecameActive = [NSDate date];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (FBSession *)createNewSession
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_photos",
                            nil];
    self.session = [[FBSession alloc] initWithPermissions:permissions];
    return self.session;
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [session closeAndClearTokenInformation];
            self.session = nil;
            [self createNewSession];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) openSessionCheckCache:(BOOL)check {
    // Create a new session object
    if (!self.session.isOpen) {
        [self createNewSession];
    }
    // Open the session in two scenarios:
    // - When we are not loading from the cache, e.g. when a login
    //   button is clicked.
    // - When we are checking cache and have an available token,
    //   e.g. when we need to show a logged vs. logged out display.
    if (!check ||
        (self.session.state == FBSessionStateCreatedTokenLoaded)) {
        [self.session openWithCompletionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{    
    return [FBSession.activeSession handleOpenURL:url];
}

- (void) closeSession {
    [self.session closeAndClearTokenInformation];
}

-(void)radiusRequestDidDetectBadConnection:(RadiusRequest *)request errorCode:(NSInteger)urlError
{
    // if less than timeout interval since application became active and connection timed out, ignore
    if(([[NSDate date] timeIntervalSinceDate:lastBecameActive] < request.underlyingRequest.timeoutInterval)
       && (urlError == NSURLErrorTimedOut)) {
        return;
    }
    
    [(RadiusViewController *)[MFSideMenuManager sharedManager].navigationController.topViewController showBadConnectionWarning];
}

-(void)radiusRequestDidDetectRecoveredConnection:(RadiusRequest *)request
{
     [(RadiusViewController *)[MFSideMenuManager sharedManager].navigationController.topViewController dismissBadConnectionWarning];
    
//    RadiusViewController *currentViewController = (RadiusViewController *)[MFSideMenuManager sharedManager].navigationController.topViewController;
//    [currentViewController refreshView];
}

-(void)radiusRequestDidFailWithBadToken:(RadiusRequest *)request
{
    
    // if session was already closed, do nothing
    if(![RadiusRequest token]) {
        return;
    }
    
    // clear session (this should probably be centralized somewhere.  right now, duplicated here and in SettingsViewController)
    
    // Remove the Radius stored data
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [RadiusUserData resetRadiusUserData];
    [RadiusRequest setToken:nil];
    [UIViewController clearNotifications];
    
    // Close FB Session
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    if ([self.session isOpen])
    {
        [self closeSession];
    }
    
    // Unregister Push Notifications and set badge count to 0
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [(RadiusViewController *)[MFSideMenuManager sharedManager].navigationController.topViewController performOnAppear:^{
        UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        UIViewController *loginController = [st instantiateViewControllerWithIdentifier:@"loginViewID"];
        
        [[MFSideMenuManager sharedManager].navigationController setMenuState:MFSideMenuStateHidden];
        [[MFSideMenuManager sharedManager].navigationController pushViewController:loginController animated:NO];
        
        
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"We had to log you out for some reason.  Log back in to keep enjoying Radius!" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:loginController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];

    }];
    
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if([RadiusRequest token]) {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[deviceToken hexadecimalString] forKey:@"device_token"];
        RadiusRequest *deviceRegisterRequest = [RadiusRequest requestWithParameters:params apiMethod:@"device/register/ios" httpMethod:@"POST"];
        [deviceRegisterRequest start];
    }
    
    NSLog(@"enabled notification types: %d",[application enabledRemoteNotificationTypes]);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // always refresh notifications
    [[MFSideMenuManager sharedManager].navigationController.topViewController findNotifications];
    
    if(application.applicationState != UIApplicationStateActive) {
        // if app was brought to foreground, open the notifications panel
        [[MFSideMenuManager sharedManager].navigationController.topViewController drawNotificationsTable];
    }
    
}

-(void)setupTitleTicker
{
    NSLog(@"app delegate called");
}

@end
