//
//  TwitterLoginViewController.m
//  TwitterTest
//
//  Created by David Herzka on 8/14/12.
//  Copyright (c) 2012 David Herzka. All rights reserved.
//

#import "TwitterLoginViewController.h"
#import "RadiusAppDelegate.h"
#import "MFSideMenu.h"
#import "RegisterViewController.h"

@interface TwitterLoginViewController ()
@property (strong, nonatomic) NSDictionary *twitterLoginInfo;
@end

@implementation TwitterLoginViewController
@synthesize webView;
@synthesize twitterLoginInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sc2.pnptsg.com/twitter1"]];
    [self.webView loadRequest:r];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) pushRegistrationWithValues:(NSDictionary *)dict {
    RegisterViewController *registerController = [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
    registerController.title = @"Register";
    [registerController setInitialValues:dict];
    registerController.twitterLoginInfo = twitterLoginInfo;
    [self.navigationController pushViewController:registerController animated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if([request.URL.path isEqualToString:@"/twitter2"]) {
        
        __block NSString *access_token, *access_token_secret, *username, *uid;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData * data, NSError *e) {
            NSError *error = nil;
            NSInteger status = [(NSHTTPURLResponse *)response statusCode];
            if(status!=200) {
                // error
                NSLog(@"Twitter Error");
            }
            NSDictionary *r = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            access_token = [r objectForKey:@"access_token"];
            access_token_secret = [r objectForKey:@"access_token_secret"];
            twitterLoginInfo = [NSDictionary dictionaryWithObjectsAndKeys:access_token, @"access_token", access_token_secret, @"access_token_secret", nil];
            username = [r objectForKey:@"username"];
            uid = [r objectForKey:@"uid"];
            
            NSLog(@"%@, %@",access_token,access_token_secret);
            
            TWRequest *twr = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/lookup.json"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:username,@"screen_name", nil] requestMethod:TWRequestMethodGET];
            
            [twr performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSError *e;
                NSDictionary *r = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&e] objectAtIndex:0];
                NSLog(@"%@",r);
                                
                //push registration view controller with initial info
                [self performSelectorOnMainThread:@selector(pushRegistrationWithValues:) withObject:r waitUntilDone:NO];
            }];
            
        }];
        
        return NO;
    }
    return YES;
}


@end
