//
//  ConvoThreadViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 9/6/12.
//
//

#import "ConvoThreadViewController.h"
#import "SlidingTableView.h"
#import "MFSideMenu.h"
#import "Flurry.h"

@interface ConvoThreadViewController () <PostContentViewDelegate>{
    
    BOOL alreadyPostingReply;

}
//@property (nonatomic) NSInteger threadDepth;
@property (nonatomic) NSMutableArray *threadArray;
@property (nonatomic) NSArray *repliesArray;

@end

@implementation ConvoThreadViewController
//@synthesize threadDepth = _threadDepth;
@synthesize threadArray = _threadArray;
@synthesize convoThreadTable;
@synthesize animatedDistance;
@synthesize responseArray, responseDictionary, userTokenString;
@synthesize repliesArray = _repliesArray;
@synthesize threadID = _threadID;
@synthesize beaconID = _beaconID;
@synthesize beaconName = _beaconName;
@synthesize convoTableIsEditing, indexPathToEditingCell, tapToStopEditingTapGestureRecognizer;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static const CGFloat DELETE_CONVO_BUTTON_TAG = 1000;
static const CGFloat ASYC_IMAGE_TAG = 537;
static const CGFloat PROFILE_BUTTON_TAG = 2000;



static const NSInteger TITLE_BUTTON_TAG = 4390;


static NSString * const REPLY_PLACEHOLDER = @"reply to this thread...";

NSMutableDictionary *imageCacheDictionary;


//-(NSInteger)threadDepth
//{
//    _threadDepth = [self findDepthOfThreadDict:threadDict atCurrLevel:0];
//    return _threadDepth;
//}
-(id)repliesArray
{
    if (!_repliesArray) _repliesArray = [threadDict objectForKey:@"replies"];
    return _repliesArray;
}

//-(NSMutableArray *)threadArray
//{
//    if (!_threadArray)
//    {
//
//    }
//
//        return _threadArray;
//}

//-(id)initWithThreadDict:(NSDictionary *)threadDictionary andBeaconID:(NSInteger)sendingBeaconID
//{
//    self = [super init];
//    if (self) {
//        self.threadDict = threadDictionary;
//        self.beaconID = sendingBeaconID;
//    }
//    return self;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)initializeWithThreadID:(NSInteger)threadID threadTitle:(NSString *)threadTitle beaconName:(NSString *)beaconName beaconID:(NSInteger)beaconID {
    // Set up navigation bar (clicking should go to beacon)
    self.title = beaconName;
    
    self.threadID = threadID;
    self.threadTitle = threadTitle;
    
    self.beaconName = beaconName;
    self.beaconID = beaconID;

}

- (void) clickedTitle:(id)sender
{
    // Push beacon view controller unless you came from the same one
    
    UINavigationController *lastController = self.navigationController.viewControllers.count > 1?[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]:nil;
    if([lastController isKindOfClass:[BeaconContentViewController2 class]] && [[(BeaconContentViewController2*)lastController sendingBeaconID] integerValue] == self.beaconID) {
        return;
    }
    
    
    BeaconContentViewController2 *beaconViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    
    [beaconViewController initializeWithBeaconID:[NSString stringWithFormat:@"%d",self.beaconID]];
    
    [self.navigationController pushViewController:beaconViewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    [self reloadConversationTable];
    
    UIImage *img = [UIImage imageNamed:@"iphone5_menubkgd@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    
    
    backgroundNotificationsView.alpha = 0.4;
    backgroundNotificationsView.frame = self.view.frame;
    
    [self.view addSubview:backgroundNotificationsView];
    [self.view sendSubviewToBack:backgroundNotificationsView ];
    
    self.convoThreadTable.backgroundColor = [UIColor clearColor];
    
//    [self.convoThreadTable setBackgroundView:backgroundNotificationsView];
//    self.convoThreadTable.backgroundView.contentMode = UIViewContentModeTop;
    
    self.titleLabel.text = [NSString stringWithFormat:@"What's happening?"];
//    self.titleLabel.text = self.threadTitle;
    self.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17.0];
    self.titleLabel.opaque = NO;
    self.titleLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    self.titleLabel.textColor = [UIColor whiteColor];
    
    convoTableIsEditing = NO;
    [self setupDismissCellEditing];

    alreadyPostingReply = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Reply to thread cell at the end
    if (indexPath.row == ([self.repliesArray count]+1))
    {
        
        //        PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
        //        customView.postTextContentTextView.text = @"Post Text Here";
        //        customView.postSendingBeaconID = self.beaconID;
        //        customView.postContentType = @"text";
        //        customView.postContentViewDelegate =self;
        //        customView.postSendingContentID = [[self getConvoDictAtDepth:(self.threadDepth-1)] objectForKey:@"id"];
        //        customView.userTask = @"PostConversation";
        //        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        //        [self.view addGestureRecognizer:singleTapRecognizer];
        //        [customView addGestureRecognizer:singleTapRecognizer];
        //
        //        SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
        //        void (^cancelOrDoneBlock)() = ^{
        //            // we must manually slide out the view out if we specify this block
        //            [MFSlidingView slideOut];
        //            [customView.descriptionTextField resignFirstResponder];
        //
        //        };
        //
        //        [MFSlidingView slideView:customView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Post Text" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    }
    //Take to author's Me page
    else
    {
//        NSLog(@"%@",[self getConvoPostItemAtIndex:indexPath]);
//        
//        ProfileViewController2 *newProfileViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
//        
//        [newProfileViewControllerInstance initializeWithUserID:[[[[self getConvoPostItemAtIndex:indexPath] objectForKey:@"poster_o"]objectForKey:@"id"] integerValue]];
//
//        [self.navigationController pushViewController:newProfileViewControllerInstance animated:YES];
        
        
    }
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

-(void)reloadConversationTable
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.threadID], @"thread", nil] apiMethod:@"conversation/thread"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        NSLog(@"reloaded conversation is: %@", response);
        threadDict = response;
        self.repliesArray = [threadDict objectForKey:@"replies"];
//        [self.convoThreadTable numberOfRowsInSection:[[threadDict objectForKey:@"replies"]count]+2];
        [convoThreadTable reloadData];
        [self setupDeleteThreadButton];

    }];
}

-(NSDictionary *)getConvoPostItemAtIndex:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return threadDict;
    }
    else //if (indexPath.row<[self.repliesArray count])
    {
        return [self.repliesArray objectAtIndex:(indexPath.row-1)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //last cell
    //if (indexPath.row == [tableView numberOfRowsInSection:0])
    //Plus one because we now have the thread title at the top, replies one index further, and then this
    if (indexPath.row == ([self.repliesArray count]+1))
    {
        static NSString *replyCellIdentifier = @"replyCellIdentifier";
        UITableViewCell *replyCell = [tableView dequeueReusableCellWithIdentifier:replyCellIdentifier];
        replyCell = nil;
        if (replyCell == nil){
            replyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                               reuseIdentifier:replyCellIdentifier];
            
        }
        
        replyCell.textLabel.text =nil;
        replyCell.detailTextLabel.text = nil;
        NSString *label = REPLY_PLACEHOLDER;

//        CGSize stringSize = [label sizeWithFont:[UIFont boldSystemFontOfSize:15]
//                              constrainedToSize:CGSizeMake(320, 9999)
//                                  lineBreakMode:UILineBreakModeWordWrap];
        
        UITextView *textV=[[UITextView alloc] initWithFrame:CGRectMake(replyCell.frame.origin.x, replyCell.frame.origin.y, tableView.frame.size.width, 75)];
        textV.text=label;
        textV.textColor=[UIColor blackColor];
        textV.editable=YES;
        textV.keyboardType = UIKeyboardTypeASCIICapable;
        textV.returnKeyType = UIReturnKeySend;
        textV.font = [UIFont fontWithName:@"Quicksand" size:15.0];
        textV.textColor = [UIColor grayColor];
        textV.backgroundColor = [UIColor whiteColor];
        
        
        textV.delegate = self;
        //        [cell.contentView addSubview:textV];
        [replyCell.contentView addSubview:textV];
        replyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return replyCell;
    }
    else
    {
        static NSString *CellIdentifier = @"MyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:15.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        UIView *oldImageView = [cell viewWithTag:ASYC_IMAGE_TAG];
        [oldImageView removeFromSuperview];
        
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryView = nil;
        cell.indentationLevel = 0;
        
        cell.textLabel.text = [[self getConvoPostItemAtIndex:indexPath] objectForKey:@"text"];
        
        DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[[self getConvoPostItemAtIndex:indexPath] objectForKey:@"timestamp"] doubleValue]];
        NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date
        
        NSString *displayNameString = [[[self getConvoPostItemAtIndex:indexPath] objectForKey:@"poster_o"]objectForKey:@"display_name"];
        
        if (indexPath.row == 0) {
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ said %@", displayNameString, dateString];
        }else {
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ replied %@", displayNameString, dateString];
        }
        
        cell.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        cell.detailTextLabel.numberOfLines = 0;

        
        NSMutableString *urlString = [[[self getConvoPostItemAtIndex:indexPath] objectForKey:@"poster_o"]objectForKey:@"picture_thumb"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if(!imageCacheDictionary) {
            imageCacheDictionary = [[NSMutableDictionary alloc] init];
        }
        
            AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, 5, 55, 55) imageURL:url cache:imageCacheDictionary loadImmediately:YES];
            asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
            asyncImageViewInstance.layer.cornerRadius = 5;
            asyncImageViewInstance.layer.masksToBounds = YES;
            UIButton *profileButton = [[UIButton alloc] initWithFrame:asyncImageViewInstance.frame];
            [profileButton addTarget:self action:@selector(goToProfile:) forControlEvents:UIControlEventTouchUpInside];
            profileButton.tag = PROFILE_BUTTON_TAG;
            [asyncImageViewInstance addSubview:profileButton];
            
            if(indexPath.row%2) {
                UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width-60,
                                                                            0,
                                                                            60,
                                                                            cell.frame.size.height)];
                
                UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                     0,
                                                                                     60,
                                                                                     cell.frame.size.height)];
                [profileButton addTarget:self action:@selector(goToProfile:) forControlEvents:UIControlEventTouchUpInside];
                [blankView addSubview:profileButton];
                cell.accessoryView = blankView;
    //            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                asyncImageViewInstance.frame = CGRectOffset(asyncImageViewInstance.frame, cell.frame.size.width-65, 0);
                if ([cell viewWithTag:ASYC_IMAGE_TAG]) {
                    [[cell viewWithTag:ASYC_IMAGE_TAG]removeFromSuperview];
                }
                [cell addSubview:asyncImageViewInstance];
                
                UIButton *deleteConvoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                [deleteConvoPostButton addTarget:self action:@selector(deleteConvoPost:) forControlEvents:UIControlEventTouchUpInside];
                [deleteConvoPostButton setImage:[UIImage imageNamed:@"btn_close_black@2x.png"] forState:UIControlStateNormal];
                [deleteConvoPostButton setTag:DELETE_CONVO_BUTTON_TAG];
                deleteConvoPostButton.alpha = 0;
                deleteConvoPostButton.userInteractionEnabled = NO;
                [cell addSubview:deleteConvoPostButton];
                
            }else {
                cell.indentationWidth = asyncImageViewInstance.frame.size.width + 5;
                cell.indentationLevel = 1;
                if ([cell viewWithTag:ASYC_IMAGE_TAG]) {
                    [[cell viewWithTag:ASYC_IMAGE_TAG]removeFromSuperview];
                }
                [cell addSubview:asyncImageViewInstance];
                
                UIButton *deleteConvoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
                [deleteConvoPostButton addTarget:self action:@selector(deleteConvoPost:) forControlEvents:UIControlEventTouchUpInside];
                [deleteConvoPostButton setImage:[UIImage imageNamed:@"btn_close_black@2x.png"] forState:UIControlStateNormal];
                [deleteConvoPostButton setTag:DELETE_CONVO_BUTTON_TAG];
                deleteConvoPostButton.alpha = 0;
                deleteConvoPostButton.userInteractionEnabled = NO;
                [cell addSubview:deleteConvoPostButton];
            }
        
        UISwipeGestureRecognizer *swipeLeftToDeleteConvoPost = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteThreadButton:)];
        [swipeLeftToDeleteConvoPost setDelegate:self];
        [swipeLeftToDeleteConvoPost setDirection:UISwipeGestureRecognizerDirectionLeft];
        [cell addGestureRecognizer:swipeLeftToDeleteConvoPost];
        
        UISwipeGestureRecognizer *swipeRightToDeleteConvoPost = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteThreadButton:)];
        [swipeRightToDeleteConvoPost setDelegate:self];
        [swipeRightToDeleteConvoPost setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:swipeRightToDeleteConvoPost];
    
        
        return cell;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Plus one because threadDepth = 0 for just one post, one respond cell at the end
    if(!self.repliesArray) {
        return 0;
    }
    return [self.repliesArray count] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //For the reply field
    NSLog(@"%d", indexPath.row);
    if (indexPath.row == ([self.repliesArray count]+1))
    {
        return 75;
    }
    else
    {
        NSString *cellText = [[self getConvoPostItemAtIndex:indexPath] objectForKey:@"text"];
        UIFont *cellFont = [UIFont fontWithName:@"Quicksand" size:15.0];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height +50;
    }
}

//-(NSInteger)findDepthOfThreadDict:(NSDictionary *)currChildDict atCurrLevel:(NSInteger)currLevel
//{
//    if ([[currChildDict objectForKey:@"children"] count] > 0)
//    {
//        return [self findDepthOfThreadDict:[[currChildDict objectForKey:@"children"] objectAtIndex:0] atCurrLevel:(currLevel+1)];
//    }
//    else
//    {
//        return currLevel+1;
//    }
//}

-(NSDictionary *)getConvoDictAtDepth:(NSInteger)postDepth
{
    if (threadDict)
    {
        NSInteger depthToGo = postDepth;
        NSDictionary *currDict = [threadDict copy];
        while (depthToGo > 0)
        {
            currDict = [[currDict objectForKey:@"children"] objectAtIndex:0];
            depthToGo--;
        }
        return currDict;
    }
    return nil;
}

-(void) goToProfile: (id)sender {
    
    [MFSlidingView slideOut];
    
    UITableViewCell *owningCell = (UITableViewCell*)[[sender superview]superview];
    NSIndexPath *pathToCell = [convoThreadTable indexPathForCell:owningCell];
    
    NSLog(@" omgz button pressed row at %d", pathToCell.row);
    
    ProfileViewController2 *newProfileViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
    
    [newProfileViewControllerInstance initializeWithUserID:[[[[self getConvoPostItemAtIndex:pathToCell] objectForKey:@"poster_o"]objectForKey:@"id"] integerValue]];
    
    [self.navigationController pushViewController:newProfileViewControllerInstance animated:YES];
    
    //    UIViewController *myViewControllerToPush = [self firstAvailableUIViewController];
    //
    //    [myViewControllerToPush.navigationController pushViewController:newViewController animated:YES];
    
    
    
    
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapForTextView:)];
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
    if ([textView.text isEqualToString:REPLY_PLACEHOLDER]) {
        [textView setText:@""];
        textView.textColor = [UIColor blackColor];
    }
    
    CGRect textFieldRect =
    [self.view.window convertRect:textView.bounds fromView:textView];
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
    
    NSLog(@"self editing");
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        [textView setText:REPLY_PLACEHOLDER];
        textView.textColor = [UIColor grayColor];
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        if (!alreadyPostingReply) {
            
            
#ifdef CONFIGURATION_TestFlight
            [TestFlight passCheckpoint:@"Replied to a Conversation Thread"];
#endif
            NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",self.threadID] forKey:@"thread"];
            [Flurry logEvent:@"Conversation_Replied" withParameters:eventParameters];
            
            if (textView.text.length != 0 && ![textView.text isEqualToString:@"Post Conversation Here"]) {
                
                RadiusRequest *r;
                r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.threadID], @"thread", textView.text, @"text", nil] apiMethod:@"conversation/reply" httpMethod:@"POST"];
                
                alreadyPostingReply = YES;
                
                [r startWithCompletionHandler:^(id response, RadiusError *error) {
                    
                    // deal with response object
                    if ([response isKindOfClass:[NSArray class]]) {
                        responseArray = response;
                    }else if ([response isKindOfClass:[NSDictionary class]]){
                        
                        responseDictionary = response;
                    }
                    
                    [textView resignFirstResponder];
                    
                    [self reloadConversationTable];
                    alreadyPostingReply = NO;
                    
                    
                }];
            }
            
        }

        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}
-(void)handleSingleTapForTextView:(UITapGestureRecognizer *)sender
{
    NSLog(@"Tapped");
    //    [[[[[self.convoTable cellForRowAtIndexPath:0] contentView] subviews] lastObject] endEditing:YES];
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
}



- (void)viewDidUnload {
    [self setConvoThreadTable:nil];
    [self setTitleLabel:nil];
    [self setDeleteThreadButtonOutlet:nil];
    [super viewDidUnload];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50,0,self.navigationController.navigationBar.frame.size.width-100,self.navigationController.navigationBar.frame.size.height)];
    [button addTarget:self action:@selector(clickedTitle:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    button.tag = TITLE_BUTTON_TAG;
    [self.navigationController.navigationBar addSubview:button];

}

-(void)viewWillDisappear:(BOOL)animated {
    UIView *button = [self.navigationController.navigationBar viewWithTag:TITLE_BUTTON_TAG];
    [button removeFromSuperview];
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor clearColor],
                                                                     UITextAttributeTextColor,
                                                                     [UIColor whiteColor],
                                                                     UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                                     UITextAttributeTextShadowOffset,
                                                                     [UIFont fontWithName:@"QuicksandBold-Regular" size:20.0],
                                                                     UITextAttributeFont,
                                                                     nil]];
}

#pragma mark Delete Reply Methods

-(void) revealDeleteThreadButton: (UISwipeGestureRecognizer *)sender {
    

    
    if (sender.state == UIGestureRecognizerStateEnded && convoTableIsEditing == NO) {
        
        convoTableIsEditing = YES;

        
        CGPoint swipeLocation = [sender locationInView:self.convoThreadTable];
        indexPathToEditingCell = [self.convoThreadTable indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.convoThreadTable cellForRowAtIndexPath:indexPathToEditingCell];
        NSDictionary *myThreadDictionary = [self getConvoPostItemAtIndex:indexPathToEditingCell];
        NSString *convoPostAuthor = [NSString stringWithFormat:@"%@",[myThreadDictionary objectForKey:@"poster"]];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *theCurrentUserID = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"id"]];
        
        if ([theCurrentUserID isEqualToString:convoPostAuthor] && indexPathToEditingCell.row != 0) {
            
        
    
            [UIView animateWithDuration:0.4
                                  delay:0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^ {

                                 swipedCell.textLabel.alpha = 0.5;
                                 swipedCell.detailTextLabel.alpha = 0.5;
                                 [[swipedCell viewWithTag:ASYC_IMAGE_TAG] setAlpha:0.5];
                                 [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setAlpha:1];
                                 
                             }completion:^(BOOL finished) {
                                 
                                 [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setUserInteractionEnabled:YES];
                                 [[[swipedCell viewWithTag:ASYC_IMAGE_TAG]viewWithTag:PROFILE_BUTTON_TAG]setUserInteractionEnabled:NO];
                                 NSLog(@"%@", [[swipedCell viewWithTag:ASYC_IMAGE_TAG]viewWithTag:PROFILE_BUTTON_TAG]);
                                 tapToStopEditingTapGestureRecognizer.enabled = YES;
                                 self.convoThreadTable.scrollEnabled = NO;


                             }];
    
        }
        
    }else
        return;
}

-(void) setupDismissCellEditing {
    
    tapToStopEditingTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopTableEditing:)];
    tapToStopEditingTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapToStopEditingTapGestureRecognizer];
    
}

-(void) stopTableEditing: (UITapGestureRecognizer *) sender {
        
    if (sender.state == UIGestureRecognizerStateEnded && convoTableIsEditing == YES && indexPathToEditingCell != nil) {
        
        UITableViewCell* swipedCell = [self.convoThreadTable cellForRowAtIndexPath:indexPathToEditingCell];
            

            [UIView animateWithDuration:0.4
                                  delay:0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^ {
                                 
                                 swipedCell.textLabel.alpha = 1;
                                 swipedCell.detailTextLabel.alpha = 1;
                                 [[swipedCell viewWithTag:ASYC_IMAGE_TAG] setAlpha:1];
                                 [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setAlpha:0];
                                 
                             }completion:^(BOOL finished) {
                                 
                                 [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setUserInteractionEnabled:NO];
                                 [[[swipedCell viewWithTag:ASYC_IMAGE_TAG]viewWithTag:PROFILE_BUTTON_TAG]setUserInteractionEnabled:YES];
                                 convoTableIsEditing = NO;
                                 tapToStopEditingTapGestureRecognizer.enabled = NO;
                                 self.convoThreadTable.scrollEnabled = YES;
                                 indexPathToEditingCell = nil;
                                 
                             }];
            
    }else
        return;

    
}


-(void) deleteConvoPost: (id) sender {
    
    if (indexPathToEditingCell != nil) {
        NSDictionary *myThreadDictionary = [self getConvoPostItemAtIndex:indexPathToEditingCell];
        NSLog(@"%@", myThreadDictionary);
        NSLog(@"%@", [myThreadDictionary objectForKey:@"id"]);
        NSString *postToDeleteID = [NSString stringWithFormat:@"%@", [myThreadDictionary objectForKey:@"id"]];
        
        RadiusRequest *r;
        r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: postToDeleteID, @"post", nil] apiMethod:@"conversation/reply/delete" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
            
                NSLog(@"working on creating thread, response is: %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
            
                UITableViewCell* swipedCell = [self.convoThreadTable cellForRowAtIndexPath:indexPathToEditingCell];
                
                
                [UIView animateWithDuration:0.4
                                      delay:0
                                    options:UIViewAnimationCurveEaseInOut
                                 animations:^ {
                                     
                                     swipedCell.textLabel.alpha = 1;
                                     swipedCell.detailTextLabel.alpha = 1;
                                     [[swipedCell viewWithTag:ASYC_IMAGE_TAG] setAlpha:1];
                                     [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setAlpha:0];
                                     
                                 }completion:^(BOOL finished) {
                                     
                                     [[swipedCell viewWithTag:DELETE_CONVO_BUTTON_TAG] setUserInteractionEnabled:NO];
                                     convoTableIsEditing = NO;
                                     tapToStopEditingTapGestureRecognizer.enabled = NO;
                                     self.convoThreadTable.scrollEnabled = YES;
                                     indexPathToEditingCell = nil;
                                     [self reloadConversationTable];

                                 }];
            }else {
                
                NSLog(@"%@", error);
                
            }
            
            
            
        }];
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[otherGestureRecognizer class]]) {
        return NO;
    }else
        return YES;
    
}

#pragma mark Delete Thread Methods

-(void) setupDeleteThreadButton {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *theCurrentUserID = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"id"]];
    
    if ([theCurrentUserID isEqualToString:[NSString stringWithFormat:@"%@", [threadDict objectForKey:@"poster"]]]) {
        
        self.deleteThreadButtonOutlet.userInteractionEnabled = YES;
        self.deleteThreadButtonOutlet.hidden = NO;
        
    }
    
}

- (IBAction)deleteThreadButtonPressed:(id)sender {
    
    ThreadCreatorSettingsView *threadCreatorSettingsViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"ThreadCreatorSettingsView" owner:self options:nil]objectAtIndex:0];
    
    [threadCreatorSettingsViewInstance setThreadID:[threadDict objectForKey:@"id"]];
    
    [threadCreatorSettingsViewInstance setupThreadCreatorSettingsView];
    [threadCreatorSettingsViewInstance setBeaconIDString:[threadDict objectForKey:@"beacon"]];
    [threadCreatorSettingsViewInstance setBeaconNameString:self.beaconName];

    
    
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:threadCreatorSettingsViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
    
}

@end
