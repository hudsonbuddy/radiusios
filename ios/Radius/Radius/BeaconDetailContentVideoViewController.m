//
//  BeaconDetailContentVideoViewController.m
//  radius
//
//  Created by Hud on 9/17/12.
//
//

#import "BeaconDetailContentVideoViewController.h"

@interface BeaconDetailContentVideoViewController () <SlidingCommentDelegate>

@end

@implementation BeaconDetailContentVideoViewController
@synthesize beaconDetailVideoWebViewOutlet;
@synthesize BeaconVideoCommentTableViewOutlet;
@synthesize voteButtonOutlet;
@synthesize voteScoreLabel;
@synthesize commentButtonOutlet;
@synthesize contentID, contentNotVotedYet, contentString, contentType, contentVotedDown, contentVotedUp, contentVoteScore;
@synthesize beaconContentDictionary;
@synthesize userTokenString, userNameString;
@synthesize likeCountLabel, commentCountLabel;
@synthesize likeCountString, commentCountString;
@synthesize youtubeThumbnailImageViewOutlet;
@synthesize beaconIDString, beaconNameString;
@synthesize beaconDetailContentVideoDelegate;

NSMutableDictionary *imageCacheDictionary;

- (void) setupThumbnailImageView {
    
    NSString *urlString = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/%@.jpg",contentString, @"2"];
    NSURL *thumbnailActualURL = [[NSURL alloc]initWithString:urlString];
    NSLog(@"youtube url is: %@", urlString);
    if (!imageCacheDictionary) {
        imageCacheDictionary = [[NSMutableDictionary alloc] init];
    }
    AsyncImageView *thumbnailInstance = [[AsyncImageView alloc] initWithFrame:youtubeThumbnailImageViewOutlet.frame imageURL:thumbnailActualURL cache:imageCacheDictionary loadImmediately:YES];
    [youtubeThumbnailImageViewOutlet addSubview:thumbnailInstance];
    
    UIImage *playOverlay = [UIImage imageNamed:@"btn_videoplay_full@2x.png"];
    UIButton *playButtonForThumbnail = [UIButton buttonWithType:UIButtonTypeCustom];
    playButtonForThumbnail.frame = CGRectMake(youtubeThumbnailImageViewOutlet.frame.origin.x + 100, youtubeThumbnailImageViewOutlet.frame.origin.y + 104, 120, 120);
    [playButtonForThumbnail setImage:playOverlay forState:UIControlStateNormal];
    [playButtonForThumbnail addTarget:self action:@selector(setupMoviePlayer) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:playButtonForThumbnail];
    [playButtonForThumbnail.superview bringSubviewToFront:playButtonForThumbnail];
    
    
    
}

- (void) setupMoviePlayer {
    
//    NSString *urlAddress= [NSString stringWithFormat:@"http://chi-v48.chi.youtube.com/get_video?video_id=%@.flv", contentString];
//    NSLog(@"the content string: %@", contentString);
//    NSLog(@"the urladdress is: %@", urlAddress);
//    NSURL *actualURL = [NSURL URLWithString:urlAddress];
//    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL: actualURL];
//    
//    [self presentMoviePlayerViewControllerAnimated:player];
//    NSString *urlAddress= [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", contentString];
//    NSString *videoHTML = [NSString stringWithFormat:@"\
//                 <html>\
//                 <head>\
//                 <style type=\"text/css\">\
//                 iframe {position:absolute; top:50%%; margin-top:-130px;}\
//                 body {background-color:#000; margin:0;}\
//                 </style>\
//                 </head>\
//                 <body>\
//                 <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
//                 </body>\
//                 </html>", urlAddress];
    
    NSString *newVideoHTML = [NSString stringWithFormat:@"<iframe width=\"320\" height=\"240\" src=\"http://www.youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen></iframe>                 <style type=\"text/css\">\
                              iframe {}\
                              body {background-color:#000; margin:0; padding:0;}\
                              </style>", contentString];
    
    UIWebView *newWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 240)];
    [newWebView loadHTMLString:newVideoHTML baseURL:nil];
    [self.view addSubview:newWebView];
    
//    int64_t delayInSeconds = 3.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        NSLog(@"%@",[self.view firstAvailableUIViewController]);
//    });
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"pnl_navbar.png"] forBarMetrics:UIBarMetricsDefault];

}



- (void) setupLikeAndCommentLabels {
    
    if ([likeCountString doubleValue] == 0){
        
        likeCountLabel.hidden = YES;
        
    }else if ([likeCountString doubleValue] == 1){
        
        
        likeCountLabel.text = likeCountString;
        likeCountLabel.textColor = [UIColor blackColor];
        likeCountLabel.backgroundColor = [UIColor whiteColor];
        likeCountLabel.layer.cornerRadius = 3;
        likeCountLabel.textAlignment = UITextAlignmentCenter;
        likeCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:12.0];
        
        
        likeCountLabel.numberOfLines = 1;
        CGSize maximumLabelSize = CGSizeMake(9999,likeCountLabel.frame.size.height);
        CGSize expectedLabelSize = [[likeCountLabel text] sizeWithFont:[likeCountLabel font]
                                                     constrainedToSize:maximumLabelSize
                                                         lineBreakMode:[likeCountLabel lineBreakMode]];
        [likeCountLabel setFrame:CGRectMake(likeCountLabel.frame.origin.x+28, likeCountLabel.frame.origin.y,         expectedLabelSize.width+5, likeCountLabel.frame.size.height-5)];
        
        
    }else if ([likeCountString doubleValue] != 0 && [likeCountString doubleValue] >1) {
        likeCountLabel.text = likeCountString;
        likeCountLabel.textColor = [UIColor blackColor];
        likeCountLabel.backgroundColor = [UIColor whiteColor];
        likeCountLabel.layer.cornerRadius = 3;
        likeCountLabel.textAlignment = UITextAlignmentRight;
        likeCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:12.0];
        
        
        likeCountLabel.numberOfLines = 1;
        CGSize maximumLabelSize = CGSizeMake(9999,likeCountLabel.frame.size.height);
        CGSize expectedLabelSize = [[likeCountLabel text] sizeWithFont:[likeCountLabel font]
                                                     constrainedToSize:maximumLabelSize
                                                         lineBreakMode:[likeCountLabel lineBreakMode]];
        [likeCountLabel setFrame:CGRectMake(likeCountLabel.frame.origin.x+28, likeCountLabel.frame.origin.y,         expectedLabelSize.width+2, likeCountLabel.frame.size.height-5)];
        
        
    }
    
    if ([commentCountString doubleValue] ==0){
        
        commentCountLabel.hidden = YES;
        commentCountLabel.text = @"";
        
    }else if ([commentCountString doubleValue] == 1){
        
        commentCountLabel.text = commentCountString;
        commentCountLabel.textColor = [UIColor blackColor];
        commentCountLabel.backgroundColor = [UIColor whiteColor];
        commentCountLabel.layer.cornerRadius = 3;
        commentCountLabel.textAlignment = UITextAlignmentCenter;
        commentCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:12.0];
        
        commentCountLabel.numberOfLines = 1;
        CGSize maximumLabelSize = CGSizeMake(9999,commentCountLabel.frame.size.height);
        CGSize expectedLabelSize = [[commentCountLabel text] sizeWithFont:[commentCountLabel font]
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:[commentCountLabel lineBreakMode]];
        [commentCountLabel setFrame:CGRectMake(commentCountLabel.frame.origin.x+30, commentCountLabel.frame.origin.y, expectedLabelSize.width+5, commentCountLabel.frame.size.height-5)];
        
    }else if ([commentCountString doubleValue] !=0 && [commentCountString doubleValue] >1) {
        commentCountLabel.text = commentCountString;
        commentCountLabel.textColor = [UIColor blackColor];
        commentCountLabel.backgroundColor = [UIColor whiteColor];
        commentCountLabel.layer.cornerRadius = 3;
        commentCountLabel.textAlignment = UITextAlignmentRight;
        commentCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:12.0];
        
        commentCountLabel.numberOfLines = 1;
        CGSize maximumLabelSize = CGSizeMake(9999,commentCountLabel.frame.size.height);
        CGSize expectedLabelSize = [[commentCountLabel text] sizeWithFont:[commentCountLabel font]
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:[commentCountLabel lineBreakMode]];
        [commentCountLabel setFrame:CGRectMake(commentCountLabel.frame.origin.x+30, commentCountLabel.frame.origin.y,         expectedLabelSize.width+2, commentCountLabel.frame.size.height-5)];
    }
    
    
}

-(void) incrementCommentScoreUp {
    
    if (commentCountLabel.hidden) {
        commentCountLabel.text = @"1";
        commentCountLabel.textColor = [UIColor blackColor];
        commentCountLabel.backgroundColor = [UIColor whiteColor];
        commentCountLabel.layer.cornerRadius = 3;
        commentCountLabel.textAlignment = UITextAlignmentCenter;
        commentCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:12.0];
        
        commentCountLabel.numberOfLines = 1;
        CGSize maximumLabelSize = CGSizeMake(9999,commentCountLabel.frame.size.height);
        CGSize expectedLabelSize = [[commentCountLabel text] sizeWithFont:[commentCountLabel font]
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:[commentCountLabel lineBreakMode]];
        [commentCountLabel setFrame:CGRectMake(commentCountLabel.frame.origin.x, commentCountLabel.frame.origin.y, expectedLabelSize.width+5, commentCountLabel.frame.size.height)];
    }else{
    
    commentCountLabel.text = [NSString stringWithFormat:@"%i", [commentCountLabel.text integerValue]+1];
    CGSize maximumLabelSize = CGSizeMake(9999,commentCountLabel.frame.size.height);
    CGSize expectedLabelSize = [[commentCountLabel text] sizeWithFont:[commentCountLabel font]
                                                    constrainedToSize:maximumLabelSize
                                                        lineBreakMode:[commentCountLabel lineBreakMode]];
    [commentCountLabel setFrame:CGRectMake(commentCountLabel.frame.origin.x, commentCountLabel.frame.origin.y,         expectedLabelSize.width+2, commentCountLabel.frame.size.height)];
    
    }
    
    if ([beaconDetailContentVideoDelegate respondsToSelector:@selector(populateBeaconContent)]) {
        [beaconDetailContentVideoDelegate populateBeaconContent];
    }
    
}

- (void) setupVoteScoreAndButton {
    
    voteButtonOutlet.titleLabel.text = @"text";
    voteScoreLabel.text = [NSString stringWithFormat:@"%@", [beaconContentDictionary objectForKey:@"score"]];
    
    if (contentNotVotedYet == YES) {
        
        [voteButtonOutlet setImage:[UIImage imageNamed:@"btn_cvp_like.png"] forState:UIControlStateNormal];
    }else if (contentVotedDown == YES){
        
        voteButtonOutlet.imageView.image = [UIImage imageNamed:@"ico_me.png"];
    }else if (contentVotedUp == YES){
        
        [voteButtonOutlet setImage:[UIImage imageNamed:@"btn_cvp_like_green.png"] forState:UIControlStateNormal];
    }
    
    
}

- (IBAction)voteButtonPressed:(id)sender {
    
    if (contentNotVotedYet) {
        
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", contentID, @"content_id", @"up", @"type", nil] apiMethod:@"content/vote" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            // deal with response object
            NSLog(@"working %@", response);
            contentVotedUp = YES;
            contentNotVotedYet = NO;
            if ([response objectForKey:@"score"] != nil) {
                [likeCountLabel setText:[NSString stringWithFormat:@"%@",[response objectForKey:@"score"]]];
            }
            UIImage *newImageForLikeButton = [UIImage imageNamed:@"btn_cvp_like_green.png"];
            
            [voteButtonOutlet setImage:newImageForLikeButton forState:UIControlStateNormal];
            
            if ([beaconDetailContentVideoDelegate respondsToSelector:@selector(populateBeaconContent)]) {
                [beaconDetailContentVideoDelegate populateBeaconContent];
            }
            
            
        }];
        
    }else if (contentVotedUp) {
        
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", contentID, @"content_id", @"reset", @"type", nil] apiMethod:@"content/vote" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            // deal with response object
            NSLog(@"working %@", response);
            contentVotedUp = NO;
            contentNotVotedYet = YES;
            if ([response objectForKey:@"score"] != nil) {
                likeCountLabel.hidden = NO;
                [likeCountLabel setText:[NSString stringWithFormat:@"%@",[response objectForKey:@"score"]]];
            }
            UIImage *newImageForLikeButton = [UIImage imageNamed:@"btn_cvp_like.png"];
            
            [voteButtonOutlet setImage:newImageForLikeButton forState:UIControlStateNormal];
            
            if ([beaconDetailContentVideoDelegate respondsToSelector:@selector(populateBeaconContent)]) {
                [beaconDetailContentVideoDelegate populateBeaconContent];
            }

            
        }];
        
    }
    
}

- (IBAction)commentVideoButtonPressed:(id)sender {
    
    [MFSlidingView slideOut];
    
    SlidingCommentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"SlidingCommentView" owner:self options:nil]objectAtIndex:0];
    
    //    customView.postTextContentTextView.text = @"Post Text Here";
    //    customView.postContentType = @"text";
    //    customView.postContentViewDelegate =self;
    //    customView.CommentScoreLabelOutlet.text = [NSString stringWithFormat:@"%@", [beaconContentDictionary objectForKey:@"score"]];
    
    customView.SlidingCommentTableViewOutlet.delegate = customView;
    customView.SlidingCommentTableViewOutlet.dataSource = customView;
    customView.AddCommentTextFieldOutlet.delegate=customView;
    customView.AddCommentTextFieldOutlet.returnKeyType = UIReturnKeyDone;
    customView.postSendingContentID = contentID;
    customView.userTask = @"PostComment";
    customView.userTokenString = userTokenString;
    customView.contentVotedUp = contentVotedUp;
    customView.contentVotedDown = contentVotedDown;
    customView.contentNotVotedYet = contentNotVotedYet;
    customView.slidingCommentDelegate = self;
    customView.layer.cornerRadius = 2;
    
    UIImage *img = [UIImage imageNamed:@"bkgd_generic@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    [customView.SlidingCommentTableViewOutlet setBackgroundView:backgroundNotificationsView];
    customView.SlidingCommentTableViewOutlet.backgroundView.contentMode = UIViewContentModeTop;
    
    //    backgroundNotificationsView.alpha = 0.3;
    //
    //    [customView.SlidingCommentTableViewOutlet addSubview:backgroundNotificationsView];
    //    [customView.SlidingCommentTableViewOutlet sendSubviewToBack:backgroundNotificationsView];
    
    
    
    //    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapToDismissFirstResponder:)];
    //    [customView addGestureRecognizer:singleTapRecognizer];
    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        
        [MFSlidingView slideOut];
        [customView.AddCommentTextFieldOutlet resignFirstResponder];
        
    };
    
    
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", nil] apiMethod:@"comments" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        // deal with response object
        NSLog(@"working on getting comments %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            customView.responseArray = response;
            [customView.SlidingCommentTableViewOutlet reloadData];
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            customView.responseDictionary = response;
            [customView.SlidingCommentTableViewOutlet reloadData];
            
        }
        
        [MFSlidingView slideOut];

        [MFSlidingView slideView:customView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Comments" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
    }];

    
}

#pragma mark Apple Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    [self setupVoteScoreAndButton];
    [self setupLikeAndCommentLabels];
//    [self setupThumbnailImageView];
    [self setupMoviePlayer];
    
//    NSString *urlAddress= [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", contentString];
//    NSLog(@"%@", urlAddress);
//    NSURL *actualURL = [NSURL URLWithString:urlAddress];
//    NSURLRequest *requestURLObject = [NSURLRequest requestWithURL:actualURL];
//    [beaconDetailVideoWebViewOutlet loadRequest:requestURLObject];
//    NSLog(@"loading video");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
	// Do any additional setup after loading the view.
    
//    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
//    
//    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
//    backgroundNotificationsView.alpha = 0.3;
//    
//    [self.view addSubview:backgroundNotificationsView];
//    [self.view sendSubviewToBack:backgroundNotificationsView ];
    
//    UIImage *buttonImg = [UIImage imageNamed:@"btn_cvp_like@2x.png"];
//    
//    [self.voteButtonOutlet setImage:buttonImg forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"%d",animated);
    if(!animated){
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
        
    }
    
//    if (![[self.view firstAvailableUIViewController] isKindOfClass:[MPMoviePlayerViewController class]]) {
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
//    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [self setBeaconDetailVideoWebViewOutlet:nil];
    [self setBeaconVideoCommentTableViewOutlet:nil];
    [self setYoutubeThumbnailImageViewOutlet:nil];
    [super viewDidUnload];
}



@end
