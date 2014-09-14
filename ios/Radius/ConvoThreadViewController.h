//
//  ConvoThreadViewController.h
//  Radius
//
//  Created by Fred Ehrsam on 9/6/12.
//
//

#import <UIKit/UIKit.h>
#import "DateAndTimeHelper.h"
#import "ProfileViewController2.h"
#import "RadiusViewController.h"
#import "ThreadCreatorSettingsView.h"

@interface ConvoThreadViewController : RadiusViewController <UITextViewDelegate, UIGestureRecognizerDelegate> {
    NSDictionary *threadDict;
}

@property (nonatomic) NSInteger threadID;
@property (weak, nonatomic) IBOutlet UITableView *convoThreadTable;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteThreadButtonOutlet;
@property (nonatomic) CGFloat animatedDistance;
@property (strong, nonatomic) NSString *userTokenString;
@property (strong, nonatomic) NSString *threadTitle;

@property (strong, nonatomic) NSString *beaconName;
@property (nonatomic) NSInteger beaconID;

@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;

@property (nonatomic) BOOL convoTableIsEditing;
@property (nonatomic, strong) NSIndexPath *indexPathToEditingCell;
@property (nonatomic, strong) UITapGestureRecognizer *tapToStopEditingTapGestureRecognizer;


- (IBAction)deleteThreadButtonPressed:(id)sender;

- (void)initializeWithThreadID:(NSInteger)threadID threadTitle:(NSString *)threadTitle beaconName:(NSString *)beaconName beaconID:(NSInteger)beaconID;

@end
