//
//  BeaconAlreadyMadeView.m
//  Radius
//
//  Created by Fred Ehrsam on 10/24/12.
//
//

#import "BeaconAlreadyMadeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BeaconAlreadyMadeView
@synthesize beaconProfilePictureButton;
@synthesize beaconNameLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setUpWithBeaconPicture:(UIImage *)picture andBeaconName:(NSString *)beaconName
{
    beaconProfilePictureButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [beaconProfilePictureButton setImage:picture forState:UIControlStateNormal];
    
    CALayer *layer = [beaconProfilePictureButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0];
    //[[beaconProfilePictureButton layer] setBorderWidth:1.0f];
    
    [beaconNameLabel setText:beaconName];
    [beaconNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:beaconNameLabel.font.pointSize]];
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
