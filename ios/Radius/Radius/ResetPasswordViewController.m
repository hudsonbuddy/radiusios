//
//  ResetPasswordViewController.m
//  radius
//
//  Created by David Herzka on 11/11/12.
//
//

#import "ResetPasswordViewController.h"
#import "RadiusRequest.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController
@synthesize resetButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupStyle];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self.emailField action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tgr];
}

- (void)setupStyle
{
//    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkgd_login.png"]];
    
    UIImage *img = [UIImage imageNamed:@"iphone5_bkgd_login@2x.png"];
    
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    backgroundNotificationsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    backgroundNotificationsView.alpha = 1;
    
    [self.view addSubview:backgroundNotificationsView];
    [self.view sendSubviewToBack:backgroundNotificationsView];
    
    self.emailField.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:self.emailField.font.pointSize];
    self.errorLabel.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:self.errorLabel.font.pointSize];
    self.successLabel.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:self.successLabel.font.pointSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEmailField:nil];
    [self setResetButton:nil];
    [self setCancelButton:nil];
    [self setErrorLabel:nil];
    [self setSuccessLabel:nil];
    [super viewDidUnload];
}

- (IBAction)resetPressed:(id)sender
{
    [resetButton setEnabled:NO];
    [self resetPassword];
}

- (void)resetPassword
{
    [self.emailField resignFirstResponder];
    NSString *email = self.emailField.text;
    
    // validate email
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.+@.+\\..+$" options:0 error:&error];
    if(![regex numberOfMatchesInString:email options:0 range:NSMakeRange(0, email.length)]) {
        [self displayError:@"enter a valid email address"];
        [resetButton setEnabled:YES];
        return;
    }
    
    
    // send reset request
    RadiusRequest *request = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObject:email forKey:@"email"] apiMethod:@"reset_password" httpMethod:@"POST"];
    [request startWithCompletionHandler:^(id result, RadiusError *error) {
        if(error) {
            NSString *message = @"we can't reset your password right now";
            if(error.type==RadiusErrorNoPasswordSet) {
                message = @"log into your account via Facebook";
            } else if(error.type==RadiusErrorUserNotFound ) {
                message = @"we couldn't find a user with that email";
            }
            [self displayError:message];
            [resetButton setEnabled:YES];
        } else {
            self.errorLabel.hidden = YES;
            self.emailField.hidden = YES;
            self.successLabel.hidden = NO;
        }
    }];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resetPassword];
    return YES;
}

- (void) displayError:(NSString *)message {
    self.errorLabel.text = message;
    self.errorLabel.hidden = NO;
}

- (IBAction)cancelPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
