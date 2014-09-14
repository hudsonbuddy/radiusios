//
//  PostContentView.h
//  radius
//
//  Created by Hud on 8/15/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfileViewController2.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"

@protocol PostContentViewDelegate;

@interface PostContentView : UIView <UITextViewDelegate> {
    
    

}

@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;
@property (strong, nonatomic) IBOutlet UITextView *postTextContentTextView;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) NSString *postSendingBeaconID;
@property (strong, nonatomic) NSString *postContentType;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *userTask;
@property (strong, nonatomic) NSString *postSendingContentID;

@property (nonatomic, assign) id <PostContentViewDelegate> postContentViewDelegate;


- (IBAction)doSomething:(id)sender;

@end

@protocol PostContentViewDelegate <NSObject>

@optional
-(void) reloadBeaconContentDataTable;
-(void) reloadConversationTable;


@end
