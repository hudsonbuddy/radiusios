//
//  UIViewController+MFSideMenu.m
//
//  Created by Michael Frederick on 3/18/12.
//

#import "UIViewController+MFSideMenu.h"
#import "MFSideMenuManager.h"
#import <objc/runtime.h>
#import "NotificationsWindow.h"
#import "RadiusRequest.h"
#import "NotificationsFind.h"
#import "Notification.h"


@class SideMenuViewController;

@interface UIViewController (MFSideMenuPrivate)
- (void)toggleSideMenu:(BOOL)hidden;
@end

@implementation UIViewController (MFSideMenu)

static char menuStateKey;

static const NSInteger TAP_BLOCKER_TAG = 6854;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) toggleSideMenuPressed:(id)sender {
    if(self.navigationController.menuState == MFSideMenuStateVisible) {
        [self.navigationController setMenuState:MFSideMenuStateHidden];
    } else {
        [self.navigationController setMenuState:MFSideMenuStateVisible];
    }
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// We can customize the Menu and Back buttons here
- (void) setupSideMenuBarButtonItem {
//    // Stock code
//    if(self.navigationController.menuState == MFSideMenuStateVisible ||
//       [[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
//        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
//                                                  initWithImage:[UIImage imageNamed:@"btn_logo.png"] style:UIBarButtonItemStyleBordered
//                                                  target:self action:@selector(toggleSideMenuPressed:)] autorelease];
//    } else {
//        NSLog(@"in back section");
//        self.navigationItem.hidesBackButton = YES;
//        self.navigationItem.backBarButtonItem.tintColor = [UIColor greenColor];
//        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
//                                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)] autorelease];
//    }
    //Custom code
    
    if(self.navigationController.menuState == MFSideMenuStateVisible ||
       [[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        UIImage *normalBackImage = [UIImage imageNamed:@"btn_logo.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.bounds = CGRectMake(0, 0, normalBackImage.size.width, normalBackImage.size.height);
        //backButton.bounds = CGRectMake(0, 0, 1, 1);
        [backButton setImage:normalBackImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(toggleSideMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        [backButtonItem release];
    } else {
        UIImage *normalBackImage = [UIImage imageNamed:@"btn_back.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.bounds = CGRectMake(0, 0, normalBackImage.size.width, normalBackImage.size.height);
        
        [backButton setImage:normalBackImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    
        [backButtonItem release];
    }
    
    if(![self.navigationController.navigationBar viewWithTag:TAP_BLOCKER_TAG]) {
        UIView *tapBlocker = [[UIView alloc] initWithFrame:CGRectMake(50,0,self.navigationController.navigationBar.frame.size.width-100,self.navigationController.navigationBar.frame.size.height)];
        NSLog(@"tapBlocked called in class: %@",[self class]);
        tapBlocker.tag = TAP_BLOCKER_TAG;
        [self.navigationController.navigationBar addSubview:tapBlocker];
    }
    
    [self refreshNotificationsIcon];
    [self findNotifications];
}

static NSMutableArray *notifications;

+(void) clearNotifications {
    notifications = nil;
}

-(void) findNotifications {
    NSInteger since;
    if(!notifications || notifications.count == 0) {
        since = 0;
    } else {
        since = [(Notification *)[notifications objectAtIndex:0] id];
    }
    NSString *sinceString = [NSString stringWithFormat:@"%d",since];
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sinceString,@"since",@"all", @"filter", nil] apiMethod:@"me/notifications" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        if(error) {
            // error
            return;
        }
        
        NSMutableArray *notificationsMutable = [[NSMutableArray alloc] init];
        
        int unreadCount = 0;
        for(NSDictionary *notificationDictionary in response) {
            Notification *notification = [Notification notificationWithDictionary:notificationDictionary];
            if(notification) {
                [notificationsMutable addObject:notification];
                if(!notification.isRead) unreadCount++;
            }
        }
        
        if(notifications) {
            [notificationsMutable addObjectsFromArray:notifications];
        }
        notifications = notificationsMutable;
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;

        [self refreshNotificationsIcon];
        
        // if already notifications window open, refresh with latest notifications
        NotificationsWindow *existingWindow = (NotificationsWindow *)[self.view viewWithTag:NOTIFICATION_WINDOW_TAG];
        if(existingWindow) {
            existingWindow.notifications = notifications;
        }
        
    }];
    
}

-(void) refreshNotificationsIcon
{
    int unreadCount = 0;
    for(Notification *n in notifications) {
        unreadCount += n.isRead?0:1;
    }
    
    [self setupNotificationsIcon:unreadCount];
}

-(void) setupNotificationsIcon:(int)unreadCount {
        
    if (unreadCount > 9) {
        NSString *notificationsNumberString = [NSString stringWithFormat:@"9+"];
        NSString *imageNotificationsNumberString= [NSString stringWithFormat:@"btn_note_%@.png", notificationsNumberString];
        UIImage *normalNotificationImage = [UIImage imageNamed:imageNotificationsNumberString];
        UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        notificationButton.bounds = CGRectMake(0, 0, normalNotificationImage.size.width, normalNotificationImage.size.height);
        //backButton.bounds = CGRectMake(0, 0, 1, 1);
        [notificationButton setImage:normalNotificationImage forState:UIControlStateNormal];
        [notificationButton addTarget:self action:@selector(notificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *notificationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = notificationButtonItem;


    }else if (unreadCount == 0) {
        NSString *imageNotificationsNumberString= [NSString stringWithFormat:@"btn_notifications.png"];
        UIImage *normalNotificationImage = [UIImage imageNamed:imageNotificationsNumberString];
        UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        notificationButton.bounds = CGRectMake(0, 0, normalNotificationImage.size.width, normalNotificationImage.size.height);
        //backButton.bounds = CGRectMake(0, 0, 1, 1);
        [notificationButton setImage:normalNotificationImage forState:UIControlStateNormal];
        [notificationButton addTarget:self action:@selector(notificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *notificationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = notificationButtonItem;

    }else {
        NSString *notificationsNumberString = [NSString stringWithFormat:@"%d", unreadCount];
        NSString *imageNotificationsNumberString= [NSString stringWithFormat:@"btn_note_%@.png", notificationsNumberString];
        UIImage *normalNotificationImage = [UIImage imageNamed:imageNotificationsNumberString];
        UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        notificationButton.bounds = CGRectMake(0, 0, normalNotificationImage.size.width, normalNotificationImage.size.height);
        //backButton.bounds = CGRectMake(0, 0, 1, 1);
        [notificationButton setImage:normalNotificationImage forState:UIControlStateNormal];
        [notificationButton addTarget:self action:@selector(notificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *notificationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = notificationButtonItem;
        
    }
    
}

//- (void)handleTapBehind:(UITapGestureRecognizer *)sender
//{
//    NSLog(@"tapped");
////    if (sender.state == UIGestureRecognizerStateEnded)
////    {
////        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
////        
////        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
////        
////        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
////        {
////            // Remove the recognizer first so it's view.window is valid.
////            [self.view.window removeGestureRecognizer:sender];
////            [self dismissModalViewControllerAnimated:YES];
////        }
////    }
//    
//    [[self.view.subviews lastObject] removeFromSuperview];
//    [self.view removeGestureRecognizer:sender];
//}

-(void)notificationButtonPressed:(id)sender {
    //    NotificationsWindow *myNotifications = [[NotificationsWindow alloc] initWithFrame:CGRectMake(0, 0, 274, 242)];
    //    [self.view addSubview:myNotifications];
    
    if (![self.view viewWithTag:NOTIFICATION_WINDOW_TAG]) {
        
        [self drawNotificationsTable];
        
    } else {
        [self dismissNotifications];
    }
    
}

static const int MAIN_DIMVIEW_TAG = 9080;
static const int NAVBAR_DIMVIEW_TAG = 9081;
static const int NOTIFICATION_WINDOW_TAG = 9082;
static const int MAIN_BLOCKBUTTON_TAG = 9083;
static const int NAVBAR_BLOCKBUTTON_TAG = 9084;

-(void) drawNotificationsTable {
    
    NSLog(@"notifications: %@",notifications);
    
    // if already notifications window, don't draw another one
    UIView *existingWindow = [self.view viewWithTag:NOTIFICATION_WINDOW_TAG];
    if(existingWindow) {
        return;
    }
    
    // always hide the side menu
    self.navigationController.menuState = MFSideMenuStateHidden;
    
    NotificationsWindow *customView = [[[NSBundle mainBundle]loadNibNamed:@"NotificationsWindow" owner:self options:nil]objectAtIndex:0];
    customView.frame= CGRectMake(5, 0, self.view.frame.size.width -10, self.view.frame.size.height);
    //customView.backgroundColor = [UIColor clearColor];
    customView.titleLabel.text = @"Notifications";
    customView.titleLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:22];
    customView.notificationsTable.delegate = customView;
    customView.notificationsTable.dataSource = customView;
    
    NSArray *notificationsAtRender = [notifications copy];
    customView.notifications = notificationsAtRender;
    customView.layer.cornerRadius = 15;
    customView.notificationsTable.layer.cornerRadius = 5;
    customView.tag = NOTIFICATION_WINDOW_TAG;
    
    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    backgroundNotificationsView.alpha = 0.5;
    customView.notificationsTable.backgroundView = backgroundNotificationsView;
    customView.notificationsTable.backgroundView.contentMode = UIViewContentModeTop;

    
//    UITapGestureRecognizer *recognizerForSubView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehindAgain:)];
//    [recognizerForSubView setNumberOfTapsRequired:1];
//    recognizerForSubView.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
//    [customView addGestureRecognizer:recognizerForSubView];

    
    UIView *dimView = [[UIView alloc] init];
    dimView.frame= CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    dimView.backgroundColor = [UIColor blackColor];
    dimView.alpha = 0.6;
    dimView.tag = MAIN_DIMVIEW_TAG;
    [self.view addSubview:dimView];
    
    UIView *dimViewForNavBar = [[UIView alloc] init];
    dimViewForNavBar.frame= CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    dimViewForNavBar.backgroundColor = [UIColor blackColor];
    dimViewForNavBar.alpha = 0.6;
    dimViewForNavBar.tag = NAVBAR_DIMVIEW_TAG;
    
    UIPanGestureRecognizer *recognizerToBlock = [[UIPanGestureRecognizer alloc]initWithTarget:self action:nil];
    [dimViewForNavBar addGestureRecognizer:recognizerToBlock];
    [self.navigationController.navigationBar addSubview:dimViewForNavBar];
    
    [self catchNotificationTapForNavBar:dimViewForNavBar];
    [self catchNotificationTapForView:self.view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    
    [self.view addSubview:customView];
    [UIView commitAnimations];
    
    [self markNotificationsRead:notificationsAtRender];
}

- (void) markNotificationsRead:(NSArray *)notifications {
    
    NSMutableString *notificationsIDToMarkRead = [[NSMutableString alloc] initWithString:@""];
    
//    for (Notification *n in theNotifcations) {
//        [notificationsIDToMarkRead stringByAppendingFormat:@"%i,", n.id];
//    }
    
        
    for(int i = 0; i<notifications.count; i++){
        Notification *n = [notifications objectAtIndex:i];
        if(!n.isRead) {
            [notificationsIDToMarkRead appendFormat:@"%d,",n.id];
        }
    }
    
    if(notificationsIDToMarkRead.length > 0) {
        [notificationsIDToMarkRead deleteCharactersInRange:NSMakeRange(notificationsIDToMarkRead.length-1, 1)];
            
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:notificationsIDToMarkRead,@"notifications", nil];
        RadiusRequest *request = [RadiusRequest requestWithParameters:params apiMethod:@"me/notifications/read" httpMethod:@"POST"];
        
        [request start];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self setupNotificationsIcon:0];
    [self findNotifications];
}


- (void)dismissNotifications {
    NotificationsWindow *notificationsWindow = (NotificationsWindow *)[self.view viewWithTag:NOTIFICATION_WINDOW_TAG];
    
    if(notificationsWindow) {
        for(Notification *n in notificationsWindow.notifications) {
            n.isRead = YES; 	
        }
    
        [notificationsWindow removeFromSuperview];
        [[self.view viewWithTag:MAIN_BLOCKBUTTON_TAG] removeFromSuperview];
        [[self.view viewWithTag:MAIN_DIMVIEW_TAG] removeFromSuperview];
        [[self.navigationController.navigationBar viewWithTag:NAVBAR_DIMVIEW_TAG] removeFromSuperview];
        [[self.navigationController.navigationBar viewWithTag:NAVBAR_BLOCKBUTTON_TAG] removeFromSuperview];
    }
}

- (void)catchNotificationTapForView:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    [button addTarget:self action:@selector(dismissNotifications) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MAIN_BLOCKBUTTON_TAG;
    [view addSubview:button];
}

- (void)catchNotificationTapForNavBar:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    [button addTarget:self action:@selector(dismissNotifications) forControlEvents:UIControlEventTouchUpInside];
    button.tag = NAVBAR_BLOCKBUTTON_TAG;
    [view addSubview:button];
}



- (void)setMenuState:(MFSideMenuState)menuState {
    if(![self isKindOfClass:[UINavigationController class]]) {
        self.navigationController.menuState = menuState;
        return;
    }
    
    MFSideMenuState currentState = self.menuState;
    
    objc_setAssociatedObject(self, &menuStateKey, [NSNumber numberWithInt:menuState], OBJC_ASSOCIATION_RETAIN);
    
    switch (currentState) {
        case MFSideMenuStateHidden:
            if (menuState == MFSideMenuStateVisible) {
                [self toggleSideMenu:NO];
                
            }
            break;
        case MFSideMenuStateVisible:
            if (menuState == MFSideMenuStateHidden) {
                [self toggleSideMenu:YES];
            }
            break;
        default:
            break;
    }
}

- (MFSideMenuState)menuState {
    if(![self isKindOfClass:[UINavigationController class]]) {
        return self.navigationController.menuState;
    }
    
    return (MFSideMenuState)[objc_getAssociatedObject(self, &menuStateKey) intValue];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if ([animationID isEqualToString:@"toggleSideMenu"])
    {
        if([self isKindOfClass:[UINavigationController class]]) {
            UINavigationController *controller = (UINavigationController *)self;
            [controller.visibleViewController setupSideMenuBarButtonItem];
            
            // disable user interaction on the current view controller
            controller.visibleViewController.view.userInteractionEnabled = (self.menuState == MFSideMenuStateHidden);
        }
    }
}

@end


@implementation UIViewController (MFSideMenuPrivate)

// TODO: alter the duration based on the current position of the menu
// to provide a smoother animation
- (void) toggleSideMenu:(BOOL)hidden {
    if(![self isKindOfClass:[UINavigationController class]]) return;
    
    [UIView beginAnimations:@"toggleSideMenu" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:kMenuAnimationDuration];
    
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    if (!hidden) {
        switch (self.interfaceOrientation) 
        {
            case UIInterfaceOrientationPortrait:
                frame.origin.x = kSidebarWidth;
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                frame.origin.x = -1*kSidebarWidth;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                frame.origin.y = -1*kSidebarWidth;
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                frame.origin.y = kSidebarWidth;
                break;
        } 
    }
    self.view.frame = frame;
        
    [UIView commitAnimations];
}

@end 
