//
//  BeaconDetailContentViewController.m
//  Radius
//
//  Created by Hud on 8/2/12.
//
//

#import "BeaconDetailContentViewController.h"

@interface BeaconDetailContentViewController () <FindCommentsDelegate, PostContentCommentDelegate, PostContentViewDelegate>

@end

@implementation BeaconDetailContentViewController
@synthesize commentTextField;
@synthesize contentWebView;
@synthesize contentTextLabel;
@synthesize contentImageView;
@synthesize profilePictureButton;
@synthesize voteOnCommentButtonOutlet;
@synthesize contentVoteScoreLabel;
@synthesize jsonArray, beaconContentDictionary;
@synthesize contentString;
@synthesize contentType;
@synthesize commentTableView;
@synthesize contentID;
@synthesize animatedDistance;
@synthesize userTokenString, userNameString;
@synthesize responseDictionary, responseArray;
@synthesize contentNotVotedYet, contentVotedDown, contentVotedUp;
@synthesize contentVoteScore;


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;




-(void) postCommentOnContent {
    
    SlidingCommentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"SlidingCommentView" owner:self options:nil]objectAtIndex:0];

    
//    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleTapRecognizer];
//
//    UITapGestureRecognizer *navBarBlocker = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [self.navigationController.navigationBar addGestureRecognizer:navBarBlocker];
    
    SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
//        [self.view removeGestureRecognizer:singleTapRecognizer];
//        [self.navigationController.navigationBar removeGestureRecognizer:navBarBlocker];

        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:customView intoView:self.view onScreenPosition:RightOfScreen offScreenPosition:RightOfScreen title:@"Post Comment" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
}

- (IBAction)contentCreatorProfileButton:(id)sender {
    
    ProfileViewController2 *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"meProfileViewID"];
    
    [newViewController initializeWithUserID:[userNameString integerValue]];

    [self.navigationController pushViewController:newViewController animated:YES];
    
}

- (IBAction)voteOnContentButtonPressed:(id)sender {
    
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"What Do You Think Of This Post?" delegate:self
                                  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                  otherButtonTitles:@"Like!", @"Dislike!",
                                  nil];
    [actionSheet showInView:self.view];

    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
        
        
        
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"OK"]==NO) {
    
    
    if ((contentVotedUp == NO && contentVotedDown == YES) || contentNotVotedYet == YES) {
        
        if ([buttonTitle isEqualToString:@"Like!"]) {
            contentVotedUp = YES;
            contentNotVotedYet = NO;
            contentVotedDown = NO;
            RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", userTokenString, @"token", @"up", @"type", nil] apiMethod:@"content/vote" httpMethod:@"POST"];
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                
                // deal with response object
                NSLog(@"the vote was %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                    [voteOnCommentButtonOutlet setTitle:@"Voted Up" forState:UIControlStateNormal];
                    NSString *newMath = [NSString stringWithFormat:@"%@", [responseDictionary objectForKey:@"score"]];
                    
                    contentVoteScore = newMath;
                    NSString *newLabel = [NSString stringWithFormat:@"%@", contentVoteScore];
                    contentVoteScoreLabel.text = newLabel;
                    
                }
                
            }];
        }
        
    }
    if ((contentVotedUp == YES && contentVotedDown == NO) || contentNotVotedYet == YES) {
        
        if ([buttonTitle isEqualToString:@"Dislike!"]) {
            contentVotedDown = YES;
            contentNotVotedYet = NO;
            contentVotedUp = NO;
            RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentID, @"content_id", userTokenString, @"token", @"down", @"type", nil] apiMethod:@"content/vote" httpMethod:@"POST"];
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                
                // deal with response object
                NSLog(@"the vote was %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                    NSString *newMath = [NSString stringWithFormat:@"%@", [responseDictionary objectForKey:@"score"]];

                    contentVoteScore = newMath;
                    NSString *newLabel = [NSString stringWithFormat:@"%@", contentVoteScore];
                    contentVoteScoreLabel.text = newLabel;
                    [voteOnCommentButtonOutlet setTitle:@"Voted Down" forState:UIControlStateNormal];

                    
                }
                
            }];
        }
        
    }
    }
    
}

-(void)commentPosted {
    
//    UIAlertView *commentPostedAlert = [[UIAlertView alloc] initWithTitle:@"comment posted" message:@"comment posted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [commentPostedAlert show];
    
    commentTextField.text = nil;
    [self findCommentsContent:contentID];
    
    
}

-(void) findCommentsContent: (NSString *) myContentID {
    
    if (myContentID != nil){
        
        FindComments *comments =[[FindComments alloc] init];
        comments.findCommentsDelegate = self;
        [comments findCommentsMethod:myContentID];
    }
    
}

-(void)populateCommentsTable:(NSMutableArray *)myArray {
    
    NSLog(@"posting comments in table");
    self.jsonArray = myArray;
    if (jsonArray != nil) {
        [commentTableView reloadData];
        
        
        
    }else {
        
        [self findCommentsContent:contentID];
        
    }
    
}

-(void)findContentAuthor {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: userNameString, @"user", nil] apiMethod:@"userinfo" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        // deal with response object
        NSLog(@"the content author %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseArray = response;
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseDictionary = response;
            NSURL *imageURL = [NSURL URLWithString:[responseDictionary objectForKey:@"picture"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *profilePicture = [UIImage imageWithData:imageData];
            [profilePictureButton setImage:profilePicture forState:UIControlStateNormal];
        }
        
        [MFSlidingView slideOut];
        
    }];

    
}

-(void)reloadBeaconContentDataTable {
    
    [self findCommentsContent:contentID];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    
    return [jsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    if ([[jsonArray objectAtIndex:indexPath.row] objectForKey:@"text"] != nil) {
        cell.textLabel.text = [[jsonArray objectAtIndex:indexPath.row] objectForKey:@"text"];
        cell.detailTextLabel.text = [[jsonArray objectAtIndex:indexPath.row] objectForKey:@"display_name"];
        
    }
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.commentTextField) {
        [theTextField resignFirstResponder];
    }

    return YES;
}

//Handle single taps such that they hide the keyboard
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

// Code to move the view focus down with each text field
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleTapRecognizer];
//    
//    
//    CGRect textFieldRect =
//    [self.view.window convertRect:textField.bounds fromView:textField];
//    CGRect viewRect =
//    [self.view.window convertRect:self.view.bounds fromView:self.view];
//    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
//    CGFloat numerator =
//    midline - viewRect.origin.y
//    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
//    CGFloat denominator =
//    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
//    * viewRect.size.height;
//    CGFloat heightFraction = numerator / denominator;
//    if (heightFraction < 0.0)
//    {
//        heightFraction = 0.0;
//    }
//    else if (heightFraction > 1.0)
//    {
//        heightFraction = 1.0;
//    }
//    UIInterfaceOrientation orientation =
//    [[UIApplication sharedApplication] statusBarOrientation];
//    if (orientation == UIInterfaceOrientationPortrait ||
//        orientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
//        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
//    }
//    else
//    {
//        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
//    }
//    CGRect viewFrame = self.view.frame;
//    viewFrame.origin.y -= animatedDistance;
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//    
//    [self.view setFrame:viewFrame];
//    
//    [UIView commitAnimations];
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
//    CGRect viewFrame = self.view.frame;
//    viewFrame.origin.y += animatedDistance;
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//    
//    [self.view setFrame:viewFrame];
//    
//    [UIView commitAnimations];
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    NSLog(@"%@", userNameString);

    
//    [self setupSideMenuBarButtonItem];
	// Do any additional setup after loading the view.
    [self findCommentsContent:contentID];
    [self setupSideMenuBarButtonItem];
    [self findContentAuthor];
    
    if (contentNotVotedYet==YES) {
        [voteOnCommentButtonOutlet setTitle:@"Vote on Content" forState:UIControlStateNormal];
    }else if (contentVotedDown==YES) {
        [voteOnCommentButtonOutlet setTitle:@"Voted Down" forState:UIControlStateNormal];
    }else if (contentVotedUp==YES) {
        [voteOnCommentButtonOutlet setTitle:@"Voted Up" forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *addPostButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postCommentOnContent)];
    [self.navigationItem setRightBarButtonItem:addPostButton animated:YES];

    
    contentTextLabel.text = contentString;
    if (contentType == @"image") {
        NSString *urlAddress=contentString;
        NSLog(@"%@", urlAddress);
        NSURL *actualURL = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestURLObject = [NSURLRequest requestWithURL:actualURL];
        [contentWebView loadRequest:requestURLObject];
        NSLog(@"loading image");
    }else if (contentType == @"video_ext") {
        NSString *urlAddress= [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", contentString];
        NSLog(@"%@", urlAddress);
        NSURL *actualURL = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestURLObject = [NSURLRequest requestWithURL:actualURL];
        [contentWebView loadRequest:requestURLObject];
        NSLog(@"loading video");
    }
    NSString *newLabel = [NSString stringWithFormat:@"%@", contentVoteScore];
    contentVoteScoreLabel.text = newLabel;
    
    
    
//    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleTapRecognizer];
    
    
    
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
    [self setContentTextLabel:nil];
    [self setContentImageView:nil];
    [self setContentWebView:nil];
    [self setCommentTableView:nil];
    [self setCommentTextField:nil];
    [self setProfilePictureButton:nil];
    [self setVoteOnCommentButtonOutlet:nil];
    [self setContentVoteScoreLabel:nil];
    [super viewDidUnload];
}

@end
