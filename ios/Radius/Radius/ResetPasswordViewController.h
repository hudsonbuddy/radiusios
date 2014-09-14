//
//  ResetPasswordViewController.h
//  radius
//
//  Created by David Herzka on 11/11/12.
//
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;

- (IBAction)resetPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end
