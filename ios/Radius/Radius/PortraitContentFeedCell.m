//
//  FeedCell.m
//  Radius
//
//  Created by Fred Ehrsam on 9/19/12.
//
//

#import "PortraitContentFeedCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PortraitContentFeedCell
@synthesize mainPictureButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PortraitContentFeedCell" owner:self options:nil];
        //[self addSubview:self.backgroundView];
        
        self.backgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_nfp_photocell.png"]];
        //self.backgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"thetest.png"]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //[self setButtonImagesRoundedRects];
        [self setupFonts];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) setButtonImagesRoundedRects
{
    CALayer *layer = [mainPictureButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10.0];
}

-(void) setupFonts
{
//    self.descriptionTextView.font = [UIFont fontWithName:@"Quicksand" size:descriptionTextView.font.pointSize];
    [self.timePostedLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
    [self.distanceLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.timePostedLabel.font.pointSize]];
    [self.beaconNameLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.timePostedLabel.font.pointSize]];
    [self.numberOfFollowersLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.timePostedLabel.font.pointSize]];
}


@end
