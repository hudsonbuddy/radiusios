//
//  RegisterViewController.h
//  Radius
//
//  Created by Fred Ehrsam on 8/3/12.
//
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "RegistrationCompleteView.h"
#import "RadiusViewController.h"
#import "MFSlidingView.h"

@interface RegisterViewController : RadiusViewController <UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

-(void) setInitialValues:(NSDictionary *)initial;
- (IBAction)chooseProfilePicture:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) NSDictionary *fieldValuesForKeys;
@property (weak, nonatomic) NSDictionary *twitterLoginInfo;
@property (weak, nonatomic) IBOutlet UIButton *termsOfServiceButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@end


