//
//  ConvoFeedCell.h
//  Radius
//
//  Created by Fred Ehrsam on 9/26/12.
//
//

#import <UIKit/UIKit.h>
#import "FeedCell.h"

@interface ConvoFeedCell : FeedCell

@property (weak, nonatomic) IBOutlet UIButton *threadTitleButton;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

@property (weak, nonatomic) IBOutlet UIButton *repliesIconButton;
@property (weak, nonatomic) IBOutlet UIButton *repliesTextButton;

@property (strong, nonatomic) IBOutlet UIView *cellView;

-(void) resizeForNearbyBanner;


@end
