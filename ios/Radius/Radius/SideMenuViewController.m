//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import <UIKit/UIKit.h>
#import "RadiusRequest.h"

@interface SideMenuViewController()


@end

@implementation SideMenuViewController

@synthesize radiusNavigationArray;
@synthesize radiusNavigationViewArray;
@synthesize lastCellSelected;
@synthesize blackImageArray;
@synthesize whiteImageArray;

- (void)viewDidLoad
{
    [self setupArray];
    [super viewDidLoad];
    //Do other setup here
    self.tableView.scrollEnabled = YES;
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]setSelected:YES];

    UIImage *img = [UIImage imageNamed:@"iphone5_menubkgd@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    backgroundNotificationsView.alpha = 1;
    backgroundNotificationsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.tableView setBackgroundView:backgroundNotificationsView];
    self.tableView.backgroundView.contentMode = UIViewContentModeTop;
    
//    [self.view addSubview:backgroundNotificationsView];
//    [self.view sendSubviewToBack:backgroundNotificationsView];
    
    [self setupCreateBeaconButton];
    
    
    
#ifdef CONFIGURATION_TestFlight
    UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [feedbackButton setImage:[UIImage imageNamed:@"btn_feedback.png"] forState:UIControlStateNormal];
    [feedbackButton addTarget:self action:@selector(feedbackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    feedbackButton.frame = CGRectMake(85,280,100,30);
    feedbackButton.layer.cornerRadius = 5;
    feedbackButton.clipsToBounds = YES;
    feedbackButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:feedbackButton];
#endif
    
}

#ifdef CONFIGURATION_TestFlight
- (void) feedbackButtonPressed {
    [TestFlight openFeedbackView];
}
#endif

- (void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"%@", lastCellSelected);
//    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]]setSelected:YES];
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];

    if (lastCellSelected.row != 2 || lastCellSelected == nil) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.tableView cellForRowAtIndexPath:path].imageView.image = [whiteImageArray objectAtIndex:path.row];
        self.lastCellSelected = path;
    }
    
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //return [NSString stringWithFormat:@"Section %d", section];
    return nil;
}
//// How to modify the headers which divide the sections of the menu (currently just 1 at the top)
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ////    UIImage *menuHeader = [UIImage imageNamed:@"menu_titlebar.png"];
    ////    UIImageView *dividerView = [[UIImageView alloc] initWithImage:menuHeader];
    ////    CGRect headerFrame           = tableView.tableHeaderView.frame;
    ////    UIView *myView = [[UIView alloc] initWithFrame:headerFrame];
    ////    [myView addSubview:dividerView];
    ////
    ////    //set contentMode to scale aspect to fit
    ////    dividerView.contentMode = UIViewContentModeScaleAspectFit;
    //
    ////    //change width of frame
    ////    CGRect frame = dividerView.frame;
    ////    frame.size.width = kSidebarWidth;
    ////    frame.origin = CGPointMake(0,-50);
    ////      frame.size.height = 44;
    ////    dividerView.frame = frame;
    ////    //self.tableView.backgroundColor = [UIColor redColor];
    //    return dividerView;
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,kSidebarWidth,44)];
    tempLabel.backgroundColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1]; //[UIColor clearColor] /*#590900*/;
    //tempLabel.shadowColor = [UIColor blackColor];
    //tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1];
    tempLabel.font = [UIFont fontWithName:@"Quicksand" size:32];
    tempLabel.textAlignment = UITextAlignmentCenter;
    tempLabel.text=@"RADIUS";
    [tempView addSubview:tempLabel];
    [tempLabel release];
    return tempView;
    //return nil;

}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(void) setupArray {
    
    radiusNavigationArray = [[NSMutableArray alloc] init];
    [radiusNavigationArray addObject:@"Search"];
    [radiusNavigationArray addObject:@"News Feed"];
    [radiusNavigationArray addObject:@"Discover"];
    [radiusNavigationArray addObject:@"Me"];
    [radiusNavigationArray addObject:@"Friends"];

    
    radiusNavigationViewArray = [[NSMutableArray alloc] init];
    [radiusNavigationViewArray addObject:@"searchViewID"];
    [radiusNavigationViewArray addObject:@"newsFeedID"];
    [radiusNavigationViewArray addObject:@"mapViewID"];
    [radiusNavigationViewArray addObject:@"meProfileViewID2"];
    [radiusNavigationViewArray addObject:@"friendsID"];

    
    blackImageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:[UIImage imageNamed:@"ico_search.png"],
                                                      [UIImage imageNamed:@"ico_followed.png"], [UIImage imageNamed:@"ico_discover.png"],
                                                      [UIImage imageNamed:@"ico_me.png"], [UIImage imageNamed:@"ico_friends.png"],
                                                      nil]];
    
    whiteImageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:[UIImage imageNamed:@"ico_search_white.png"],
                                                      [UIImage imageNamed:@"ico_followed_white.png"], [UIImage imageNamed:@"ico_discover_white.png"],
                                                      [UIImage imageNamed:@"ico_me_white.png"], [UIImage imageNamed:@"ico_friends_white.png"],
                                                      nil]];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.radiusNavigationArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.row == 4) {
//        return 100;
//    }else
//        return 44;
    
    return 44;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 5) {
        
    
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            UIView *bgColorView = [[UIView alloc] init];
            [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
            [cell setSelectedBackgroundView:bgColorView];
            [bgColorView release];
            
            cell.imageView.image = [blackImageArray objectAtIndex:indexPath.row];

        }
        
        cell.textLabel.text = [self.radiusNavigationArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:22.0];
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else {
        return nil;
    }
}

-(void) createBeacon {
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"createCheckExistingID"];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
}

-(void) setupCreateBeaconButton {
    
    UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(35, self.view.frame.size.height-84-44, 200, 100)];
    [createButton addTarget:self action:@selector(createBeacon) forControlEvents:UIControlEventTouchUpInside];
    [createButton setImage:[UIImage imageNamed:@"btn_createbeacon@2x.png"] forState:UIControlStateNormal];
    [self.tableView addSubview:createButton];
    [self.tableView bringSubviewToFront:createButton];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        [tableView cellForRowAtIndexPath:indexPath].imageView.image = [whiteImageArray objectAtIndex:indexPath.row];
    }
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        [tableView cellForRowAtIndexPath:indexPath].imageView.image = [blackImageArray objectAtIndex:indexPath.row];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 5) {
    
    //Setting the image back to black when unselected
    if (lastCellSelected != nil)
    {
        [tableView cellForRowAtIndexPath:lastCellSelected].imageView.image = [blackImageArray objectAtIndex:lastCellSelected.row];
    }
    lastCellSelected = [indexPath copy];
        
    [tableView cellForRowAtIndexPath:indexPath].imageView.image = [whiteImageArray objectAtIndex:indexPath.row];
    
    UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:[self.radiusNavigationViewArray objectAtIndex:indexPath.row]];
    demoController.title = [NSString stringWithFormat:@"%@",[self.radiusNavigationArray objectAtIndex:indexPath.row]];
    
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
        
    }
}

@end
