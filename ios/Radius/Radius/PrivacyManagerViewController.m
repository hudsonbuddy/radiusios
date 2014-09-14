//
//  PrivacyManagerViewController.m
//  radius
//
//  Created by Hud on 1/3/13.
//
//

#import "PrivacyManagerViewController.h"
#import "ProfileViewController2.h"

@interface PrivacyManagerViewController ()

@property (nonatomic, strong) NSMutableDictionary *cache;


@end

@implementation PrivacyManagerViewController

static const NSInteger CELL_ASYNC_IMAGE_TAG = 1000;
static const NSInteger APPROVE_BUTTON_TAG = 2000;
static const NSInteger DENY_BUTTON_TAG = 3000;
static const NSInteger KICK_BUTTON_TAG = 4000;




@synthesize privacyTableOutlet, pendingRequestsArray, preapprovedArray, beaconID;
@synthesize indexPathOfActionCell;


#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self showLoadingOverlay];
    [self setupSideMenuBarButtonItem];
    [self initializePrivacyManagerViewController];
    [self findPendingRequests];
    [self findApprovedList];
}

-(void) initializePrivacyManagerViewController {
    
    privacyTableOutlet.delegate = self;
    privacyTableOutlet.dataSource = self;
    [self setTitle:@"Privacy"];

}

-(void) findPendingRequests{
    
    
    RadiusRequest *r = [RadiusRequest requestWithParameters: [NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", nil] apiMethod:@"beacon/privacy/requests" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        NSLog(@"reloaded pending requests for beacon is: %@", response);
        pendingRequestsArray = response;
        [privacyTableOutlet reloadData];
        [self dismissLoadingOverlay];
    }];

    
}

-(void) findApprovedList {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters: [NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", nil] apiMethod:@"beacon/privacy/approved" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        NSLog(@"reloaded preapproved for beacon is: %@", response);
        preapprovedArray = response;
        [privacyTableOutlet reloadData];
        [self dismissLoadingOverlay];

    }];
    
}

#pragma mark Button Methods

-(void) kickFromPreapprovedList: (id) sender {
    
    UITableViewCell *owningCell = (UITableViewCell*)[sender superview];
    NSIndexPath *pathToCell = [privacyTableOutlet indexPathForCell:owningCell];
    indexPathOfActionCell = pathToCell;

    [privacyTableOutlet cellForRowAtIndexPath:pathToCell].userInteractionEnabled = NO;

    
    NSLog(@" omgz button pressed row at %d and section at %d", pathToCell.row, pathToCell.section);
    
    RadiusRequest *requestInstance = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[preapprovedArray objectAtIndex:pathToCell.row]objectForKey:@"id"], @"users", beaconID, @"beacon",  nil] apiMethod:@"beacon/privacy/kick" httpMethod:@"POST"];
    [requestInstance startWithCompletionHandler:^(id response, RadiusError *error){
        
        if (response) {
            
            [self findApprovedList];
        
        }else if (error){
            
            return;
            
        }
        
    }];
    
    
}

-(void) approvePrivacyRequest: (id) sender {
    
    UITableViewCell *owningCell = (UITableViewCell*)[sender superview];
    NSIndexPath *pathToCell = [privacyTableOutlet indexPathForCell:owningCell];
    indexPathOfActionCell = pathToCell;
    
    [privacyTableOutlet cellForRowAtIndexPath:pathToCell].userInteractionEnabled = NO;
    
    NSLog(@" omgz button pressed row at %d and section at %d", pathToCell.row, pathToCell.section);
    
    RadiusRequest *requestInstance = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[pendingRequestsArray objectAtIndex:pathToCell.row] objectForKey:@"id"], @"approve", nil] apiMethod:@"/beacon/privacy/requests" httpMethod:@"POST"];
    [requestInstance startWithCompletionHandler:^(id response, RadiusError *error){
        
        if (response) {

            [self findPendingRequests];
            [self findApprovedList];
            
        }else if (error){
            
            return;
        }
        
        
    }];
    
    
}

-(void) denyPrivacyRequest: (id) sender {
    
    UITableViewCell *owningCell = (UITableViewCell*)[sender superview];
    NSIndexPath *pathToCell = [privacyTableOutlet indexPathForCell:owningCell];
    indexPathOfActionCell = pathToCell;

    [privacyTableOutlet cellForRowAtIndexPath:pathToCell].userInteractionEnabled = NO;

    
    NSLog(@" omgz button pressed row at %d and section at %d", pathToCell.row, pathToCell.section);
    
    RadiusRequest *requestInstance = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[[pendingRequestsArray objectAtIndex:pathToCell.row] objectForKey:@"user"] objectForKey:@"id"], @"deny", nil] apiMethod:@"/beacon/privacy/requests" httpMethod:@"POST"];
    [requestInstance startWithCompletionHandler:^(id response, RadiusError *error){
        
        if (response) {
            
            [self findPendingRequests];

        }else if (error){
            
            return;
        }
        
    }];
    
    
}
#pragma mark Table Cell Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (pendingRequestsArray != nil && [pendingRequestsArray count]>0 && indexPath.section == 0) {
        
        static NSString *MyIdentifier = @"PendingRequestCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        }

        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.textLabel.text = [[[pendingRequestsArray objectAtIndex:indexPath.row] objectForKey:@"user"]objectForKey:@"display_name"];;
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        
        DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[[pendingRequestsArray objectAtIndex:indexPath.row ] objectForKey:@"timestamp"] doubleValue]];
        NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Requested %@",dateString];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        
        
        NSMutableString *urlString = [[[[pendingRequestsArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"picture_thumb"] mutableCopy];
        //        [urlString replaceCharactersInRange:[urlString rangeOfString:@".us/"] withString:@".us/th_"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if (!self.cache) {
            
            self.cache = [[NSMutableDictionary alloc] init];
            
        }
        
        AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) imageURL:url cache:self.cache loadImmediately:YES];
        asyncImageViewInstance.tag = CELL_ASYNC_IMAGE_TAG;
        cell.indentationWidth = asyncImageViewInstance.frame.size.width;
        cell.indentationLevel = 1;
        
        if ([cell viewWithTag:CELL_ASYNC_IMAGE_TAG] != nil) {
            [[cell viewWithTag:CELL_ASYNC_IMAGE_TAG]removeFromSuperview];
        }
        
        [cell addSubview:asyncImageViewInstance];
        
        UIButton *approveButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 10, 30, 30)];
        [approveButton addTarget:self action:@selector(approvePrivacyRequest:) forControlEvents:UIControlEventTouchUpInside];
        [approveButton setImage:[UIImage imageNamed:@"btn_fpp_accept"] forState:UIControlStateNormal];
        [approveButton setTag:APPROVE_BUTTON_TAG];
        approveButton.alpha = 1;
        approveButton.userInteractionEnabled = YES;
        [cell addSubview:approveButton];
        
        UIButton *denyButton = [[UIButton alloc] initWithFrame:CGRectMake(290, 10, 30, 30)];
        [denyButton addTarget:self action:@selector(denyPrivacyRequest:) forControlEvents:UIControlEventTouchUpInside];
        [denyButton setImage:[UIImage imageNamed:@"btn_fpp_decline"] forState:UIControlStateNormal];
        [denyButton setTag:DENY_BUTTON_TAG];
        denyButton.alpha = 1;
        denyButton.userInteractionEnabled = YES;
        [cell addSubview:denyButton];
        
        //        cell.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        
        return cell;
    }
    
    if (preapprovedArray != nil && [preapprovedArray count]>0 && indexPath.section == 1) {
        
        
        static NSString *MyIdentifier = @"PreapprovedCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        }
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.textLabel.text = [[preapprovedArray objectAtIndex:indexPath.row] objectForKey:@"display_name"];
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        
        
        NSInteger numFollowed = [[[preapprovedArray objectAtIndex:indexPath.row] objectForKey:@"num_followed"] integerValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d followed beacon%@",numFollowed,numFollowed==1?@"":@"s"];
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        NSMutableString *urlString = [[[preapprovedArray objectAtIndex:indexPath.row] objectForKey:@"picture_thumb"] mutableCopy];
        //        [urlString replaceCharactersInRange:[urlString rangeOfString:@".us/"] withString:@".us/th_"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if (!self.cache) {
            
            self.cache = [[NSMutableDictionary alloc] init];
            
        }
        
        AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) imageURL:url cache:self.cache loadImmediately:YES];
        asyncImageViewInstance.tag = CELL_ASYNC_IMAGE_TAG;
        cell.indentationWidth = asyncImageViewInstance.frame.size.width;
        cell.indentationLevel = 1;
        
        if ([cell viewWithTag:CELL_ASYNC_IMAGE_TAG] != nil) {
            [[cell viewWithTag:CELL_ASYNC_IMAGE_TAG]removeFromSuperview];
        }
        
        [cell addSubview:asyncImageViewInstance];
        
        UIButton *kickButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 0, 50, 50)];
        [kickButton addTarget:self action:@selector(kickFromPreapprovedList:) forControlEvents:UIControlEventTouchUpInside];
        [kickButton setImage:[UIImage imageNamed:@"btn_fpp_kick"] forState:UIControlStateNormal];
        [kickButton setTag:KICK_BUTTON_TAG];
        kickButton.alpha = 1;
        kickButton.userInteractionEnabled = YES;
        [cell addSubview:kickButton];
        
        return cell;
        
    }
    
    static NSString *MyIdentifier = @"FakeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == privacyTableOutlet) {
        
        if (indexPath.section == 0) {
            
            ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
            //NSString *userIDString = [NSString stringWithFormat:@"%@",[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] ];
            [meProfileController initializeWithUserID:[[[[self.pendingRequestsArray objectAtIndex:indexPath.row] objectForKey:@"user"]objectForKey:@"id"] integerValue]];
            
            [self.navigationController pushViewController:meProfileController animated:YES];
            
        }else if (indexPath.section == 1) {
            
            ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
            //NSString *userIDString = [NSString stringWithFormat:@"%@",[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] ];
            [meProfileController initializeWithUserID:[[[self.preapprovedArray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]];
            
            [self.navigationController pushViewController:meProfileController animated:YES];
            
            
        }
        

    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        if ([pendingRequestsArray count]>0) {
            return [pendingRequestsArray count];
        }else
            return 0;
        
    }else if (section == 1){
        if ([preapprovedArray count]>0) {
            return [preapprovedArray count];
        }else
            return 0;
        
    }

    return 0;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == privacyTableOutlet) {
        return 2;
    }else
        return 1;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
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
    if (tableView == privacyTableOutlet) {
            if (section == 0) {
                label.text = @"Pending Requests";
            }else if (section == 1){
                label.text = @"Approved Users";
            }
        
    }
    [label sizeToFit];
    
    label.frame = CGRectOffset(label.frame, 0, 18-label.frame.size.height/2);
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = .5;
    label.layer.shadowRadius = 1.0;
    
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 30;
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

- (void)viewDidUnload {
    [self setPrivacyTableOutlet:nil];
    [super viewDidUnload];
}
@end
