//
//  InitialLoadingViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 9/11/12.
//
//

#import "InitialLoadingViewController.h"
#import "RadiusRequest.h"
#import "RadiusAppDelegate.h"
#import "MFSlidingView.h"
#import "MFSideMenuManager.h"
#import "UIViewController+MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
#import "MapViewController.h"


@interface InitialLoadingViewController ()

@end

@implementation InitialLoadingViewController

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
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    
    if (self.view.frame.size.height > 500) {
        UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone5_splash@2x.png"]];
        backgroundNotificationsView.alpha = 1;
        backgroundNotificationsView.frame = CGRectMake(0, -20, 320, 568);
        self.view.contentMode = UIViewContentModeTop;
        [self.view addSubview:backgroundNotificationsView];
    }else{
        
        UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Splash.png"]];
        backgroundNotificationsView.alpha = 1;
        backgroundNotificationsView.frame = CGRectMake(0, -20, 320, 480);
        self.view.contentMode = UIViewContentModeTop;
        [self.view addSubview:backgroundNotificationsView];
        
    }

    [self LoginIfValidToken];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)LoginIfValidToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:@"facebook_share"] == nil) {
//        [defaults setObject:@"YES" forKey:@"facebook_share"];
//    }
    NSString *token = [defaults objectForKey:@"token"];
    if (token)
    {
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:token, @"token", nil] apiMethod:@"token_status"];
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
            if ([[response objectForKey:@"valid"] integerValue] == 1)
            {
                [Flurry setUserID:[NSString stringWithFormat:@"%@",[defaults objectForKey:@"id"]]];
                
                [RadiusRequest setToken:token];
                
                MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewID"];
                mapViewController.showSuggestions = YES;
                [self transitionToViewController:mapViewController];
                
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge)];
            }
            else
            {
                UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                    instantiateViewControllerWithIdentifier:@"loginViewID"];
                [self.navigationController pushViewController:demoController animated:YES];
            }
        }];
    }
    else
    {
        UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                            instantiateViewControllerWithIdentifier:@"loginViewID"];
        [self.navigationController pushViewController:demoController animated:YES];
    }
}

- (void)transitionToViewController:(UIViewController *)viewController
{
    //demoController.title = [NSString stringWithFormat:@"Map"];
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}


@end
