//
//  ShareToFacebookView.m
//  Radius
//
//  Created by Fred Ehrsam on 10/24/12.
//
//

#import "ShareToFacebookView.h"
#import "RadiusRequest.h"
#import "Facebook.h"
#import "MFSlidingView.h"
#import "Flurry.h"

@interface ShareToFacebookView() {
    BOOL placeholderSet;
}

@end


@implementation ShareToFacebookView
@synthesize contentDescriptionTextView;
@synthesize contentID;
@synthesize shareOnFBButton;
static NSString *placeholderString = @"Describe it! (optional)";



- (void)setPlaceholder
{
    [contentDescriptionTextView setText:placeholderString];
    [contentDescriptionTextView setTextColor:[UIColor lightGrayColor]];
    [contentDescriptionTextView setFont:[UIFont fontWithName:@"Quicksand" size:14]];
    placeholderSet = YES;

}

- (void)unsetPlaceholder
{
    [contentDescriptionTextView setText:@""];
    [contentDescriptionTextView setTextColor:[UIColor blackColor]];
    [contentDescriptionTextView setFont:[UIFont fontWithName:@"Quicksand" size:14]];

    placeholderSet = NO;
}

-(void) setupFBViewWithContentID:(NSString *) cID
{
    self.contentID = cID;
    [self.contentDescriptionTextView setDelegate:self];
    [self setPlaceholder];
    
    self.contentDescriptionTextView.layer.cornerRadius = 3;
    self.shareContentType = @"content";
        
}

-(void) setupFBViewWithBeaconID:(NSString *) beaconID
{
    self.beaconID = beaconID;
    [self.contentDescriptionTextView setDelegate:self];
    [self setPlaceholder];
    
    self.contentDescriptionTextView.layer.cornerRadius = 3;
    self.shareContentType = @"beacon";

    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(placeholderSet) {
        [self unsetPlaceholder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self setPlaceholder];
    }
}

- (IBAction)shareOnFBPressed
{
    if ([self.shareContentType isEqualToString:@"content"]) {
        [self shareContentToFacebook];
    }else if ([self.shareContentType isEqualToString:@"beacon"]){
        [self shareBeaconToFacebook];
    }
    
}

-(void) shareContentToFacebook{
    
    [shareOnFBButton setEnabled:NO];
    NSString *message = placeholderSet?@"":contentDescriptionTextView.text;
    RadiusRequest *shareRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", message, @"message", nil] apiMethod:@"content/share/facebook" httpMethod:@"POST"];
    [shareRequest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         if (error && error.type == RadiusErrorFbAlreadyConnected)
         {
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
                           //Connect that FB token to the user's Radius account
                           RadiusRequest *linkFBRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:@"token"], @"token", session.accessToken, @"fb_access_token", nil] apiMethod:@"connect_facebook" httpMethod:@"POST"];
                           [linkFBRequest startWithCompletionHandler:^(id response, RadiusError *error) {
                               //Try sharing on FB again now that we're connected
                               [self shareOnFBPressed];
                           }];
                       }];
                  }
                  //FB request denied by user
                  else
                  {
                      [self removeFromSuperview];
                  }
              }];
         }
         else
         {
             NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.contentID forKey:@"content_item"];
             [Flurry logEvent:@"Content_Shared" withParameters:eventParameters];
             
             //Need a congrats view to display here
             [MFSlidingView slideOut];
         }
     }];

    
}

-(void) shareBeaconToFacebook {
    
    [shareOnFBButton setEnabled:NO];
    NSString *message = placeholderSet?@"":contentDescriptionTextView.text;
    RadiusRequest *shareRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.beaconID, @"beacon_id", message, @"message", nil] apiMethod:@"beacon/share/facebook" httpMethod:@"POST"];
    [shareRequest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         if (error && error.type == RadiusErrorFbAlreadyConnected)
         {
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
                           //Connect that FB token to the user's Radius account
                           RadiusRequest *linkFBRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:@"token"], @"token", session.accessToken, @"fb_access_token", nil] apiMethod:@"connect_facebook" httpMethod:@"POST"];
                           [linkFBRequest startWithCompletionHandler:^(id response, RadiusError *error) {
                               //Try sharing on FB again now that we're connected
                               [self shareOnFBPressed];
                           }];
                       }];
                  }
                  //FB request denied by user
                  else
                  {
                      [self removeFromSuperview];
                  }
              }];
         }
         else
         {
             NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.beaconID forKey:@"beacon"];
             [Flurry logEvent:@"Beacon_Shared" withParameters:eventParameters];
             
             //Need a congrats view to display here
             [MFSlidingView slideOut];
         }
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

@end
