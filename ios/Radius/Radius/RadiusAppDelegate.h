//
//  RadiusAppDelegate.h
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "RadiusRequest.h"

@class SideMenuViewController;

@interface RadiusAppDelegate : UIResponder <UIApplicationDelegate,RadiusRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SideMenuViewController *sideMenuController;

// FBSample logic
// In this sample the app delegate maintains a property for the current
// active session, and the view controllers reference the session via
// this property, as well as play a role in keeping the session object
// up to date; a more complicated application may choose to introduce
// a simple singleton that owns the active FBSession object as well
// as access to the object by the rest of the application
@property (strong, nonatomic) FBSession *session;
extern NSString *const FBSessionStateChangedNotification;
- (void) openSessionCheckCache:(BOOL)check;
- (void) closeSession;
- (void) setupTitleTicker;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
