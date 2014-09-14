//
//  CreateCheckExistingViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 9/26/12.
//
//

#import "CreateCheckExistingViewController.h"
#import "MFSideMenu.h"
#import "CreateBeaconControllerViewController.h"
#import "BeaconAlreadyMadeView.h"
#import "RadiusRequest.h"
#import "BeaconContentViewController2.h"
#import "MFSlidingView.h"
#import "Flurry.h"

@interface CreateCheckExistingViewController ()
@end

@implementation CreateCheckExistingViewController
@synthesize existingBeaconTable;
@synthesize location = _location;
@synthesize nearbyRadiusBeaconsArray;
@synthesize googResponseDict, googPlaces;
NSString *clickedBeaconID;
NSString *clickedBeaconName;
BeaconAlreadyMadeView *beaconAlreadyMadeView;
UITapGestureRecognizer *recognizerForSubView;
UIButton *frameButton;
UIButton *navButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Started to Create a Beacon"];
#endif
    [Flurry logEvent:@"Beacon_Created" timed:YES];
    
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    [self setupExistingTableImageViewAndTable];
    
    self.title = @"Create Beacon";
    
    if(self.location) {
        [self reloadExistingBeaconsTable];
    } else {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        if(locationManager.location) {
            self.location = locationManager.location;
            [self reloadExistingBeaconsTable];
        } else {
            locationManager.delegate = self;
            [locationManager startUpdatingLocation];
        }
    }
    
    [self showLoadingOverlay];
    //[dimView removeFromSuperview];
}

-(void) setupExistingTableImageViewAndTable {
    
    UIImageView *existingPlacePanelImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pnl_cbp_existingplace.png"]];
    [self.tableBackgroundView addSubview:existingPlacePanelImageView];
    [self.tableBackgroundView sendSubviewToBack:existingPlacePanelImageView];
//    [self.existingBeaconTable setFrame:CGRectMake(0, 20, 310, 350)];
    [self.tableBackgroundView addSubview:existingBeaconTable];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.location = newLocation;
    [self reloadExistingBeaconsTable];
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = [locations objectAtIndex:0];
    [self reloadExistingBeaconsTable];
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) reloadExistingBeaconsTable
{
    //Request the very close Radius beacons - 3 maximum
    //bbox - a comma-separated list of floats representing a bounding box as lng_min,lat_min,lng_max,lat_max
    //    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"-122.04,37.35,-122.03,37.36", @"bbox", 0, @"offset", 4, @"limit", nil] apiMethod:@"beacon/in_bbox"];
    
    NSLog(@"current coordinates: %f %f", self.location.coordinate.longitude, self.location.coordinate.latitude);
    RadiusRequest *radRequest2 = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%f,%f,%f,%f", self.location.coordinate.longitude-.01, self.location.coordinate.latitude-.01, self.location.coordinate.longitude+.01, self.location.coordinate.latitude+.01], @"bbox", 0, @"offset", 4, @"limit", nil] apiMethod:@"beacon/in_bbox"];
    [radRequest2 startWithCompletionHandler:^(id response, RadiusError *error) {
        nearbyRadiusBeaconsArray = response;
        [self removeDuplicatePlaces];
        //[self.existingBeaconTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    [self loadGooglePlaces];
}

-(void)loadGooglePlaces
{
    [self loadGooglePlaces:0];
}

-(void)loadGooglePlaces:(int)retryCount
{
    
    //Request the very close places from Google Places API
    //Places fetched ranked by distance, not prominance
    //Radius = 500m, which is about half the ~.68 mi used in the Radius query
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&sensor=true&radius=500&key=AIzaSyA88IgjLOeRzYjRVg3ac9thcFhip6-4p8s", self.location.coordinate.latitude, self.location.coordinate.longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error || !data) {
            
            // if this has been retried three times (request was made four times total), just don't include Google places
            if(retryCount > 3) {
                return;
            }
            
            [self loadGooglePlaces:retryCount+1];
            return;
        }
        
        NSError *e = nil;
        id googResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&e];
        googResponseDict = googResponse;
        googPlaces = [[googResponseDict objectForKey:@"results"] mutableCopy];
        [self removeDuplicatePlaces];
        //[self.existingBeaconTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

//Checks if we have both the lists of Radius and Google places and removes duplicate Google places
-(void)removeDuplicatePlaces
{
    if (nearbyRadiusBeaconsArray != nil && googPlaces != nil)
    {
        NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc] init];
        for (int i=0; i<[googPlaces count]; i++)
        {
            NSDictionary *currentGoogPlace = [googPlaces objectAtIndex:i];
            NSString *currentGoogleID = [currentGoogPlace objectForKey:@"id"];
            for (int j=0; j<[nearbyRadiusBeaconsArray count]; j++)
            {
                NSString *currentRadiusPlaceGoogleID = [[nearbyRadiusBeaconsArray objectAtIndex:j] objectForKey:@"google_place"];
                if ([currentGoogleID isEqualToString:currentRadiusPlaceGoogleID])
                {
                    [indicesToRemove addIndex:i];
                    break;
                }
            }
        }
        [googPlaces removeObjectsAtIndexes:indicesToRemove];
        //Reload the table once the duplicate Google places have been removed
        [self.existingBeaconTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self dismissLoadingOverlay];
    }

}

- (IBAction)nopeButtonPressed
{
    CreateBeaconControllerViewController *demoController = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewID"];
    [demoController initializeWithLocation:self.location.coordinate];
    [self.navigationController pushViewController:demoController animated:YES];
}

- (void)continuePressed
{
    NSLog(@"continue pressed");
    BeaconContentViewController2 *createdBeaconInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
    [createdBeaconInstance initializeWithBeaconID:clickedBeaconID];
    [MFSlidingView slideOut];
    [self.navigationController pushViewController:createdBeaconInstance animated:YES];
}

#pragma mark Table View Setup

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"number of cells is: %u", [nearbyRadiusBeaconsArray count] + [googPlaces count]);
    return [nearbyRadiusBeaconsArray count] + [googPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"current index path is:%@", indexPath);
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.textLabel.textColor = [UIColor blackColor];
    //Make it so cells are Radius maroon when highlighted
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
    [cell setSelectedBackgroundView:bgColorView];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    //Set font of cells - different for Radius vs. Google results
    //Radius places
    if (indexPath.row < [nearbyRadiusBeaconsArray count])
    {
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        UIImageView *symbolView = [[UIImageView alloc] initWithFrame:CGRectMake(320-44,
                                                                                6,
                                                                                32,
                                                                                32)];
        symbolView.image = [UIImage imageNamed:@"btn_logo.png"];
        symbolView.contentMode = UIViewContentModeScaleAspectFill;
        cell.accessoryView = symbolView;
    }
    //Google places
    else
    {
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    }
    
    if (indexPath.row < [nearbyRadiusBeaconsArray count])
    {
        cell.textLabel.text = [[nearbyRadiusBeaconsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    else
    {
        cell.textLabel.text = [[googPlaces objectAtIndex:(indexPath.row-[nearbyRadiusBeaconsArray count])] objectForKey:@"name"];
    }
    
    
    return cell;
}

-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showLoadingOverlay];
    CreateBeaconControllerViewController *create2Controller = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewID"];
    [create2Controller setTitle:@"Create"];
    //If it is place already on Radius, redirect to that beacon's page
    if (indexPath.row < [nearbyRadiusBeaconsArray count])
    {
        NSDictionary *currentBeaconDict = [nearbyRadiusBeaconsArray objectAtIndex:indexPath.row];
        clickedBeaconID = [currentBeaconDict objectForKey:@"id"];
        clickedBeaconName = [currentBeaconDict objectForKey:@"name"];
        //        UIAlertView *alreadyExistsAlert = [[UIAlertView alloc] initWithTitle:@"Here's the place!" message:@"This place already exists on Radius.  Check it out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //        [alreadyExistsAlert show];
        beaconAlreadyMadeView = [[[NSBundle mainBundle]loadNibNamed:@"BeaconAlreadyMadeView" owner:self options:nil]objectAtIndex:0];
        [beaconAlreadyMadeView setFrame:CGRectMake(self.view.frame.size.width/2-beaconAlreadyMadeView.frame.size.width/2, 100, beaconAlreadyMadeView.frame.size.width, beaconAlreadyMadeView.frame.size.height)];
        NSString *pictureURL = [currentBeaconDict objectForKey:@"picture"];
        if (pictureURL != (id)[NSNull null] && pictureURL.length != 0)
        {
            NSURL *imageURL = [NSURL URLWithString:[currentBeaconDict objectForKey:@"picture"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *profileImage = [[UIImage alloc] initWithData:imageData];
            [beaconAlreadyMadeView setUpWithBeaconPicture:profileImage andBeaconName:[currentBeaconDict objectForKey:@"name"]];
        }
        else
        {
            [beaconAlreadyMadeView setUpWithBeaconPicture:[UIImage imageNamed:@"icon - retina.png"] andBeaconName:[currentBeaconDict objectForKey:@"name"]];
        }

        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        
        [self.continueButton addTarget:self action:@selector(continuePressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self dismissLoadingOverlay];
        [MFSlidingView slideView:beaconAlreadyMadeView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
    }
    //If it's a Google place
    else
    {
        NSDictionary *currGooglePlaceDict = [googPlaces objectAtIndex:(indexPath.row-[nearbyRadiusBeaconsArray count])];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[[[currGooglePlaceDict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue],[[[[currGooglePlaceDict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]);
        [create2Controller initializeWithLocation:location name:[currGooglePlaceDict objectForKey:@"name"] googlePlaceReference:[currGooglePlaceDict objectForKey:@"reference"]];
        [self.navigationController pushViewController:create2Controller animated:YES];
    }
}

- (void)catchTapForView:(UIView *)view {
    [self resignFirstResponder];
    frameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    frameButton.frame = view.bounds;
    [frameButton addTarget:self action:@selector(dismissBeaconAlreadyMadeView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:frameButton];
}

- (void)catchTapForNavBar:(UIView *)view {
    [self resignFirstResponder];
    navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navButton.frame = view.bounds;
    [navButton addTarget:self action:@selector(dismissBeaconAlreadyMadeView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:navButton];
}

- (void)viewDidUnload {
    [self setContinueButton:nil];
    [super viewDidUnload];
}
@end
