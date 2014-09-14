//
//  DescribeContentView.m
//  Radius
//
//  Created by Fred Ehrsam on 10/31/12.
//
//

#import "DescribeContentView.h"
#import <QuartzCore/QuartzCore.h>
#import "Facebook.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "Flurry.h"

@interface DescribeContentView() {
    BOOL showsPlaceholder;
}

@end


@implementation DescribeContentView
static NSString *describeString = @"Describe it! (optional)";
static const CGFloat FACEBOOK_ACTIVITY_INDICATOR_TAG = 100;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame handler:(void (^)(DescribeContentView *describeView, NSString * description, BOOL fbShare) )handler
{
    self = [self initWithFrame:frame];
    if(self) {
        self.handler = handler;
        //[[[NSBundle mainBundle]loadNibNamed:@"DescribeContentView" owner:self options:nil]objectAtIndex:0];
        [[NSBundle mainBundle] loadNibNamed:@"DescribeContentView" owner:self options:nil];
        
        [self.postButton addTarget:self action:@selector(postPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.mainView];
        [self.descriptionTextField setDelegate:self];
        [self setupFonts];
        [self setupTextView];
        
        NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([[myDefaults objectForKey:@"facebook_share"] isEqualToString:@"YES"]) {
            [self shareToFacebook];
        }

        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self.descriptionTextField action:@selector(resignFirstResponder)];
        tgr.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tgr];
        
        [self showPlaceholderText];
    }
    return self;
}

-(void) showPlaceholderText
{
    showsPlaceholder = YES;
    self.descriptionTextField.text = describeString;
    self.descriptionTextField.textColor = [UIColor lightGrayColor];
}

-(void) hidePlaceholderText
{
    showsPlaceholder = NO;
    self.descriptionTextField.text = @"";
    self.descriptionTextField.textColor = [UIColor blackColor];
}

-(void) setupTextView
{
    self.descriptionTextField.clipsToBounds = YES;
    self.descriptionTextField.layer.cornerRadius = 5.0f;
}

-(void)setupWithBeaconName:(NSString *) name andThumbnail:(UIImage *) thumbnail
{
    [self.beaconNameLabel setText:name];
    [self.contentThumbnailImageView setImage:thumbnail];
    CALayer *layer = [self.contentThumbnailImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0];
}

- (IBAction)postPressed: (id) sender
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Posted Content"];
#endif
    
    if (showsPlaceholder)
    {
        self.handler(self, nil, self.facebookButton.isSelected);
    }
    else
    {
        self.handler(self, self.descriptionTextField.text, self.facebookButton.isSelected);
    }
}

- (IBAction)facebookButtonPressed:(id)sender
{
    [self shareToFacebook];
}

-(void) shareToFacebook {
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Pressed Facebook Share Button while Posting Content"];
#endif
    [Flurry logEvent:@"Content_FB_Post_Pressed"];
    
    UIActivityIndicatorView *fbActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    fbActivityIndicatorView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 20, self.frame.size.width, self.frame.size.height);
    fbActivityIndicatorView.tag = FACEBOOK_ACTIVITY_INDICATOR_TAG;
    [fbActivityIndicatorView startAnimating];
    [self addSubview:fbActivityIndicatorView];
    
    RadiusRequest *request = [RadiusRequest requestWithAPIMethod:@"me"];
    [request startWithCompletionHandler:^(id response, RadiusError *error) {
        
        [[self viewWithTag:FACEBOOK_ACTIVITY_INDICATOR_TAG]removeFromSuperview];
        
        NSInteger fb_uid = [[response objectForKey:@"fb_uid"] integerValue];
        if (fb_uid!=0)
        {
            self.facebookButton.selected = !self.facebookButton.isSelected;
            NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];

            if (self.facebookButton.selected) {
                [myDefaults setObject:@"YES" forKey:@"facebook_share"];
            }else if (!self.facebookButton.selected){
                [myDefaults setObject:@"NO" forKey:@"facebook_share"];
            }

        }
        else
        {
            [self connectUserWithFacebook];
        }
    }];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [self.descriptionTextField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) connectUserWithFacebook
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Attempted to Connect With Facebook while Posting Content"];
#endif
    
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
             NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:session.accessToken,@"fb_access_token",nil];
             RadiusRequest *request = [RadiusRequest requestWithParameters:payload apiMethod:@"connect_facebook" httpMethod:@"POST"];
             [request startWithCompletionHandler:^(id response, RadiusError *error) {
                 if(error) {
                     // something went wrong
                     NSLog(@"%@",response);
                     
                     if(error.type == RadiusErrorFbAlreadyConnected) {
                         
                         UIAlertView *alertViewForFBError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, you Facebook account is already connected to another Radius account. We were unable to share to Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         [alertViewForFBError show];
                         
//                         PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
//                         [popupAlert setupWithDescriptionText:@"Sorry, your Facebook account is already connected to another Radius account" andButtonText:@"OK"];
//                         SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//                         void (^cancelOrDoneBlock)() = ^{
//                             // we must manually slide out the view out if we specify this block
//                             [MFSlidingView slideOut];
//                         };
//                         [MFSlidingView slideView:popupAlert intoView:self onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                     }
                 } else {
                    [Flurry logEvent:@"Content_Post_FB_Connected"];
                     
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setObject:session.accessToken forKey:@"fb_access_token"];
                     self.facebookButton.selected = YES;
                 }
             }];
         }
     }];
    
    NSLog(@"started to open session");
}


-(void) setupFonts
{
    [self.beaconNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.beaconNameLabel.font.pointSize]];
    [self.descriptionTextField setFont:[UIFont fontWithName:@"Quicksand" size:self.descriptionTextField.font.pointSize]];
    [self.postingToLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.postingToLabel.font.pointSize]];
    [self.shareToLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.shareToLabel.font.pointSize]];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (showsPlaceholder) {
        [self hidePlaceholderText];

    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self showPlaceholderText];
    }
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
