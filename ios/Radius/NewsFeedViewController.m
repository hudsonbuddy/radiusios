//
//  NewsFeedViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 9/17/12.
//
//

#import "NewsFeedViewController.h"
#import "RadiusRequest.h"
#import "DateAndTimeHelper.h"
#import "BeaconContentViewController2.h"
#import "RadiusEvent.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "BeaconCreateEvent.h"
#import "Flurry.h"

@interface NewsFeedViewController() {
    BOOL isLoadingMore;
    BOOL reachedBottom;
    
    RadiusRequest *lastRequest;
    UIView *loadingView;
    
    NSInteger totalRequested;
    
    // to only show the "enable location services..." alert once
    BOOL noLocationAlertShown;
}

@property NSMutableArray *newsFeedDataArray;
@end

@implementation NewsFeedViewController
@synthesize allButton, followedButton, nearbyButton, topButton;
@synthesize feedTableView;
@synthesize newsFeedDataArray;
@synthesize locationManager;

NSMutableDictionary *cache;
NSMutableDictionary *imageCacheDictionary;

NSString *currentFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Opened News Feed"];
#endif
    [Flurry logEvent:@"News_Feed_Opened"];
    
    [super viewDidLoad];
    
    [self setTopButtonSelected];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];
    
    cache = [[NSMutableDictionary alloc] init];
    
    isLoadingMore = NO;
}

// For iOS < 6 compatibility
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if(self.allButton.isSelected) {
        [self setAllButtonSelected];
    }
    [locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(self.allButton.isSelected) {
        [self setAllButtonSelected];
    }
    [locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(self.allButton.isSelected) {
        [self setAllButtonSelected];
    }
    [locationManager stopUpdatingLocation];
    [self showNoLocationAlert];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(self.allButton.isSelected) {
        [self setAllButtonSelected];
    }
    [manager startUpdatingLocation];
}

-(void)requestNewsFeedWithOffset:(NSUInteger)offset limit:(NSUInteger)limit completionHandler:(RadiusResponseHandler)completionHandler
{
    
    totalRequested = offset+limit;
    
    NSString *currLat = [NSString stringWithFormat:@"%.8lf",locationManager.location.coordinate.latitude];
    NSString *currLng = [NSString stringWithFormat:@"%.8lf",locationManager.location.coordinate.longitude];
    
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:currentFilter, @"filter", currLat, @"lat", currLng, @"lng", offsetString,@"offset",limitString,@"limit", @"true", @"sensor", nil] apiMethod:@"me/news_feed"];
    lastRequest = radRequest;
    [radRequest startWithCompletionHandler:^(id result, RadiusError *error) {
        if(radRequest==lastRequest) {
            completionHandler(result,error);
        }
    }];
    
}

-(void)showLoadingView
{
    if(!loadingView) {
        CGFloat height = 140;
        CGFloat width = 250;
        CGFloat topOffset = 120;
        
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(feedTableView.frame.size.width/2-width/2,
                                                               topOffset,
                                                               width,
                                                               height)];
        loadingView.layer.cornerRadius = 5;
        loadingView.layer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor];
        
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingIndicator.frame = CGRectMake(0,25,loadingView.frame.size.width,loadingIndicator.frame.size.height);
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,25+60,loadingView.frame.size.width,40)];
        loadingLabel.numberOfLines = 2;
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = @"we're gathering the latest \nbeacon broadcasts for you";
        loadingLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17.0];
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.backgroundColor = [UIColor clearColor];
        
        
        [loadingView addSubview:loadingIndicator];
        [loadingView addSubview:loadingLabel];
        [loadingIndicator startAnimating];
        [feedTableView addSubview:loadingView];
        
    }
    
}

-(void)dismissLoadingView
{
    [loadingView removeFromSuperview];
    loadingView = nil;
}

-(void)loadInitialNewsFeedData
{
    
    newsFeedDataArray = nil;
    [feedTableView reloadData];
    
    reachedBottom = NO;
    isLoadingMore = YES;
    totalRequested = 0;
    
    [self removeLoadingMoreIndicator];
    [self showLoadingView];
    
    [self requestNewsFeedWithOffset:0 limit:10 completionHandler:^(id response, RadiusError *error) {
        
        [self dismissLoadingView];
        
        if(error) {
            // display error message
            return;
        }
        
        if([response count] < 10) reachedBottom = YES;
        
        newsFeedDataArray = [self eventsFromResponse:response];
        
        //Reload the table view and scroll it to top
        [feedTableView reloadData];
        if(self.newsFeedDataArray.count) {
            [feedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        isLoadingMore = NO;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // not sure if this must be done on the main thread, but just to be safe...
            [loadingView removeFromSuperview];
        });
        
        
    }];
    
}

-(NSMutableArray *)eventsFromResponse:(NSArray *)responseArray
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(NSDictionary *eventDict in responseArray) {
        RadiusEvent *event = [RadiusEvent eventWithDictionary:eventDict];
        if(event) {
            [events addObject:event];
        }
    }
    
    return events;
}

-(void)loadMoreNewsFeedData
{
    // We can run into concurrency issues here with nonatomic boolean assign.  Maybe add a lock.
    
    if(isLoadingMore || reachedBottom) return;
    
    isLoadingMore = YES;
    
    [self addLoadingMoreIndicator];
    
    [self requestNewsFeedWithOffset:totalRequested limit:20 completionHandler:^(id response, RadiusError *error) {
        
        if(!error) {
            if([response count]<20) reachedBottom = YES;
            
            [newsFeedDataArray addObjectsFromArray:[self eventsFromResponse:response]];
            [feedTableView reloadData];
            
            feedTableView.scrollsToTop = YES;
        }
        
        [self removeLoadingMoreIndicator];
        isLoadingMore = NO;
    }];
}

static const NSInteger LOADING_MORE_INDICATOR_TAG = 987592;

- (void)addLoadingMoreIndicator
{
    if([feedTableView viewWithTag:LOADING_MORE_INDICATOR_TAG]) return;
    
    feedTableView.contentInset = UIEdgeInsetsMake(feedTableView.contentInset.top,
                                                  feedTableView.contentInset.left,
                                                  50,
                                                  feedTableView.contentInset.right);
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.frame = CGRectMake(0, feedTableView.contentSize.height+15, 300, 20);
    [aiv startAnimating];
    aiv.tag = LOADING_MORE_INDICATOR_TAG;
    [feedTableView addSubview:aiv];
}

- (void)removeLoadingMoreIndicator
{
    [[feedTableView viewWithTag:LOADING_MORE_INDICATOR_TAG] removeFromSuperview];
    feedTableView.contentInset = UIEdgeInsetsMake(feedTableView.contentInset.top,
                                                  feedTableView.contentInset.left,
                                                  0,
                                                  feedTableView.contentInset.right);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showNoLocationAlert {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *path = @"Settings";
    if(version >= 4 && version < 6) {
        path = @"Settings > Location Services";
    } else if(version >= 6) {
        path = @"Settings > Privacy > Location Services";
    }
    
    NSString *message = [NSString stringWithFormat:@"To see activity from nearby beacons, enable location services for Radius in %@.",path];
    PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
    [popupAlert setupWithDescriptionText:message andButtonText:@"OK"];
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
}

#pragma Methods for tab buttons

- (IBAction)allButtonPressed
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Applied News Feed \"All\" Filter"];
#endif
    [Flurry logEvent:@"News_Feed_All_Pressed"];
    
    [self setAllButtonSelected];
}

-(void)setAllButtonSelected
{
    if(locationManager.location) {
        currentFilter = @"all";
    } else {
        if(!noLocationAlertShown) {
            [self showNoLocationAlert];
            noLocationAlertShown = YES;
        }
        currentFilter = @"followed";
    }
    [self loadInitialNewsFeedData];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [allButton setAlpha:1];
                         [topButton setAlpha:.4];
                         
                        
                     } completion:^(BOOL finished) {
                         
                         
                         
                     }];

}

- (IBAction)topButtonPressed
{
    [self setTopButtonSelected];
}
-(void)setTopButtonSelected
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Applied News Feed \"Top\" Filter"];
#endif
    [Flurry logEvent:@"News_Feed_Top_Pressed"];
    
    currentFilter = @"top";
    [self loadInitialNewsFeedData];

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
                         [allButton setAlpha:.4];
                         [topButton setAlpha:1];
                         
                         
                     } completion:^(BOOL finished) {
                         
                         
                         
                     }];
}


#pragma FeedTableView delagate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RadiusEvent *event = [newsFeedDataArray objectAtIndex:indexPath.row];
    return [event newsFeedCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newsFeedDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RadiusEvent *event = [newsFeedDataArray objectAtIndex:indexPath.row];
    
    // Get the cell for this particular type of event
    FeedCell *cell = [event newsFeedCellForTableView:tableView imageCache:cache];
    
    // Common setup for all feed cells
    DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:event.timestamp];
    NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date
    [cell.timePostedLabel setText:dateString];
    
    //Calculate distance from user's current location to the Beacon
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[[event.beaconInfo objectForKey:@"center"] objectAtIndex:0] doubleValue] longitude:[[[event.beaconInfo objectForKey:@"center"] objectAtIndex:1] doubleValue]];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    //Distance in Meters
    //1 meter == 100 centimeter
    //1 meter == 3.280 feet
    //1 meter == 10.76 square feet
    //Max 1 decimal place for display purposes
    NSString *milesString = [NSString stringWithFormat:@"%f", (distance*3.28/5280)];
    NSRange rangeOfDecimal = [milesString rangeOfString:@"."];
    milesString = [milesString substringToIndex:rangeOfDecimal.location+2];
    NSString *distString = [NSString stringWithFormat:@"%@ mi", milesString];
    //[cell.distanceLabel setText:distString];
    [cell setDistanceLabelWithDistance:distString];
    
    [cell.beaconNameLabel setText:[event.beaconInfo objectForKey: @"name"]];
    if ([event isMemberOfClass:[BeaconCreateEvent class]])
    {
        [cell.numberOfFollowersLabel setText:@"New beacon!"];
        cell.numberOfFollowersLabel.textColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/;
    }
    else
    {
        int numFollowers = [[event.beaconInfo objectForKey: @"num_followers"] integerValue];
        if (numFollowers == 1)
        {
            [cell.numberOfFollowersLabel setText:@"1 follower"];
        }
        else
        {
            [cell.numberOfFollowersLabel setText: [NSString stringWithFormat:@"%d followers", numFollowers]];
        }
    }
    
    return cell;
}

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RadiusEvent *event = [newsFeedDataArray objectAtIndex:indexPath.row];
    
    UIViewController *next = [event linkViewController];
    
    if(next) {
        [self.navigationController pushViewController:next animated:YES];
    }
    
    return;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -600;
    if(y > h + reload_distance) {
        [self loadMoreNewsFeedData];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [locationManager stopUpdatingLocation];
}



@end
