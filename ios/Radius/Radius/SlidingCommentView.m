//
//  SlidingCommentView.m
//  radius
//
//  Created by Hud on 9/6/12.
//
//

#import "SlidingCommentView.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "NotificationsFind.h"
#import "ProfileViewController2.h"

@implementation SlidingCommentView
@synthesize VoteButtonOutlet;
@synthesize CommentScoreLabelOutlet;
@synthesize SlidingCommentTableViewOutlet;
@synthesize AddCommentTextFieldOutlet;
@synthesize sendingSlidingContentID;
@synthesize postContentType, postSendingBeaconID, postSendingContentID, userTask, userTokenString;
@synthesize responseArray, responseDictionary;
@synthesize contentVotedUp, contentVotedDown, contentNotVotedYet;
@synthesize tapToDismissGestureRecognizer;
@synthesize slidingCommentDelegate;
@synthesize commentTableIsEditing, indexPathToEditingCell, tapToStopEditingTapGestureRecognizer;

NSMutableDictionary *imageCacheDictionary;

static const CGFloat DELETE_CONVO_BUTTON_TAG = 1000;
static const CGFloat ASYC_IMAGE_TAG = 537;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setupDismissCellEditing {
    
    tapToStopEditingTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopTableEditing:)];
    tapToStopEditingTapGestureRecognizer.enabled = NO;
    [self addGestureRecognizer:tapToStopEditingTapGestureRecognizer];
    
}

- (IBAction)AddCommentButtonPressed:(id)sender {
    
    [self postCommentMethod];
    
}

- (void) postCommentMethod {
    
    if (userTask == @"PostComment")
    {

        if (AddCommentTextFieldOutlet.text.length != 0) {
            
            
            NSLog(@"comment text is: %@", AddCommentTextFieldOutlet.text);
            NSLog(@"comment posted to this id content: %@", postSendingContentID);
            
            RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: AddCommentTextFieldOutlet.text, @"text",postSendingContentID, @"content_id", nil] apiMethod:@"comment" httpMethod:@"POST"];
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                
                [MFSlidingView slideOut];
                
                UIViewController *myController = [self firstAvailableUIViewController];
                
                PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:myController.view options:nil] objectAtIndex:0];
                [popupAlert setupWithDescriptionText:@"Comment posted!" andButtonText:@"OK"];
                SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                
                void (^cancelOrDoneBlock)() = ^{
                    // we must manually slide out the view out if we specify this block
                    [MFSlidingView slideOut];
                    [MFSlidingView slideView:self intoView:myController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Comments" options:options doneBlock:^{
                        [MFSlidingView slideOut];
                    } cancelBlock:^{
                        [MFSlidingView slideOut];
                    }];
                };
                
                popupAlert.doneBlock = cancelOrDoneBlock;
                
                [MFSlidingView slideView:popupAlert intoView:myController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                
                
                // deal with response object
                NSLog(@"working %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
             
             [self populateCommentTable];
                
                if([slidingCommentDelegate respondsToSelector:@selector(incrementCommentScoreUp)]){
                    
                    [slidingCommentDelegate incrementCommentScoreUp];

                }
                
                AddCommentTextFieldOutlet.text = @"";
            }];
        }
    }
    
    
}

- (void) populateCommentTable {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:postSendingContentID, @"content_id", nil] apiMethod:@"comments" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        // deal with response object
        NSLog(@"working on getting comments %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseArray = response;
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseDictionary = response;
        }
        
        [self.SlidingCommentTableViewOutlet reloadData];
        
        NSInteger lastRow = [self.SlidingCommentTableViewOutlet numberOfRowsInSection:0]-1;
        if(lastRow>=0) {
            [self.SlidingCommentTableViewOutlet scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
    
    
    
}

- (IBAction)VoteButtonPressed:(id)sender {
    
   }

-(IBAction)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [AddCommentTextFieldOutlet endEditing:YES];
    NSLog(@"tapping blocked");
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == self.AddCommentTextFieldOutlet)
    {
        [theTextField endEditing:YES];
        [self postCommentMethod];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.tapToDismissGestureRecognizer setEnabled:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self.tapToDismissGestureRecognizer setEnabled:NO];

}


#pragma mark Table Cell Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (responseArray !=nil) {
        return [responseArray count];
        
    }else if (responseDictionary != nil){
        return [responseDictionary count];
        
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    
    if (responseArray != nil && [responseArray count]>0) {
        
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        }
        
        DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[[responseArray objectAtIndex:indexPath.row] objectForKey:@"timestamp"] doubleValue]];
        NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date

        
        cell.textLabel.text = [[responseArray objectAtIndex:indexPath.row] objectForKey:@"text"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ posted %@",[[[responseArray objectAtIndex:indexPath.row] objectForKey:@"author_o"]objectForKey:@"display_name"] ,dateString];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 3;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        NSMutableString *urlString = [[[responseArray objectAtIndex:indexPath.row] objectForKey:@"author_o"]objectForKey:@"picture_thumb"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if(!imageCacheDictionary) imageCacheDictionary = [[NSMutableDictionary alloc] init];
        
        AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60) imageURL:url cache:imageCacheDictionary loadImmediately:YES];
        asyncImageViewInstance.tag = ASYC_IMAGE_TAG;
        asyncImageViewInstance.layer.cornerRadius = 5;
        
        cell.indentationWidth = asyncImageViewInstance.frame.size.width + 5;
        cell.indentationLevel = 1;
        
        UIButton *profileButton = [[UIButton alloc] initWithFrame:asyncImageViewInstance.frame];
        [profileButton addTarget:self action:@selector(goToProfile:) forControlEvents:UIControlEventTouchUpInside];
        [asyncImageViewInstance addSubview:profileButton];
        if ([cell viewWithTag:ASYC_IMAGE_TAG]) {
            [[cell viewWithTag:ASYC_IMAGE_TAG] removeFromSuperview];
        }
        [cell addSubview:asyncImageViewInstance];
        
        UISwipeGestureRecognizer *swipeLeftToDeleteComment = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteCommentButton:)];
        [swipeLeftToDeleteComment setDelegate:self];
        [swipeLeftToDeleteComment setDirection:UISwipeGestureRecognizerDirectionLeft];
        [cell addGestureRecognizer:swipeLeftToDeleteComment];
        
        UISwipeGestureRecognizer *swipeRightToDeleteConvoPost = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(revealDeleteCommentButton:)];
        [swipeRightToDeleteConvoPost setDelegate:self];
        [swipeRightToDeleteConvoPost setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:swipeRightToDeleteConvoPost];
        
        UIButton *deleteConvoPostButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
        [deleteConvoPostButton addTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
        [deleteConvoPostButton setImage:[UIImage imageNamed:@"btn_close_black@2x.png"] forState:UIControlStateNormal];
        [deleteConvoPostButton setTag:DELETE_CONVO_BUTTON_TAG];
        deleteConvoPostButton.alpha = 0;
        deleteConvoPostButton.userInteractionEnabled = NO;
        [cell addSubview:deleteConvoPostButton];

        return cell;
    }else if (responseDictionary != nil && [responseDictionary count] > 0) {
        
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        }
        
        DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[responseDictionary objectForKey:@"timestamp"] doubleValue]];
        NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date

        
        cell.textLabel.text = [responseDictionary objectForKey:@"text"];
        cell.detailTextLabel.text = dateString;
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        
        
        
        return cell;
    }else{
    

    cell.textLabel.text = @"no data";
    cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (responseArray) {
        
    
        NSString *cellText = [[responseArray objectAtIndex:indexPath.row] objectForKey:@"text"];
        UIFont *cellFont = [UIFont fontWithName:@"Quicksand" size:15.0];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height +50;

    }
    
    return 50;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSLog(@"%@", [responseArray objectAtIndex:indexPath.row]);
    NSLog(@" omgz selected row");
    
}

-(void) goToProfile: (id)sender {
    
    [MFSlidingView slideOut];
    
    UITableViewCell *owningCell = (UITableViewCell*)[[sender superview]superview];
    NSIndexPath *pathToCell = [SlidingCommentTableViewOutlet indexPathForCell:owningCell];

    NSLog(@" omgz button pressed row at %d", pathToCell.row);
    
    ProfileViewController2 *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
    
    [newViewController initializeWithUserID:[[[[responseArray objectAtIndex:pathToCell.row]objectForKey:@"author_o"]objectForKey:@"id"]integerValue]];
    
    [[MFSideMenuManager sharedManager].navigationController pushViewController:newViewController animated:YES];
    
//    UIViewController *myViewControllerToPush = [self firstAvailableUIViewController];
//    
//    [myViewControllerToPush.navigationController pushViewController:newViewController animated:YES];
   
}

-(void) revealDeleteCommentButton: (UISwipeGestureRecognizer *)sender {
    
    
    
    if (sender.state == UIGestureRecognizerStateEnded && commentTableIsEditing == NO) {
        
        commentTableIsEditing = YES;
        
        CGPoint swipeLocation = [sender locationInView:self.SlidingCommentTableViewOutlet];
        indexPathToEditingCell = [self.SlidingCommentTableViewOutlet indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.SlidingCommentTableViewOutlet cellForRowAtIndexPath:indexPathToEditingCell];
        NSDictionary *myThreadDictionary = [responseArray objectAtIndex:indexPathToEditingCell.row];
        NSLog(@"thread dictionary: %@", myThreadDictionary);
        NSString *convoPostAuthor = [NSString stringWithFormat:@"%@",[myThreadDictionary objectForKey:@"author"]];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *theCurrentUserID = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"id"]];
        
        if ([theCurrentUserID isEqualToString:convoPostAuthor]) {
            
            
            
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
                                 tapToStopEditingTapGestureRecognizer.enabled = YES;
                                 self.SlidingCommentTableViewOutlet.scrollEnabled = NO;
                                 
                                 
                             }];
            
        }
        
    }else
        return;
}

-(void) stopTableEditing: (UITapGestureRecognizer *) sender {
    
    if (sender.state == UIGestureRecognizerStateEnded && commentTableIsEditing == YES && indexPathToEditingCell != nil) {
        
        UITableViewCell* swipedCell = [self.SlidingCommentTableViewOutlet cellForRowAtIndexPath:indexPathToEditingCell];
        
        
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
                             commentTableIsEditing = NO;
                             tapToStopEditingTapGestureRecognizer.enabled = NO;
                             self.SlidingCommentTableViewOutlet.scrollEnabled = YES;
                             indexPathToEditingCell = nil;
                             
                         }];
        
    }else
        return;
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[otherGestureRecognizer class]]) {
        return NO;
    }else
        return YES;
    
}

-(void) deleteComment: (id) sender {
    
    if (indexPathToEditingCell != nil) {
        NSDictionary *myThreadDictionary = [responseArray objectAtIndex:indexPathToEditingCell.row];
        NSLog(@"%@", myThreadDictionary);
        NSLog(@"%@", [myThreadDictionary objectForKey:@"id"]);
        NSString *postToDeleteID = [NSString stringWithFormat:@"%@", [myThreadDictionary objectForKey:@"id"]];
        
        RadiusRequest *r;
        r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: postToDeleteID, @"comment", nil] apiMethod:@"comment/delete" httpMethod:@"POST"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
                
                NSLog(@"working on creating thread, response is: %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
                
                UITableViewCell* swipedCell = [self.SlidingCommentTableViewOutlet cellForRowAtIndexPath:indexPathToEditingCell];
                
                
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
                                     commentTableIsEditing = NO;
                                     tapToStopEditingTapGestureRecognizer.enabled = NO;
                                     self.SlidingCommentTableViewOutlet.scrollEnabled = YES;
                                     indexPathToEditingCell = nil;
                                     [self populateCommentTable];
                                     
                                 }];
            }else {
                
                NSLog(@"%@", error);
                
            }
            
            
            
        }];
        
    }
}
@end
