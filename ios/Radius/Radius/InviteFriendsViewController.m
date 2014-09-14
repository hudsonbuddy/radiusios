//
//  InviteFriendsViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 10/25/12.
//
//

#import "InviteFriendsViewController.h"
#import <objc/runtime.h>
#import "InviteNewUserView.h"
#import "ProfileViewController2.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "MFSlidingView.h"

@interface InviteFriendsViewController () {
@private
    InviteNewUserView *inviteNewUserView;
    
    // to keep track of current query
    NSString *currentQuery;
    NSUInteger lastUserOffset;
    NSUInteger lastUserCount;
    NSUInteger lastFacebookOffset;
    NSUInteger lastFacebookCount;
    
    NSMutableArray *beaconResults;
    NSMutableArray *friendResults;
    NSMutableArray *userResults;
    
    BOOL isFacebookConnected;
    
    NSMutableDictionary *imageCache;
        
    UIView *activityIndicator;
    NSString *lastQuery;
    
    UITableView *inviteTable;
    NSMutableArray *allInvitedKeys;
}

@end

@implementation InviteFriendsViewController
@synthesize searchBarInput;
@synthesize searchResultsTableView;
@synthesize selectedPeopleDictionary;
@synthesize beaconID, beaconName;
@synthesize justCreated;

static const NSUInteger SEARCH_LIMIT = 25;
static const char * INDEX_PATH_ASSOCIATION_KEY = "index_path";

-(void)initializeInstanceVariables
{
    // to keep track of current query
    currentQuery = nil;
    lastUserOffset = 0;
    lastUserCount = 0;
    lastFacebookOffset = 0;
    lastFacebookCount = 0;
    
    friendResults = nil;
    userResults = nil;
    
    isFacebookConnected = YES;
        
    selectedPeopleDictionary = [[NSMutableDictionary alloc] init];
    allInvitedKeys = [[NSMutableArray alloc] init];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
}

-(void)addActivityIndicator
{
    if(activityIndicator) return;
    
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    myIndicator.frame = CGRectMake(140,65,40,40);
    myIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    myIndicator.layer.cornerRadius = 5;
    [myIndicator startAnimating];
    [self.searchResultsTableView addSubview:myIndicator];
    
    activityIndicator = myIndicator;
}

-(void)removeActivityIndicator
{
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}

-(void)performSearch
{
    
    NSString *searchQueryString = [self.searchBarInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    lastQuery = searchQueryString;
    currentQuery = nil;
    [self clearCachedResults];
    [searchResultsTableView reloadData];
    
    if(![searchQueryString isEqualToString:@""]) {
        [self addActivityIndicator];
        [self findInitialResultsForQuery:searchQueryString];
    } else {
        [self removeActivityIndicator];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSearch];
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:singleTapRecognizer];
    searchBar.text = @"";
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [searchBarInput endEditing:YES];
}

-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.view removeGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
    
}

-(void) clearCachedResults {
    beaconResults = friendResults = userResults = nil;
}

-(void)findInitialResultsForQuery:(NSString *)query
{
    [self findFacebookFriendsForQuery:query limit:5 offset:0];
    [self findRadiusUsersForQuery:query limit:SEARCH_LIMIT offset:0];
}



-(void) findRadiusUsersForQuery:(NSString *)query limit:(NSUInteger)limit offset:(NSUInteger)offset {
    isFacebookConnected = YES;
    RadiusRequest *searchRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:query, @"q",[NSNumber numberWithInteger:offset],@"offset",[NSNumber numberWithInteger:limit],@"limit",nil] apiMethod:@"user/search"];
    [searchRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(query!=lastQuery) return;
        
        [self removeActivityIndicator];
        
        if(![response isKindOfClass:[NSArray class]]) return;
        
        NSArray *resultArray = (NSArray *) response;
        
        currentQuery = query;
        lastUserOffset = offset;
        lastUserCount = resultArray.count;
        
        if(!userResults) userResults = [[NSMutableArray alloc] init];
        [userResults addObjectsFromArray:resultArray];
        [searchResultsTableView reloadData];
    }];
}


-(void) findFacebookFriendsForQuery:(NSString *)query limit:(NSUInteger)limit offset:(NSUInteger)offset {
    RadiusRequest *searchRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:query, @"q",[NSNumber numberWithInteger:offset],@"offset",[NSNumber numberWithInteger:limit],@"limit",nil] apiMethod:@"me/find_friends"];
    [searchRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(query!=lastQuery) return;
        
        [self removeActivityIndicator];
        
        if(![response isKindOfClass:[NSArray class]]) {
            isFacebookConnected = NO;
            return;
        }
        
        NSArray *resultArray = (NSArray *) response;
        
        currentQuery = query;
        lastFacebookOffset = offset;
        lastFacebookCount = resultArray.count;
        
        if(!friendResults) friendResults = [[NSMutableArray alloc] init];
        [friendResults addObjectsFromArray:resultArray];
        [searchResultsTableView reloadData];
    }];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView==inviteTable) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == inviteTable) {
        return [selectedPeopleDictionary count];
    } else {
        switch(section) {
            case 0:{
                if(!friendResults) {
                    return isFacebookConnected?0:1;
                }
                if((lastFacebookOffset != 0 && lastFacebookCount == SEARCH_LIMIT) ||
                   (lastFacebookOffset == 0 && lastFacebookCount == 5)) {
                    return friendResults.count+1;
                }
                return friendResults.count;
            }
            case 1:{
                if(!userResults) return 0;
                if(lastUserCount == SEARCH_LIMIT) {
                    return userResults.count+1;
                }
                return userResults.count;
            }
        }
    }
    return 0;
}

- (void)loadImage:(NSString *)urlString toCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([urlString isEqual:[NSNull null]]) {
        cell.imageView.image = nil;
        return;
    }
    
    
    UIImage *image = [imageCache objectForKey:urlString];
    
    if(image) {
        cell.imageView.image = image;
        [cell setNeedsLayout];
    } else {
        cell.imageView.image = nil;
        [cell setNeedsLayout];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        // Use associated objects to ensure image is not loaded to a deallocated cell
        objc_setAssociatedObject(cell,INDEX_PATH_ASSOCIATION_KEY,indexPath,OBJC_ASSOCIATION_RETAIN);
        
        dispatch_async(queue,^{
            NSURL *url = [NSURL URLWithString:urlString];
            
            UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
            
            if(image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageCache setObject:image forKey:urlString];
                    
                    NSIndexPath *cellIndexPath = (NSIndexPath *) objc_getAssociatedObject(cell, INDEX_PATH_ASSOCIATION_KEY);
                    if([cellIndexPath isEqual:indexPath]) {
                        cell.imageView.image = image;
                        [cell setNeedsLayout];
                    } else {
                    }
                });
            }
        });
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == inviteTable)
    {
        static NSString *MyIdentifier = @"UserCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        }
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *currInvitedPersonDict = [selectedPeopleDictionary objectForKey:[allInvitedKeys objectAtIndex:indexPath.row]];
        cell.textLabel.text = [currInvitedPersonDict objectForKey:@"name"];
        cell.imageView.image = [currInvitedPersonDict objectForKey:@"picture"];
        
        return cell;
    }
    else
    {
        static NSString *MyIdentifier = @"UserCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        }
        cell.accessoryView = nil;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/;
        switch(indexPath.section) {
            case 0:{
                if(!isFacebookConnected) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.textLabel.text = @"Connect to Facebook";
                    cell.textLabel.textColor = [UIColor colorWithRed:59.0/255 green:89.0/255 blue:152.0/255 alpha:1.0];
                } else {
                    if (indexPath.row == friendResults.count) {
                        cell.imageView.image = nil;
                        cell.textLabel.text = @"more...";
                    } else {
                        id result = [friendResults objectAtIndex:indexPath.row];
                        cell.textLabel.text = [result objectForKey:@"name"];
                        
                        [self loadImage:[result objectForKey:@"pic_square"] toCell:cell atIndexPath:indexPath];
                        
                        
                        if([result objectForKey:@"user"]!=[NSNull null]) {
                            NSLog(@"%f",cell.frame.size.height);
                            UIImageView *symbolView = [[UIImageView alloc] initWithFrame:CGRectMake(320-44,
                                                                                                    6,
                                                                                                    32,
                                                                                                    32)];
                            symbolView.image = [UIImage imageNamed:@"btn_logo.png"];
                            symbolView.contentMode = UIViewContentModeScaleAspectFill;
                            cell.accessoryView = symbolView;
                        }
                        NSLog(@"looking for key: %@", [NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]);
                        if ([selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]])
                        {
                            NSLog(@"highlighting %@", [result objectForKey:@"name"]);
                            [cell setHighlighted:YES];
                        }
                    }
                }
                return cell;
            }
            case 1:{
                if (indexPath.row == userResults.count) {
                    cell.textLabel.text = @"more...";
                } else {
                    id result = [userResults objectAtIndex:indexPath.row];
                    cell.textLabel.text = [result objectForKey:@"display_name"];
                    
                    NSString *urlString = [result objectForKey:@"picture_thumb"];
                    [self loadImage:urlString toCell:cell atIndexPath:indexPath];
                    if ([selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]]]) [cell setHighlighted:YES];
                }
                return cell;
            }
        }
    }
    return nil;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0 && !isFacebookConnected) {
        cell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:18];
    }
    
    if (tableView == searchResultsTableView)
    {
        switch(indexPath.section)
        {
            case 0:{
                if (isFacebookConnected && indexPath.row < friendResults.count)
                {
                    id result = [friendResults objectAtIndex:indexPath.row];
                    if ([selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]]) [cell setHighlighted:YES];
                }
                break;
            }
            case 1:{
                if (indexPath.row != userResults.count)
                {
                    id result = [userResults objectAtIndex:indexPath.row];
                    if ([selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]]]) [cell setHighlighted:YES];
                }
                break;
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == inviteTable) return 0;
    return 30;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    
    if(section==0) return @"Friends";
    if(section==1) return @"Other Radius Users";
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    if (tableView == inviteTable) label.text = @"Invited friends";
    else label.text = [self titleForHeaderInSection:section];
    [label sizeToFit];
    
    label.frame = CGRectOffset(label.frame, 0, 18-label.frame.size.height/2);
    
    [view addSubview:label];
    return view;
}

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == inviteTable)
    {
        [selectedPeopleDictionary removeObjectForKey:[allInvitedKeys objectAtIndex:indexPath.row]];
        [allInvitedKeys removeObjectAtIndex:indexPath.row];
        [inviteTable reloadData];
    }
    else
    {
        UITableViewCell *currCell = [tableView cellForRowAtIndexPath:indexPath];
        switch(indexPath.section)
        {
                //Facebook friends section
            case 0: {
                if(isFacebookConnected) {
                    
                    if(indexPath.row == friendResults.count) {
                        [self findFacebookFriendsForQuery:currentQuery limit:SEARCH_LIMIT offset:lastFacebookOffset+SEARCH_LIMIT];
                    } else {
                    
                        id result = [friendResults objectAtIndex:indexPath.row];
                        if ([selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]])
                        {
                            [currCell setHighlighted:NO];
                            //[tableView deselectRowAtIndexPath:indexPath animated:NO];
                            [tableView reloadData];
                            //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [selectedPeopleDictionary removeObjectForKey:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]];
                            [allInvitedKeys removeObject:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]];
                        }
                        else if ([result objectForKey:@"user"]!=[NSNull null] && [selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"r%@", [[result objectForKey:@"user"] objectForKey:@"id"]]])
                        {
                            [currCell setHighlighted:NO];
                            [tableView reloadData];
                            [selectedPeopleDictionary removeObjectForKey:[NSString stringWithFormat:@"r%@", [[result objectForKey:@"user"] objectForKey:@"id"]]];
                            [allInvitedKeys removeObject:[NSString stringWithFormat:@"r%@", [[result objectForKey:@"user"] objectForKey:@"id"]]];
                        }
                        else
                        {
                            [currCell setHighlighted:YES];
                            NSMutableDictionary *currPersonDict = [[NSMutableDictionary alloc] init];
                            [currPersonDict setObject:[result objectForKey:@"name"] forKey:@"name"];
                            [currPersonDict setObject:currCell.imageView.image forKey:@"picture"];
                            [currPersonDict setObject:[result objectForKey:@"uid"] forKey:@"facebookid"];
                            //If they are also a Radius user attach the Radius user ID and hash them that way
                            if ([result objectForKey:@"user"]!=[NSNull null])
                            {
                                [currPersonDict setObject:[[result objectForKey:@"user"] objectForKey:@"id"] forKey:@"radiusid"];
                                [selectedPeopleDictionary setObject:currPersonDict forKey:[NSString stringWithFormat:@"r%@", [[result objectForKey:@"user"] objectForKey:@"id"]]];
                                [allInvitedKeys insertObject:[NSString stringWithFormat:@"r%@", [[result objectForKey:@"user"] objectForKey:@"id"]] atIndex:[allInvitedKeys count]];
                            }
                            else
                            {
                                [selectedPeopleDictionary setObject:currPersonDict forKey:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]]];
                                [allInvitedKeys insertObject:[NSString stringWithFormat:@"f%@", [result objectForKey:@"uid"]] atIndex:[allInvitedKeys count]];
                                
                            }
                        }
                    }
                } else {
                    NSLog(@"tapped 'connect with Facebook'");
                }
                break;
            }
                //Radius users section
            case 1:
            {
                if (indexPath.row == userResults.count)
                {
                    [self findRadiusUsersForQuery:currentQuery limit:SEARCH_LIMIT offset:lastUserOffset+SEARCH_LIMIT];
                }
                else
                {
                    id result = [userResults objectAtIndex:indexPath.row];

                    if ([selectedPeopleDictionary objectForKey:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]]])
                    {
                        [currCell setHighlighted:NO];
                        [tableView reloadData];
                        [selectedPeopleDictionary removeObjectForKey:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]]];
                        [allInvitedKeys removeObject:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]]];
                        
                    }
                    else
                    {
                        [currCell setHighlighted:YES];
                        NSMutableDictionary *currPersonDict = [[NSMutableDictionary alloc] init];
                        [currPersonDict setObject:[result objectForKey:@"display_name"] forKey:@"name"];
                        [currPersonDict setObject:currCell.imageView.image forKey:@"picture"];
                        [currPersonDict setObject:[result objectForKey:@"id"] forKey:@"radiusid"];
                        
                        [selectedPeopleDictionary setObject:currPersonDict forKey:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]]];
                        [allInvitedKeys insertObject:[NSString stringWithFormat:@"r%@", [result objectForKey:@"id"]] atIndex:[allInvitedKeys count]];
                    }
                }
                break;
            }
        }
    }
}

- (void)catchTapForView:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    [button addTarget:self action:@selector(dismissButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)catchTapForNavBar:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    [button addTarget:self action:@selector(dismissButtonFromNavBar:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

-(void)changeSearchBarAppearance
{
    //Set font of search text field
    for(int i =0; i<[searchBarInput.subviews count]; i++) {
        if([[searchBarInput.subviews objectAtIndex:i] isKindOfClass:[UITextField class]])
            [(UITextField*)[searchBarInput.subviews objectAtIndex:i] setFont:[UIFont fontWithName:@"Quicksand" size:14]];
    }
    
}

- (IBAction)inviteListPressed
{
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    inviteTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
    [inviteTable setDataSource:self];
    [inviteTable setDelegate:self];
    
    [MFSlidingView slideView:inviteTable intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Invited friends" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
}
- (IBAction)inviteAndFinishPressed
{
    NSMutableString *radiusIDs = [[NSMutableString alloc] init];
    NSMutableString *facebookIDs = [[NSMutableString alloc] init];
    for (int i=0; i<[allInvitedKeys count]; i++)
    {
        NSDictionary *currPerson = [NSDictionary dictionaryWithDictionary:[selectedPeopleDictionary objectForKey:[allInvitedKeys objectAtIndex:i]]];
        if ([currPerson objectForKey:@"radiusid"] != [NSNull null] && [currPerson objectForKey:@"radiusid"] != nil)
        {
            [radiusIDs appendString: [NSString stringWithFormat:@"%@,", [currPerson objectForKey:@"radiusid"]]];
        }
        else if ([currPerson objectForKey:@"facebookid"] != [NSNull null] && [currPerson objectForKey:@"facebookid"] != nil)
        {
            [facebookIDs appendString: [NSString stringWithFormat:@"%@,", [currPerson objectForKey:@"facebookid"]]];
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Remove final commas from each string and send invites appropriately
    if (radiusIDs != (id)[NSNull null] && radiusIDs.length != 0)
    {
        if ([radiusIDs characterAtIndex:([radiusIDs length]-1)] == ',')
        {
            radiusIDs = [[radiusIDs substringToIndex:([radiusIDs length]-1)] mutableCopy];
        }
        //Send Radius users a notification
        RadiusRequest *inviteUsers = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"token"], @"token", radiusIDs, @"to", beaconID, @"beacon", nil] apiMethod:@"beacon/invite" httpMethod:@"POST"];
        [inviteUsers startWithCompletionHandler:^(id response, RadiusError *error) {
            NSLog(@"invite response is: %@", response);
        }];
    }
    if (facebookIDs != (id)[NSNull null] && facebookIDs.length != 0)
    {
        if ([facebookIDs characterAtIndex:([facebookIDs length]-1)] == ',')
        {
            facebookIDs = [[facebookIDs substringToIndex:([facebookIDs length]-1)] mutableCopy];
        }
        //Send Facebook users an invite        
        Facebook *f = [[Facebook alloc] initWithAppId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"] andDelegate:nil];
        f.accessToken = [FBSession activeSession].accessToken;
        f.expirationDate = [FBSession activeSession].expirationDate;
        
        NSString *inviteMessage = [NSString stringWithFormat:@"%@ has invited you to see %@ on Radius!", [defaults objectForKey:@"display_name"], beaconName];
        [f dialog:@"apprequests" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys: inviteMessage, @"message", facebookIDs, @"to", nil] andDelegate:self];
    }
    
    BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [createdBeaconInstance setSendingBeaconID:beaconID];
    [createdBeaconInstance setTitle:beaconName];
    [createdBeaconInstance setBeaconJustCreated:justCreated];
    NSArray *controllers = [NSArray arrayWithObject:createdBeaconInstance];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"Invite friends!"];
    [self initializeInstanceVariables];
    [self changeSearchBarAppearance];
    [self clearCachedResults];
    [self setupSideMenuBarButtonItem];
    [searchResultsTableView reloadData];
    searchBarInput.text = @"";
    imageCache = [[NSMutableDictionary alloc] init];
    currentQuery = nil;
}

- (void) connectUserWithFacebook
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
             NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:session.accessToken,@"fb_access_token",nil];
             RadiusRequest *request = [RadiusRequest requestWithParameters:payload apiMethod:@"connect_facebook" httpMethod:@"POST"];
             [request startWithCompletionHandler:^(id response, RadiusError *error) {
                 if(error) {
                     // something went wrong
                     NSLog(@"%@",response);
                     
                     if(error.type == RadiusErrorFbAlreadyConnected) {
                         PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
                         [popupAlert setupWithDescriptionText:@"Sorry, your Facebook account is already connected to another Radius account" andButtonText:@"OK"];
                         SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                         void (^cancelOrDoneBlock)() = ^{
                             // we must manually slide out the view out if we specify this block
                             [MFSlidingView slideOut];
                         };
                         [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                     }
                 }
                 [self performSearch];
             }];
         }
     }];
    
    NSLog(@"started to open session");
}


- (void)viewDidUnload {
    [self setSearchBarInput:nil];
    [self setSearchResultsTableView:nil];
    [super viewDidUnload];
}

@end
