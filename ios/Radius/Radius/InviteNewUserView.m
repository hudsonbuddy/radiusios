//
//  InviteNewUserView.m
//  Radius
//
//  Created by Fred Ehrsam on 10/19/12.
//
//

#import "InviteNewUserView.h"
#import <QuartzCore/QuartzCore.h>
#import "MFSlidingView.h"

@implementation InviteNewUserView
@synthesize fbID;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        [[NSBundle mainBundle] loadNibNamed:@"InviteNewUserView" owner:self options:nil];
        [self.nameLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.nameLabel.font.pointSize]];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (IBAction)closePressed:(id)sender
{
    [self removeFromSuperview];
    //    UIViewController *myController = [self firstAvailableUIViewController];
    //
    //    [[myController.view.subviews lastObject] removeFromSuperview];
    //    [[myController.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
}

-(void)setUserProfileTo:(NSString *) displayName withPicture:(UIImage *)profilePicture
{
    self.name = displayName;
    self.nameLabel.text = self.name;
    self.profileImage = profilePicture;
    [self.profilePictureButton setImage:self.profileImage forState:UIControlStateNormal];
    CALayer *layer = [self.profilePictureButton.imageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0];
}

- (IBAction)sendInvitePressed:(id)sender
{
    [self showInviteDialog];
}

- (void)showInviteDialog {
        
    Facebook *f = [[Facebook alloc] initWithAppId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"] andDelegate:nil];
    if([[FBSession activeSession] isOpen]) {
        f.accessToken = [FBSession activeSession].accessToken;
        f.expirationDate = [FBSession activeSession].expirationDate;
    }
    
    if (fbID != 0)
    {
        NSLog(@"%@",[NSString stringWithFormat:@"%@",fbID]);
        [f dialog:@"apprequests" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Come join Radius and tune in to your favorite places!", @"message", [NSString stringWithFormat:@"%@",fbID], @"to", nil] andDelegate:self];
    }
    else
    {
        [f dialog:@"apprequests" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Come join Radius and tune in to your favorite places!", @"message", nil] andDelegate:self];
    }
    
    [MFSlidingView slideOut];
}

@end
