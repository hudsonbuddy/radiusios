//
//  PopupView.m
//  Radius
//
//  Created by Fred Ehrsam on 11/4/12.
//
//

#import "PopupView.h"
#import "MFSlidingView.h"

@implementation PopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)primaryButtonPressed:(id)sender
{
    [MFSlidingView slideOut];
    if(self.doneBlock) {
        self.doneBlock();
    }
}

-(void) setupWithDescriptionText:(NSString *) description andButtonText:(NSString *) buttonText doneBlock:(void(^)()) doneBlock
{
    [self.messageLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.messageLabel.font.pointSize]];
//    self.messageLabel.minimumScaleFactor = 0.5;
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.primaryButton.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.primaryButton.titleLabel.font.pointSize]];
    [self.messageLabel setText:description];
    [self.primaryButton.titleLabel setText:buttonText];
    
    self.doneBlock = doneBlock;
}

-(void) setupWithDescriptionText:(NSString *) description andButtonText:(NSString *) buttonText
{
    [self setupWithDescriptionText:description andButtonText:buttonText doneBlock:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
