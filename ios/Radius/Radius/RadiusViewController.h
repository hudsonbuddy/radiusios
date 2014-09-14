//
//  RadiusViewController.h
//  radius
//
//  Created by David Herzka on 11/9/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusUserData.h"
#import "AsyncImageView.h"
#import "DateAndTimeHelper.h"


@interface RadiusViewController : UIViewController

-(void)showLoadingOverlay;
-(void)dismissLoadingOverlay;

-(void)showBadConnectionWarning;
-(void)dismissBadConnectionWarning;

-(void)performOnAppear:(void(^)(void))block;

// subclasses should override this and do whatever work should be done when
// the application becomes active or recovers from a bad connection
-(void)refresh;

@property (readonly) BOOL hasAppeared;

@end
