//
//  InviteNewUserView.h
//  Radius
//
//  Created by Fred Ehrsam on 10/19/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusAppDelegate.h"

@interface InviteNewUserView : UIView <FBDialogDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profilePictureButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendInviteButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) UIImage *profileImage;
@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSNumber *fbID;

-(void)setUserProfileTo:(NSString *) displayName withPicture:(UIImage *)profilePicture;

@end
