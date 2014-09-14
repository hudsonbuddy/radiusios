//
//  SearchViewController.m
//  Radius
//
//  Created by Hud on 7/17/12.
//
//

#import "SearchViewController.h"
#import <objc/runtime.h>
#import "InviteNewUserView.h"
#import "ProfileViewController2.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "AsyncImageView.h"

@interface SearchViewController () {
@private
    InviteNewUserView *inviteNewUserView;
    
    // to keep track of current query
    NSString *currentQuery;
    NSUInteger lastBeaconOffset;
    NSUInteger lastBeaconCount;
    NSUInteger lastUserOffset;
    NSUInteger lastUserCount;
    NSUInteger lastFacebookOffset;
    NSUInteger lastFacebookCount;
    
    NSMutableArray *beaconResults;
    NSMutableArray *friendResults;
    NSMutableArray *userResults;
    
    BOOL isFacebookConnected;
    
    NSMutableDictionary *imageCache;
    
    SearchMode mode;
    
    UIView *activityIndicator;
    
    NSString *lastQuery;
}

@end

@implementation SearchViewController
@synthesize searchBarInput;
@synthesize searchResultsTableView;

const NSUInteger SEARCH_LIMIT = 25;
static const char * INDEX_PATH_ASSOCIATION_KEY = "index_path";


-(void) initializeInstanceVariables
{
    // to keep track of current query
    currentQuery = nil;
    lastBeaconOffset = 0;
    lastBeaconCount = 0;
    lastUserOffset = 0;
    lastUserCount = 0;
    lastFacebookOffset = 0;
    lastFacebookCount = 0;
    
    beaconResults = nil;
    friendResults = nil;
    userResults = nil;
    
    isFacebookConnected = YES;
    
    mode = SearchModeBeacons;
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

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    
    [searchBarInput endEditing:YES];
    
}

-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
   [self.view removeGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
    
}

    

-(void)setSearchMode:(SearchMode)newMode {
    mode = newMode;
    [searchResultsTableView reloadData];
    if(currentQuery) {
        if((mode==SearchModeBeacons && !beaconResults) || (mode==SearchModePeople && !userResults)) {
            [self addActivityIndicator];
            [self findInitialResultsForQuery:currentQuery];
        }
    }
}

-(void) clearCachedResults {
    beaconResults = friendResults = userResults = nil;
}


-(void)findInitialResultsForQuery:(NSString *)query
{
    if (mode==SearchModeBeacons) {
        [self findBeaconsForQuery:query limit:SEARCH_LIMIT offset:0];
    } else if(mode==SearchModePeople) {
        [self findFacebookFriendsForQuery:query limit:5 offset:0];
        [self findRadiusUsersForQuery:query limit:SEARCH_LIMIT offset:0];
    }
}

-(void) findBeaconsForQuery:(NSString *)query limit:(NSUInteger)limit offset:(NSUInteger)offset {
    RadiusRequest *searchRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:query, @"q",[NSNumber numberWithInteger:offset],@"offset",[NSNumber numberWithInteger:limit],@"limit",nil] apiMethod:@"beacon/search"];
    [searchRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(query!=lastQuery) return;

        [self removeActivityIndicator];

        if(error) return;
        
        NSArray *resultArray = (NSArray *) response;
        
        currentQuery = query;
        lastBeaconOffset = offset;
        lastBeaconCount = resultArray.count;
        
        if(!beaconResults) beaconResults = [[NSMutableArray alloc] init];
        [beaconResults addObjectsFromArray:resultArray];
        [searchResultsTableView reloadData];
    }];
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
    switch(mode) {
        case SearchModeBeacons:
            return 1;
        case SearchModePeople:
            return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    
    switch(mode) {
        case SearchModeBeacons: {
            if(!beaconResults) return 0;
            
            if(lastBeaconCount == SEARCH_LIMIT) {
                return beaconResults.count+1;
            }            
            return beaconResults.count;
        }
        case SearchModePeople: {
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
    switch(mode) {
        case SearchModeBeacons: {
            if (indexPath.row == beaconResults.count) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
                cell.detailTextLabel.text = @"";
                cell.imageView.image = nil;
                cell.textLabel.text = @"more...";
                return cell;
            } else {
                static NSString *MyIdentifier = @"BeaconCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
                }
                id result = [beaconResults objectAtIndex:indexPath.row];
                cell.textLabel.text = [result objectForKey:@"name"];
                int numFollowers = [[result objectForKey:@"num_followers"] intValue];
                cell.detailTextLabel.text = [NSString stringWithFormat: @"%d follower%@", numFollowers, numFollowers == 1 ? @"" : @"s"];
                UIView *bgColorView = [[UIView alloc] init];
                [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
                [cell setSelectedBackgroundView:bgColorView];
                [self loadImage:[result objectForKey:@"picture_thumb"] toCell:cell atIndexPath:indexPath];

                return cell;
//                AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60) imageURL:[result objectForKey:@"picture_thumb"] cache:imageCache loadImmediately:YES];
//                asyncImageViewInstance.tag = 537;
//                asyncImageViewInstance.layer.cornerRadius = 5;
//                
//                cell.indentationWidth = asyncImageViewInstance.frame.size.width + 5;
//                cell.indentationLevel = 1;
//                [cell addSubview:asyncImageViewInstance];
                
            }
        }
        case SearchModePeople: {
            static NSString *MyIdentifier = @"UserCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
                UIView *bgColorView = [[UIView alloc] init];
                [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
                [cell setSelectedBackgroundView:bgColorView];
            }
            cell.accessoryView = nil;
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
                        }
                    }
                    return cell;
                }
                case 1:{
                    if (indexPath.row == userResults.count) {
                        cell.imageView.image = nil;
                        cell.textLabel.text = @"more...";
                    } else {
                        id result = [userResults objectAtIndex:indexPath.row];
                        cell.textLabel.text = [result objectForKey:@"display_name"];
                        
                        NSString *urlString = [result objectForKey:@"picture_thumb"];
                        [self loadImage:urlString toCell:cell atIndexPath:indexPath];
                    }
                    return cell;
                }
            }
        }
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(mode==SearchModePeople && indexPath.section==0 && !isFacebookConnected) {
        cell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(mode==SearchModePeople) {
        return 30;
    }
    return 0;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    if(mode==SearchModePeople) {
        if(section==0) return @"Friends";
        if(section==1) return @"Other Radius Users";
    }

    if(mode==SearchModeBeacons) {
        return nil;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view;
    if(NSClassFromString(@"UITableViewHeaderFooterView")) {
        view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    } else {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = [UIColor grayColor];
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
        bottomLine.backgroundColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
        [view addSubview:bottomLine];
    }
        
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    label.text = [self titleForHeaderInSection:section];
    [label sizeToFit];
    
    label.frame = CGRectOffset(label.frame, 0, 18-label.frame.size.height/2);
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = .5;
    label.layer.shadowRadius = 1.0;
    [view addSubview:label];
    return view;
}


static const NSUInteger MAIN_DIMVIEW_TAG = 81762;
static const NSUInteger NAVBAR_DIMVIEW_TAG = 81763;
static const NSUInteger MAIN_DISMISSBUTTON_TAG = 81764;
static const NSUInteger NAVBAR_DISMISSBUTTON_TAG = 81765;

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(mode) {
        case SearchModeBeacons: {
            if(indexPath.row == beaconResults.count) {
                [self findBeaconsForQuery:currentQuery limit:SEARCH_LIMIT offset:lastBeaconOffset+SEARCH_LIMIT];
            } else {
                BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
                [createdBeaconInstance setSendingBeaconID:[[beaconResults objectAtIndex:indexPath.row] objectForKey:@"id"]];
                [createdBeaconInstance setTitle:[[beaconResults objectAtIndex:indexPath.row] objectForKey:@"name"]];
                [self.navigationController pushViewController:createdBeaconInstance animated:YES];
            }
            break;
        }
        case SearchModePeople: {
            switch(indexPath.section) {
                case 0: {
                    if(isFacebookConnected) {
                        
                        if(indexPath.row == friendResults.count) {
                            [self findFacebookFriendsForQuery:currentQuery limit:SEARCH_LIMIT offset:lastFacebookOffset+SEARCH_LIMIT];
                        } else {
                        
                            NSDictionary *result = [friendResults objectAtIndex:indexPath.row];
                            NSDictionary *radiusUser = [result objectForKey:@"user"];
                            if([radiusUser isEqual:[NSNull null]]) {
                                NSString *name = [[friendResults objectAtIndex:indexPath.row] objectForKey:@"name"];

                                //Present the Invite New User popup
                                inviteNewUserView = [[[NSBundle mainBundle]loadNibNamed:@"InviteNewUserView" owner:self options:nil]objectAtIndex:0];
                                id result = [friendResults objectAtIndex:indexPath.row];
                                [inviteNewUserView setUserProfileTo:name withPicture:[imageCache objectForKey:[result objectForKey:@"pic_square"]]];
                                NSLog(@"returned class is %@", [[result objectForKey:@"uid"] class]);
                                inviteNewUserView.fbID = [result objectForKey:@"uid"];
                                SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                                void (^cancelOrDoneBlock)() = ^{
                                    // we must manually slide out the view out if we specify this block
                                    [MFSlidingView slideOut];
                                };
                                
                                [MFSlidingView slideView:inviteNewUserView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                            
                            } else {
                                ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
                                
                                [meProfileController initializeWithUserID:[[radiusUser objectForKey:@"id"] integerValue]];
                                
                                [self.navigationController pushViewController:meProfileController animated:YES];
                            }
                        }
                    } else {
                        [self connectUserWithFacebook];
                    }
                    break;
                }
                case 1: {
                    if(indexPath.row == userResults.count) {
                        [self findRadiusUsersForQuery:currentQuery limit:SEARCH_LIMIT offset:lastUserOffset+SEARCH_LIMIT];
                    } else {
                        ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];

                        [meProfileController initializeWithUserID:[[[userResults objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]];
                        
                        [self.navigationController pushViewController:meProfileController animated:YES];
                    }
                    break;
                }
            }
            
        }
    }
    
    [searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];

}

-(void)dismissInvite
{
    [[self.view viewWithTag:MAIN_DIMVIEW_TAG] removeFromSuperview];
    [[self.view viewWithTag:MAIN_DISMISSBUTTON_TAG] removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:NAVBAR_DIMVIEW_TAG] removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:NAVBAR_DISMISSBUTTON_TAG] removeFromSuperview];
    [inviteNewUserView removeFromSuperview];
}

- (void)catchTapForView:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    button.tag = MAIN_DISMISSBUTTON_TAG;
    [button addTarget:self action:@selector(dismissInvite) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)catchTapForNavBar:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    button.tag = NAVBAR_DISMISSBUTTON_TAG;
    [button addTarget:self action:@selector(dismissInvite) forControlEvents:UIControlEventTouchUpInside];
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
    [self initializeInstanceVariables];
    [self changeSearchBarAppearance];
    [self clearCachedResults];
    [searchResultsTableView reloadData];
    searchBarInput.text = @"";
    imageCache = [[NSMutableDictionary alloc] init];
    currentQuery = nil;
    
    [self pressedBeaconButton:nil];
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
                         [popupAlert setupWithDescriptionText:@"Sorry, your Facebook account is already connected to another Radius account." andButtonText:@"OK"];
                         SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                         void (^cancelOrDoneBlock)() = ^{
                             // we must manually slide out the view out if we specify this block
                             [MFSlidingView slideOut];
                         };
                         [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                     }
                 }
                 [self findFacebookFriendsForQuery:self.searchBarInput.text limit:SEARCH_LIMIT offset:0];
             }];
         }
     }];
    
    NSLog(@"started to open session");
}


- (void)viewDidUnload {
    [self setSearchBarInput:nil];
    [self setSearchResultsTableView:nil];
    [self setBeaconButton:nil];
    [self setPeopleButton:nil];
    [super viewDidUnload];
}

- (IBAction)pressedBeaconButton:(id)sender {
    [self setSearchMode:SearchModeBeacons];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [self.beaconButton setAlpha:1];
                         [self.peopleButton setAlpha:.4];
                         
                         
                     } completion:^(BOOL finished) {
                         
                         
                         
                     }];
}

- (IBAction)pressedPeopleButton:(id)sender {
    [self setSearchMode:SearchModePeople];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [self.beaconButton setAlpha:.4];
                         [self.peopleButton setAlpha:1];
                         
                         
                     } completion:^(BOOL finished) {
                         
                         
                         
                     }];}
@end
