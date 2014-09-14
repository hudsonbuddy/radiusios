//
//  LoginViewController.h
//  Radius
//
//  Created by Hud on 7/17/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusViewController.h"

@interface LoginViewController : RadiusViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    UIButton *facebookLoginButton;
}

@property (strong, nonatomic, retain) UITextField *emailTextField;
@property (strong, nonatomic, retain) UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *loginMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (IBAction)submitCredentialsButton:(id)sender;
- (IBAction)FBLoginPressed:(id)sender;
- (IBAction)forgotPasswordPressed:(id)sender;

@end
