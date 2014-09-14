//
//  SlidingCommentView.h
//  radius
//
//  Created by Hud on 9/6/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "DateAndTimeHelper.h"
#import "AsyncImageView.h"

@protocol SlidingCommentDelegate;

@interface SlidingCommentView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    
    
}
@property (strong, nonatomic) IBOutlet UITableView *SlidingCommentTableViewOutlet;
@property (strong, nonatomic) IBOutlet UITextField *AddCommentTextFieldOutlet;

@property (strong, nonatomic) IBOutlet UIButton *VoteButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *CommentScoreLabelOutlet;
@property (nonatomic, strong) NSString *sendingSlidingContentID;

@property (strong, nonatomic) NSString *postSendingBeaconID;
@property (strong, nonatomic) NSString *postContentType;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userTask;
@property (strong, nonatomic) NSString *postSendingContentID;
@property (strong, nonatomic) NSMutableDictionary *responseDictionary;
@property (strong, nonatomic) NSMutableArray *responseArray;

@property (nonatomic) BOOL contentVotedUp;
@property (nonatomic) BOOL contentVotedDown;
@property (nonatomic) BOOL contentNotVotedYet;

@property (nonatomic) BOOL commentTableIsEditing;
@property (nonatomic, strong) NSIndexPath *indexPathToEditingCell;
@property (nonatomic, strong) UITapGestureRecognizer *tapToStopEditingTapGestureRecognizer;

@property (nonatomic, assign) id <SlidingCommentDelegate> slidingCommentDelegate;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapToDismissGestureRecognizer;

-(IBAction)handleSingleTap:(UITapGestureRecognizer *)sender;
- (IBAction)AddCommentButtonPressed:(id)sender;
- (IBAction)VoteButtonPressed:(id)sender;
-(void) setupDismissCellEditing;
@end

@protocol SlidingCommentDelegate <NSObject>

-(void) incrementCommentScoreUp;
-(void) postCommentMethod;


@end
