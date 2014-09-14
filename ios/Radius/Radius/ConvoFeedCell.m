//
//  ConvoFeedCell.m
//  Radius
//
//  Created by Fred Ehrsam on 9/26/12.
//
//

#import "ConvoFeedCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ConvoFeedCell

@synthesize threadTitleButton;
@synthesize postTextView;
@synthesize repliesIconButton, repliesTextButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ConvoFeedCell" owner:self options:nil];
        
        [self setupFonts];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.cellView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_nfp_threadcell.png"]];
        [self addSubview:self.cellView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)threadTitleButtonPressed:(id)sender
{
    NSLog(@"thread title button pressed");
}

-(void)setupFonts
{
    [threadTitleButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:threadTitleButton.titleLabel.font.pointSize]];
    [postTextView setFont:[UIFont fontWithName:@"Quicksand" size:postTextView.font.pointSize]];
    [repliesTextButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:repliesTextButton.titleLabel.font.pointSize]];
    threadTitleButton.titleLabel.numberOfLines = 1;
    threadTitleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    threadTitleButton.titleLabel.minimumScaleFactor = .8;
    threadTitleButton.titleLabel.lineBreakMode = UILineBreakModeClip;
    
    postTextView.scrollsToTop = NO;
    
    //    repliesTextButton.titleLabel.numberOfLines = 1;
    //    repliesTextButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    //    repliesTextButton.titleLabel.minimumScaleFactor = .6;
    //    repliesTextButton.titleLabel.lineBreakMode = UILineBreakModeClip;
    
    [self.timePostedLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
    [self.distanceLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.distanceLabel.font.pointSize]];
    [self.beaconNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.beaconNameLabel.font.pointSize]];
    [self.numberOfFollowersLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.numberOfFollowersLabel.font.pointSize]];
}

-(void)resizeForNearbyBanner
{
        [self.threadTitleButton setFrame:CGRectMake(self.threadTitleButton.frame.origin.x, self.threadTitleButton.frame.origin.y, 235, self.threadTitleButton.frame.size.height)];
        [self.postTextView setFrame:CGRectMake(self.postTextView.frame.origin.x, self.postTextView.frame.origin.y, 235, self.postTextView.frame.size.height)];
}

@end
