//
//  FriendsViewController.m
//  radius
//
//  Created by Hud on 12/17/12.
//
//

#import "FriendsViewController.h"
#import "ProfileViewController2.h"
#import "SearchViewController.h"

@interface FriendsViewController (){
    
    RadiusUserData *_userData;

}
@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation FriendsViewController

@synthesize friendsTableViewOutlet;
static const NSInteger CELL_ASYNC_IMAGE_TAG = 1000;



-(void) initializeFriendsViewController {
    
    [self.friendsTableViewOutlet setDelegate:self];
    [self.friendsTableViewOutlet setDataSource:self];
    _userData = [RadiusUserData sharedRadiusUserData];
    [self showLoadingOverlay];

    [self findFriends];
}
-(void) findFriends {
    
    if (_userData.friends) {
        [self dismissLoadingOverlay];
    }
    
        RadiusRequest *r = [RadiusRequest requestWithParameters:nil apiMethod:@"me/friends" httpMethod:@"GET"];
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if (response) {
                
                NSLog(@"friends response is : %@", response);
                _userData.friends = response;
                [friendsTableViewOutlet reloadData];
                [self dismissLoadingOverlay];
            }

            if (error) {
                NSLog(@"error: %@", error);
                [self dismissLoadingOverlay];

            }
            
        }];
    
    
}

#pragma mark Table Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (_userData.friends.count > 0 && _userData.friends.count > indexPath.row) {
        
        static NSString *MyIdentifier = @"FriendCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        }
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.textLabel.text = [[_userData.friends objectAtIndex:indexPath.row] objectForKey:@"display_name"];
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        
        NSInteger numFollowed = [[[_userData.friends objectAtIndex:indexPath.row] objectForKey:@"num_followed"] integerValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d followed beacon%@",numFollowed,numFollowed==1?@"":@"s"];
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        NSMutableString *urlString = [[[_userData.friends objectAtIndex:indexPath.row] objectForKey:@"picture_thumb"] mutableCopy];
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
        
        //        cell.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        cell.textLabel.text = @"Search for friends from Facebook and Radius!";
        cell.textLabel.numberOfLines = 5;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:18];
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == friendsTableViewOutlet) {
        
        if (_userData.friends.count > 0 && _userData.friends.count > indexPath.row) {
        
            ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
            //NSString *userIDString = [NSString stringWithFormat:@"%@",[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] ];
            [meProfileController initializeWithUserID:[[[_userData.friends objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]];
            
            [self.navigationController pushViewController:meProfileController animated:YES];
            
        } else {
            
            SearchViewController *searchController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchViewID"];
            [searchController setupSideMenuBarButtonItem];
            [searchController setTitle:@"Search"];
            [self.navigationController pushViewController:searchController animated:YES];
            [searchController pressedPeopleButton:nil];
            
            
        }
    }
    

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    if (!_userData.friends) return 0;
    
    if (_userData.friends.count > 0) {
        return [_userData.friends count]+1;
    } else {
        return 1;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if  (_userData.friends.count > 0 && _userData.friends.count > indexPath.row) {
        return 50;
    } else {
        return 70;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeFriendsViewController];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFriendsTableViewOutlet:nil];
    [super viewDidUnload];
}
@end
