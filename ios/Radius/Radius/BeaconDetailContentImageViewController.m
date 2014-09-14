//
//  BeaconDetailContentImageViewController.m
//  radius
//
//  Created by Hud on 9/6/12.
//
//

#import "BeaconDetailContentImageViewController.h"
#import "BeaconContentViewController2.h"
#import "ProfileViewController2.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "SlidingTableView.h"
#import "Flurry.h"

@interface BeaconDetailContentImageViewController () <SlidingCommentDelegate>
{
    UITapGestureRecognizer *imageTapRecognizer;
    UIView * container;
    UIScrollView * scrollContainer;

    SlidingTableView *_customSlidingTableView;
    NSArray *responseFollowedArray;
    
    AsyncImageView *aiv;
}

@property (nonatomic, strong) NSMutableDictionary *cache;


@end

@implementation BeaconDetailContentImageViewController
@synthesize voteButtonOutlet;
@synthesize commentButtonOutlet;
@synthesize voteScoreLabel;
@synthesize cache;
@synthesize beaconNameButton, nameButton, descriptionLabel;


@synthesize DetailContentImageView;
@synthesize BeaconImageCommentTableViewOutlet;
@synthesize contentNotVotedYet, contentVotedDown, contentVotedUp, contentVoteStatus;
@synthesize contentVoteScore;
@synthesize beaconNameString, beaconIDString;
@synthesize contentString, contentType, contentID;
@synthesize beaconContentDictionary;
@synthesize userNameString, userTokenString;
@synthesize contentImageHeight, contentImageWidth;
@synthesize likeCountLabel, commentCountLabel;
@synthesize likeCountString, commentCountString;
@synthesize frameContentImageHeight, frameContentImageWidth;
@synthesize frameContentOriginX, frameContentOriginY;
@synthesize topInfoBarView, bottomInfoBarView;
@synthesize beaconDetailContentImageDelegate;
@synthesize posterIDString;
@synthesize contentOwnerSettingsButton;
@synthesize currentUserIsContentOwner;
@synthesize likeView, commentView;
@synthesize imageArray;
@synthesize initialContentIndex, currentContentIndex;
@synthesize currentImageView;

- (void) initializeBeaconContentImage {
    
    [self setContentString:[[beaconContentDictionary objectForKey:@"content"] objectForKey:@"url"]];
    [self setContentID:[beaconContentDictionary objectForKey:@"id"]];
    [self setContentImageHeight:[[beaconContentDictionary objectForKey:@"content"] objectForKey:@"height"]];
    [self setContentImageWidth:[[beaconContentDictionary objectForKey:@"content"] objectForKey:@"width"]];
    [self setCommentCountString:[NSString stringWithFormat:@"%@",[beaconContentDictionary objectForKey:@"num_comments"]]];
    [self setLikeCountString:[NSString stringWithFormat:@"%@",[beaconContentDictionary objectForKey:@"score"]]];
    [self setPosterIDString:[NSString stringWithFormat:@"%@",[beaconContentDictionary objectForKey:@"poster"]]];
    [self setUserNameString:[beaconContentDictionary objectForKey:@"poster"]];
    if ([[beaconContentDictionary objectForKey:@"vote"]integerValue] == -1) {
        [self setContentVotedDown:YES];
    }else if ([[beaconContentDictionary objectForKey:@"vote"]integerValue] == 0) {
        [self setContentNotVotedYet:YES];
    }else if ([[beaconContentDictionary objectForKey:@"vote"]integerValue] == 1) {
        [self setContentVotedUp:YES];
    }
    [self setContentVoteScore:[beaconContentDictionary objectForKey:@"score"]];
    
//    commentCountString = [NSString stringWithFormat:@"%@", [beaconContentDictionary objectForKey:@"num_comments"]];
    
}

-(void) setupBeaconImage {
    
    [self setupLikeAndCommentLabels];
    [self setupNameButtons];
    [self setupDescriptionLabel];

    
    [self setupContentSettingsButton];
    
    [self setupVoteScoreAndButton];
    [self findIndexOfInitialImage];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self setupImageViewWithURL:[NSURL URLWithString:contentString]];
    });
    
    
    
}

-(void) initializeLikeAndCommentLabels {
    
    likeCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:likeCountLabel.font.pointSize];
    commentCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:commentCountLabel.font.pointSize];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:likeView.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = likeView.bounds;
    maskLayer.path = maskPath.CGPath;
    likeView.layer.mask = maskLayer;
    
    UIBezierPath *commentMaskPath = [UIBezierPath bezierPathWithRoundedRect:commentView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *commentMaskLayer = [[CAShapeLayer alloc] init];
    commentMaskLayer.frame = commentView.bounds;
    commentMaskLayer.path = commentMaskPath.CGPath;
    commentView.layer.mask = commentMaskLayer;
    
}

- (void) setupLikeAndCommentLabels {
    

    
    if ([likeCountString integerValue] == 0 || likeCountString == nil || [likeCountString isKindOfClass:[NSNull class]]){
        
        [likeCountLabel setHidden:YES];
        [likeCountLabel setText:@""];
    }
    else
    {
        [likeCountLabel setHidden:NO];
        [likeCountLabel setText:likeCountString];
    }

    if ([commentCountString integerValue] ==0)
    {
        commentCountLabel.hidden = YES;
        commentCountLabel.text = @"";
    }
    else
    {
        [commentCountLabel setHidden:NO];
        [commentCountLabel setText:commentCountString];
    }
}

- (void) initializeImageViewWithScrollContainer{
    
    if (!self.cache) {
        
        self.cache = [[NSMutableDictionary alloc] init];
        
    }
    
//    aiv = [[AsyncImageView alloc] initWithFrame:DetailContentImageView.frame];
    
    CALayer * layer = [aiv layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0];
    
    scrollContainer = [[UIScrollView alloc] initWithFrame: self.view.frame];
    // setup shadow layer and corner
    scrollContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    scrollContainer.layer.shadowOffset = CGSizeMake(0, 1);
    scrollContainer.layer.shadowOpacity = 1;
    scrollContainer.layer.shadowRadius = 5.0;
    scrollContainer.layer.cornerRadius = 5.0;
    scrollContainer.clipsToBounds = NO;
    scrollContainer.contentSize = aiv.frame.size;
    scrollContainer.delegate = self;
    scrollContainer.pinchGestureRecognizer.delegate = self;
    scrollContainer.minimumZoomScale=1;
    scrollContainer.maximumZoomScale=6.0;
    scrollContainer.showsHorizontalScrollIndicator = NO;
    scrollContainer.showsVerticalScrollIndicator = NO;
    scrollContainer.canCancelContentTouches = YES;
    scrollContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:scrollContainer.bounds].CGPath;
    
    // combine the views
    [[[scrollContainer subviews]lastObject]removeFromSuperview];
//    [scrollContainer addSubview: aiv];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:scrollContainer];
    });

    
}

- (void) setupImageViewWithURL: (NSString *)myImageURL {
    

    
    NSLog(@"the width is %@, and the height is: %@", contentImageWidth, contentImageHeight);
    
    NSString *anotherString = [NSString stringWithFormat:@"%@", myImageURL];
    NSURL *imageURL = [[NSURL alloc]initWithString:anotherString];

    CGRect frame;
    
    if ([contentImageHeight doubleValue] >= [contentImageWidth doubleValue]) {
        
        NSLog(@"image taller than wide");
        
        double portraitRatio = [contentImageHeight doubleValue] / [contentImageWidth doubleValue];
        frameContentImageHeight = 350;
        frameContentImageWidth = 350 / portraitRatio;
        
        // make sure width is less than or equal to 320.  This could probably be more elegantly written.
        if(frameContentImageWidth > 320){
            frameContentImageHeight = 320/frameContentImageWidth * frameContentImageHeight;
            frameContentImageWidth = 320;
        }
        
        frameContentOriginX = (320 - frameContentImageWidth)/2;
        frameContentOriginY = 30;
        frame = CGRectMake(frameContentOriginX, frameContentOriginY, frameContentImageWidth, frameContentImageHeight);
    }else if ([contentImageHeight integerValue] < [contentImageWidth integerValue]){
        
        NSLog(@"image wider than tall");
        frameContentImageHeight = [contentImageHeight doubleValue];
        frameContentImageWidth = [contentImageWidth doubleValue];
        
        double portraitRatio = (frameContentImageHeight/frameContentImageWidth);
        
        frameContentImageHeight = 320 * portraitRatio;
        frameContentImageWidth = 320;
        frameContentOriginX = (320 - frameContentImageWidth)/2;
        frameContentOriginY = 60;
        frame = CGRectMake(frameContentOriginX, frameContentOriginY, frameContentImageWidth, frameContentImageHeight);
        NSLog(@"the new width is: %f and the new height is: %f", frameContentImageWidth, frameContentImageHeight);
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [aiv removeFromSuperview];
        aiv = [[AsyncImageView alloc] initWithFrame:frame imageURL:imageURL cache:self.cache];
        [scrollContainer addSubview:aiv];
        [scrollContainer setNeedsDisplay];
        [aiv setNeedsDisplay];
        [self addTapRecognizerToImage];
    });
    
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    UIImage *randomImage = [[UIImage alloc] initWithData:imageData];
    currentImageView = [[UIImageView alloc] initWithImage:randomImage];
    currentImageView.frame = aiv.frame;
    //Round the corners

    
//    //Add a shadow by wrapping the avatar into a container
//    container = [[UIView alloc] initWithFrame: DetailContentImageView.frame];
//    
//    DetailContentImageView.frame = CGRectMake(0,0,DetailContentImageView.frame.size.width, DetailContentImageView.frame.size.height);
//    
//    // setup shadow layer and corner
//    container.layer.shadowColor = [UIColor blackColor].CGColor;
//    container.layer.shadowOffset = CGSizeMake(0, 1);
//    container.layer.shadowOpacity = 1;
//    container.layer.shadowRadius = 5.0;
//    container.layer.cornerRadius = 5.0;
//    container.clipsToBounds = NO;
//    
//    // combine the views
//    [container addSubview: DetailContentImageView];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view addSubview:container];
//        //[self.view sendSubviewToBack:container];
//    });
    
    //Add a shadow by wrapping the avatar into a container
    
//    DetailContentImageView.frame = CGRectMake(0,0,DetailContentImageView.frame.size.width, DetailContentImageView.frame.size.height);
    


}

- (void) postCommentMethod {
    
    
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
    customView.contentVotedUp = contentVotedUp;
    customView.contentVotedDown = contentVotedDown;
    customView.contentNotVotedYet = contentNotVotedYet;
    customView.slidingCommentDelegate = self;
    customView.commentTableIsEditing = NO;
    customView.AddCommentTextFieldOutlet.font = [UIFont fontWithName:@"Quicksand" size:14];
    [customView setupDismissCellEditing];
    customView.layer.cornerRadius = 2;
    
    UIImage *img = [UIImage imageNamed:@"bkgd_generic@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    [customView.SlidingCommentTableViewOutlet setBackgroundView:backgroundNotificationsView];
    customView.SlidingCommentTableViewOutlet.backgroundView.contentMode = UIViewContentModeTop;
    
    //    backgroundNotificationsView.alpha = 0.3;
    //
    //    [customView.SlidingCommentTableViewOutlet addSubview:backgroundNotificationsView];    
    
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
        
        
        [MFSlidingView slideView:customView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Comments" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
    }];
    
}

-(void) incrementCommentScoreUp {
    
    if ([commentCountLabel.text isEqualToString:@""] || commentCountLabel.hidden == YES) {
        
        commentCountLabel.hidden = NO;
        commentCountLabel.text = @"1";
        commentCountString = commentCountLabel.text;
        commentCountLabel.textColor = [UIColor blackColor];
        commentCountLabel.backgroundColor = [UIColor whiteColor];
        commentCountLabel.layer.cornerRadius = 3;
        commentCountLabel.textAlignment = UITextAlignmentCenter;
        commentCountLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:commentCountLabel.font.pointSize];
        
        commentCountLabel.numberOfLines = 1;
        CGSize maximumLabelSize = CGSizeMake(9999,commentCountLabel.frame.size.height);
        CGSize expectedLabelSize = [[commentCountLabel text] sizeWithFont:[commentCountLabel font]
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:[commentCountLabel lineBreakMode]];
        expectedLabelSize.width = expectedLabelSize.width +5;
        
        [commentCountLabel setFrame:CGRectMake(283, commentCountLabel.frame.origin.y, expectedLabelSize.width, 16)];
        
    }else{
        
        commentCountLabel.text = [NSString stringWithFormat:@"%i", [commentCountLabel.text integerValue]+1];
        commentCountString = commentCountLabel.text;
    }
    
    if ([beaconDetailContentImageDelegate respondsToSelector:@selector(populateBeaconContent)]) {
        [beaconDetailContentImageDelegate populateBeaconContent];
    }
    
}

-(void) initializeVoteScoreAndButton {
    
    voteScoreLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:voteScoreLabel.font.pointSize];
    voteButtonOutlet.titleLabel.text = @"text";
    [voteScoreLabel setHidden:YES];


    
}

- (void) setupVoteScoreAndButton {
    
    voteScoreLabel.text = [NSString stringWithFormat:@"%@", [beaconContentDictionary objectForKey:@"score"]];
    
    if (contentNotVotedYet == YES) {
        
        UIImage *buttonImg = [UIImage imageNamed:@"btn_cvp_like.png"];
        [self.voteButtonOutlet setImage:buttonImg forState:UIControlStateNormal];
        
    }else if (contentVotedDown == YES){
        voteButtonOutlet.imageView.image = [UIImage imageNamed:@"ico_me.png"];
        voteButtonOutlet.alpha = 0.5;
        
    }else if (contentVotedUp == YES){
        
        UIImage *buttonImg = [UIImage imageNamed:@"btn_cvp_like_green.png"];
        [self.voteButtonOutlet setImage:buttonImg forState:UIControlStateNormal];
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Responding to sliding view to see who's following the beacon
    if ([tableView.dataSource isMemberOfClass:[SlidingTableView class]] || [tableView.dataSource isMemberOfClass:[BeaconFollowers class]])
    {
        ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
        //NSString *userIDString = [NSString stringWithFormat:@"%@",[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] ];
        [meProfileController initializeWithUserID:[[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]];
        
        [self.navigationController pushViewController:meProfileController animated:YES];
        [MFSlidingView slideOut];
    }
}

- (IBAction)likeCountPressed:(id)sender
{
    [self seeContentLikers];
}


-(void) seeContentLikers {
    
    _customSlidingTableView = [[[NSBundle mainBundle]loadNibNamed:@"SlidingTableView" owner:self options:nil]objectAtIndex:0];
    _customSlidingTableView.slidingTableViewTableView.delegate = self;
    _customSlidingTableView.slidingTableViewTableView.dataSource = _customSlidingTableView;
    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    [_customSlidingTableView.slidingTableViewTableView setBackgroundView:backgroundNotificationsView];
    _customSlidingTableView.slidingTableViewTableView.backgroundView.contentMode = UIViewContentModeCenter;
    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:_customSlidingTableView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Likes" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", nil] apiMethod:@"content/likes" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        // deal with response object
        NSLog(@"working %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseFollowedArray = response;
            [_customSlidingTableView setResponseArray:response];
            [_customSlidingTableView.slidingTableViewTableView reloadData];
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            //responseFollowedDictionary = response;
            [_customSlidingTableView setResponseDictionary:response];
            [_customSlidingTableView.slidingTableViewTableView reloadData];
 
        }
        
    }];
}

- (IBAction)voteButtonPressed:(id)sender {
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Voted on an Image"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.contentID forKey:@"content_item"];
    [Flurry logEvent:@"Content_Liked" withParameters:eventParameters];
    
    
    if (contentNotVotedYet) {
        
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", @"up", @"type", nil] apiMethod:@"content/vote" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            // deal with response object
            NSLog(@"working %@", response);
            contentVotedUp = YES;
            contentNotVotedYet = NO;
            if ([response objectForKey:@"score"] != nil) {
//                [likeCountLabel setText:[NSString stringWithFormat:@"%@",[response objectForKey:@"score"]]];
                likeCountString = [NSString stringWithFormat:@"%@",[response objectForKey:@"score"]];
                [self setupLikeAndCommentLabels];
            }
            UIImage *newImageForLikeButton = [UIImage imageNamed:@"btn_cvp_like_green@2x.png"];
            
            [voteButtonOutlet setImage:newImageForLikeButton forState:UIControlStateNormal];
            
            if ([beaconDetailContentImageDelegate respondsToSelector:@selector(populateBeaconContent)]) {
                [beaconDetailContentImageDelegate populateBeaconContent];
            }
            
        }];
        
    }else if (contentVotedUp) {
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", @"reset", @"type", nil] apiMethod:@"content/vote" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            // deal with response object
            NSLog(@"working %@", response);
            contentVotedUp = NO;
            contentNotVotedYet = YES;
            if ([response objectForKey:@"score"] != nil) {
                likeCountString = [NSString stringWithFormat:@"%@",[response objectForKey:@"score"]];
                [self setupLikeAndCommentLabels];
            }
            UIImage *newImageForLikeButton = [UIImage imageNamed:@"btn_cvp_like@2x.png"];
            
            [voteButtonOutlet setImage:newImageForLikeButton forState:UIControlStateNormal];
            
            if ([beaconDetailContentImageDelegate respondsToSelector:@selector(populateBeaconContent)]) {
                [beaconDetailContentImageDelegate populateBeaconContent];
            }
        }];
        
    }
    
}

- (IBAction)shareButtonPressed:(id)sender
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Attempted to Share an Image"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.contentID forKey:@"content_item"];
    [Flurry logEvent:@"Content_Share_Pressed" withParameters:eventParameters];
    
    PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
    [popupAlert setupWithDescriptionText:@"To share on Facebook, go to settings and connect your account!" andButtonText:@"OK"];
    ShareToFacebookView *shareToFBView = [[[NSBundle mainBundle]loadNibNamed:@"ShareToFacebookView" owner:self options:nil]objectAtIndex:0];
    [shareToFBView setupFBViewWithContentID:contentID];
    
    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    RadiusRequest *radRequest = [RadiusRequest requestWithAPIMethod:@"me"];
    [radRequest startWithCompletionHandler:^(id result, RadiusError *error)
    {
        NSString *fbID = [result objectForKey:@"fb_uid"];
        if (fbID != nil && !([fbID isKindOfClass:[NSNull class]]))
        {
            [MFSlidingView slideView:shareToFBView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        }
        else
        {
            [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        }
    }];
    

}

//- (void)catchTapForView:(UIView *)view {
//    [self resignFirstResponder];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = view.bounds;
//    [button addTarget:self action:@selector(dismissButton:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:button];
//}
//
//- (void)catchTapForNavBar:(UIView *)view {
//    [self resignFirstResponder];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = view.bounds;
//    [button addTarget:self action:@selector(dismissButtonFromNavBar:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:button];
//}

- (IBAction)commentButtonPressed:(id)sender {
    [self postCommentMethod];
}

-(void)imageTapped
{    
    [UIView animateWithDuration:0.4 animations:^{
        if ([topInfoBarView alpha] > 0)
        {
            [topInfoBarView setAlpha:0];
//            [self.navigationController.navigationBar setAlpha:0];
        }
        else
        {
            [self.view bringSubviewToFront:topInfoBarView];
            [topInfoBarView setAlpha:0.8];

//            [self.navigationController.navigationBar setAlpha:1];


        }
        if ([bottomInfoBarView alpha] > 0)
        {
            [bottomInfoBarView setAlpha:0];
        }
        else
        {
            [self.view bringSubviewToFront:bottomInfoBarView];
            [bottomInfoBarView setAlpha:0.8];
        }
    }];
}

-(void) addTapRecognizerToImage
{
    imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
    imageTapRecognizer.cancelsTouchesInView = NO;
    imageTapRecognizer.delegate = self;
    [aiv addGestureRecognizer:imageTapRecognizer];
}

- (void)viewDidLoad
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Looked at a Posted Image"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.contentID forKey:@"content_item"];
    [Flurry logEvent:@"Content_Viewed" withParameters:eventParameters];
    
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    
    [self initializeNameButtons];
    [self setupNameButtons];
    
    
    

    [self initializeLikeAndCommentLabels];
    [self setupLikeAndCommentLabels];
    
    [self initializeDescriptionLabel];
    [self setupDescriptionLabel];
    

    
    [self setupContentSettingsButton];
    
    [self initializeVoteScoreAndButton];
    [self setupVoteScoreAndButton];
    
    [self findIndexOfInitialImage];

    [self setupSwipeGesturesForImage];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self initializeImageViewWithScrollContainer];

        [self setupImageViewWithURL:[NSURL URLWithString:contentString]];
        
    });
    


}

//-(void) setupFrameForTopAndBottomBar {
//    
//    [self.navigationController.navigationBar setAlpha:0];
//    
//    self.topInfoBarView.frame = CGRectMake(self.topInfoBarView.frame.origin.x, self.topInfoBarView.frame.origin.y +44, self.topInfoBarView.frame.size.width, self.topInfoBarView.frame.size.height);
//    self.bottomInfoBarView.frame = CGRectMake(self.bottomInfoBarView.frame.origin.x, self.bottomInfoBarView.frame.origin.y +44, self.bottomInfoBarView.frame.size.width, self.bottomInfoBarView.frame.size.height);
//    self.DetailContentImageView.frame = CGRectMake(self.DetailContentImageView.frame.origin.x, self.DetailContentImageView.frame.origin.y +44, self.DetailContentImageView.frame.size.width, self.DetailContentImageView.frame.size.height);
//}

-(void) initializeDescriptionLabel {
    
    descriptionLabel.font = [UIFont fontWithName:@"Quicksand" size:descriptionLabel.font.pointSize];

}

-(void)setupDescriptionLabel
{
    
    NSString *description = [beaconContentDictionary objectForKey:@"description"];
    if([description isKindOfClass:[NSNull class]]) {
        description = @"";
    }
    descriptionLabel.text = description;
}

-(void) initializeNameButtons {
    
    [nameButton.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:nameButton.titleLabel.font.pointSize]];
    [beaconNameButton.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:beaconNameButton.titleLabel.font.pointSize]];
    [beaconNameButton setTitle:beaconNameString forState:UIControlStateNormal];

    
}

-(void) setupNameButtons
{
    
    DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[beaconContentDictionary objectForKey:@"timestamp"] doubleValue]];
    NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date
    

    [nameButton setTitle:[NSString stringWithFormat:@"%@ posted %@",[[beaconContentDictionary objectForKey:@"poster_o"] objectForKey:@"display_name"], dateString] forState:UIControlStateNormal];

}

- (IBAction)beaconNameLabelPressed:(id)sender
{
    BeaconContentViewController2 *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [demoController initializeWithBeaconID:beaconIDString];
    [self.navigationController pushViewController:demoController animated:YES];
}
- (IBAction)nameLabelPressed:(id)sender
{
    ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
    
    [meProfileController initializeWithUserID:userNameString.integerValue];
    
    [self.navigationController pushViewController:meProfileController animated:YES];
}

-(void) setupContentSettingsButton {
    
    NSString *userIDString1 = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
    
    NSLog(@"%@", userIDString1);
    
    
    if ([userIDString1 isEqualToString:posterIDString] || [userIDString1 isEqualToString:userNameString]) {
        
        [self.contentOwnerSettingsButton setHidden:NO];
        self.currentUserIsContentOwner = YES;
        [self.contentOwnerSettingsButton setUserInteractionEnabled:YES];
        
    }else {
        
        [self.contentOwnerSettingsButton setHidden:NO];
        self.currentUserIsContentOwner = NO;
        [self.contentOwnerSettingsButton setUserInteractionEnabled:YES];


        
    }
    
}

- (IBAction)contentOwnerSettingsButtonPressed:(id)sender {
    
    NSLog(@"content owner settings button pressed");
    ContentCreatorSettingsView *customContentCreatorSettingsViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"ContentCreatorSettingsView" owner:self options:nil]objectAtIndex:0];
    
    [customContentCreatorSettingsViewInstance setContentIDString:contentID];
    
    if (self.currentUserIsContentOwner == YES) {
        [customContentCreatorSettingsViewInstance setUserIsContentCreator:YES];
    }else if (self.currentUserIsContentOwner == NO){
        [customContentCreatorSettingsViewInstance setUserIsContentCreator:NO];
    }else{
        [customContentCreatorSettingsViewInstance setUserIsContentCreator:NO];

    }
    
    [customContentCreatorSettingsViewInstance setupContentCreatorSettingsView];
    [customContentCreatorSettingsViewInstance setBeaconIDString:beaconIDString];
    [customContentCreatorSettingsViewInstance setBeaconNameString:beaconNameString];

    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:customContentCreatorSettingsViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return aiv;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale!=1.0) {
        // Zooming, enable scrolling
        scrollView.scrollEnabled = TRUE;
    } else {
        // Not zoomed, disable scrolling so gestures get used instead
        scrollView.scrollEnabled = FALSE;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
    
}

-(void) setupSwipeGesturesForImage {
    
    if ([imageArray count] > 1) {
        
        UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftOnImage:)];
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeftRecognizer];
        
        UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightOnImage:)];
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeRightRecognizer];
    }
    
}

-(void) findIndexOfInitialImage {
    
    for (int i = 0; i < [imageArray count]; i++) {
        
        
        if ([contentID integerValue] == [[[imageArray objectAtIndex:i]objectForKey:@"id"]integerValue]) {
            initialContentIndex = [NSString stringWithFormat:@"%d", i];
            currentContentIndex = initialContentIndex;
            NSLog(@"%@", initialContentIndex);
        }
    }
    
}

-(void) handleSwipeLeftOnImage: (UISwipeGestureRecognizer *) sender  {
    
    if ([currentContentIndex integerValue] != [imageArray count]-1) {
        
        beaconContentDictionary = [imageArray objectAtIndex:([currentContentIndex integerValue]+1)];
        NSLog(@"%@", beaconContentDictionary);

//        [self initializeImageViewWithScrollContainer];
//        [self initializeBeaconContentImage];
//        [self setupBeaconImage];
        [self handleAnimationWithDirection:@"left"];
        if ([topInfoBarView alpha] > 0) {
            [self imageTapped];

        }

    }else{
        
        [self handleBounceWithDirection:@"left"];
        
    }
    
    
}

-(void) handleSwipeRightOnImage: (UISwipeGestureRecognizer *) sender {

    if ([currentContentIndex integerValue] != 0) {
        
        beaconContentDictionary = [imageArray objectAtIndex:([currentContentIndex integerValue]-1)];
        NSLog(@"%@", beaconContentDictionary);

//        [self initializeImageViewWithScrollContainer];
//        [self initializeBeaconContentImage];
//        [self setupBeaconImage];
        [self handleAnimationWithDirection:@"right"];
        if ([topInfoBarView alpha] > 0) {
            [self imageTapped];
            
        }


    }else{
        
        [self handleBounceWithDirection:@"right"];
        
    }
    


}

-(void) handleAnimationWithDirection: (NSString *) direction{
    
    if ([direction isEqualToString:@"left"]) {

        [self.view addSubview:currentImageView];
        aiv.hidden = YES;
        
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                            
                             currentImageView.transform = CGAffineTransformIdentity;
                             currentImageView.frame = CGRectMake(-currentImageView.frame.size.width, currentImageView.frame.origin.y, currentImageView.frame.size.width, currentImageView.frame.size.height);
                             
                             
                         }completion:^(BOOL finished) {
                             
                             currentImageView = nil;
                             [self initializeImageViewWithScrollContainer];
                             [self initializeBeaconContentImage];
                             [self setupBeaconImage];
                             
                         }];
    }else if ([direction isEqualToString:@"right"]) {
        
        [self.view addSubview:currentImageView];
        aiv.hidden = YES;


        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             
                             currentImageView.transform = CGAffineTransformIdentity;
                             currentImageView.frame = CGRectMake(320, currentImageView.frame.origin.y, currentImageView.frame.size.width, currentImageView.frame.size.height);
                             
                             
                         }completion:^(BOOL finished) {
                             
                             currentImageView = nil;
                             [self initializeImageViewWithScrollContainer];
                             [self initializeBeaconContentImage];
                             [self setupBeaconImage];

                             
                         }];
        
        
    }
    
    
}

-(void) handleBounceWithDirection: (NSString *)direction{


    
}


#pragma mark Apple Methods

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
    [self setDetailContentImageView:nil];
    [self setBeaconImageCommentTableViewOutlet:nil];
    [self setNameButton:nil];
    [self setBeaconNameButton:nil];
    [self setTopInfoBarView:nil];
    [self setLikeCountLabel:nil];
    [self setCommentCountLabel:nil];
    [self setBottomInfoBarView:nil];
    [self setDescriptionLabel:nil];
    [self setContentOwnerSettingsButton:nil];
    [self setLikeView:nil];
    [self setCommentView:nil];
    [super viewDidUnload];
}




@end
