//
//  PostThreadView.h
//  radius
//
//  Created by Hud on 10/2/12.
//
//

#import <UIKit/UIKit.h>
#import "NotificationsFind.h"
#import "RadiusRequest.h"
#import "RadiusViewController.h"
#import "MFSlidingView.h"
#import "MFSideMenu.h"

@protocol PostThreadViewDelegate;


@interface PostThreadView : UIView <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *threadTitleTextField;
@property (strong, nonatomic) IBOutlet UITextView *threadContentTextView;
@property (strong, nonatomic) IBOutlet UIButton *postButtonOutlet;
@property (nonatomic) CGFloat animatedDistance;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *sendingBeaconID;
@property (strong, nonatomic) NSMutableDictionary *responseDictionary;
@property (strong, nonatomic) NSMutableArray *responseArray;

@property (nonatomic, assign) id <PostThreadViewDelegate> postThreadViewDelegate;

@property (strong, nonatomic) NSString *userTaskString;

@property (nonatomic, retain) IBOutlet UIView *view;
- (IBAction)postThreadButtonPressed:(id)sender;

-(id)initWithSendingBeaconID: (NSString *)theBeaconID andUserTokenString: (NSString *)theUserTokenString;

@end


@protocol PostThreadViewDelegate <NSObject>

@optional
-(void) postThreadViewDidCompleteRequest:(PostThreadView *)postThreadView;


@end