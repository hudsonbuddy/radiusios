//
//  ChangeInfoViewController.m
//  Radius
//
//  Created by Fred Ehrsam on 10/5/12.
//
//

#import "ChangeInfoViewController.h"
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "PopupView.h"
#import "RadiusRequest.h"

@interface ChangeInfoViewController ()
@property (nonatomic) CGFloat animatedDistance;
@end

@implementation ChangeInfoViewController
@synthesize currentLabel, currentTextField;
@synthesize enterNewLabel, enterNewTextField;
@synthesize retypeNewLabel, retypeNewTextField;
@synthesize fieldToChange;
@synthesize errorMessageLabel;
@synthesize changeButton;
@synthesize animatedDistance;
@synthesize changeInfoDelegateProperty;
@synthesize currentView, nuView, retypeView;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static NSDictionary *fieldsToNamesDict = nil;

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
	// Do any additional setup after loading the view.
    [self initFieldCodesToNames];
    [self setupSideMenuBarButtonItem];
    [self setupFonts];
    [self populateFieldsAndLabels];
    [self setupChangeButton];
    
    //Initialize the single tap recognizer
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapRecognizer];
    
    UIImage *img = [UIImage imageNamed:@"bkgd_login.png"];
    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    backgroundNotificationsView.alpha = 0.3;
    [self.view addSubview:backgroundNotificationsView];
    [self.view sendSubviewToBack:backgroundNotificationsView];
}

-(void)initFieldCodesToNames {
    if (fieldsToNamesDict == nil) {
        fieldsToNamesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"password", @"password",
                             @"name", @"display_name",
                             @"email", @"email",
                             nil];
    }
}

-(NSString *)getNameOfFieldWithCode:(NSString *)fieldCode withCapital:(BOOL)isCapitalized
{
    NSString *fieldName = [fieldsToNamesDict objectForKey:fieldCode];
    if (isCapitalized)
    {
        fieldName = [fieldCode stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[fieldName substringToIndex:1] uppercaseString]];
    }
    return fieldName;
}

-(void)populateFieldsAndLabels
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([fieldToChange isEqualToString:@"password"])
    {
        self.title = @"Password";
        currentLabel.text = @"Current Password";
        currentTextField.placeholder = @"current password";
        currentTextField.secureTextEntry = YES;
        enterNewLabel.text = @"New Password";
        enterNewTextField.placeholder = @"enter new password";
        enterNewTextField.secureTextEntry = YES;
        retypeNewLabel.text = @"Confirm New Password";
        retypeNewTextField.placeholder = @"retype new password";
        retypeNewTextField.secureTextEntry = YES;
        
    }
    else if ([fieldToChange isEqualToString:@"display_name"])
    {
        self.title = @"Change Name";
        currentLabel.text = @"Current Display Name";
        [currentTextField setEnabled:NO];
        RadiusRequest *radRequest = [RadiusRequest requestWithAPIMethod:@"me"];
        [radRequest startWithCompletionHandler:^(id result, RadiusError *error) {
            currentTextField.text = [result objectForKey:@"display_name"];//[defaults objectForKey:@"display_name"];
        }];
        currentTextField.borderStyle = UITextBorderStyleNone;
        enterNewLabel.text = @"New Display Name";
        enterNewTextField.placeholder = @"enter new display name";
        retypeNewLabel.text = @"Confirm New Display Name";
        retypeNewTextField.placeholder = @"retype new display name";
    }
    else if ([fieldToChange isEqualToString:@"email"])
    {
        self.title = @"Change Email";
        currentLabel.text = @"Current Email";
        [currentTextField setEnabled:NO];
        RadiusRequest *radRequest = [RadiusRequest requestWithAPIMethod:@"me"];
        [radRequest startWithCompletionHandler:^(id result, RadiusError *error) {
            currentTextField.text = [result objectForKey:@"email"];//[defaults objectForKey:@"display_name"];
        }];

        enterNewLabel.text = @"New Email";
        enterNewTextField.placeholder = @"enter new email";
        retypeNewLabel.text = @"Confirm New Email";
        retypeNewTextField.placeholder = @"retype new email";
    }
    [errorMessageLabel setHidden:YES];
    //Set backgrounds of fields
    [self.currentView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normhigh.png"]]];
    [self.nuView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normmid.png"]]];
    [self.retypeView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"fld_normlow.png"]]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == currentTextField && ([fieldToChange isEqualToString:@"display_name"] || [fieldToChange isEqualToString:@"email"])) {
        return NO;
    }
    return YES;
}

-(void)setupFonts
{
    [currentLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:currentLabel.font.pointSize]];
    [currentTextField setFont:[UIFont fontWithName:@"Quicksand" size:currentTextField.font.pointSize]];
    [enterNewLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:enterNewLabel.font.pointSize]];
    [enterNewTextField setFont:[UIFont fontWithName:@"Quicksand" size:enterNewTextField.font.pointSize]];
    [retypeNewLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:retypeNewLabel.font.pointSize]];
    [retypeNewTextField setFont:[UIFont fontWithName:@"Quicksand" size:retypeNewTextField.font.pointSize]];
    [errorMessageLabel setFont:[UIFont fontWithName:@"Quicksand" size:errorMessageLabel.font.pointSize]];
}

-(void)setupChangeButton
{
    if ([fieldToChange isEqualToString:@"password"]) [changeButton setBackgroundImage:[UIImage imageNamed:@"btn_set_passwordchange.png"] forState:UIControlStateNormal];
    else if ([fieldToChange isEqualToString:@"display_name"]) [changeButton setBackgroundImage:[UIImage imageNamed:@"btn_set_namechange.png"] forState:UIControlStateNormal];
    else if ([fieldToChange isEqualToString:@"email"]) [changeButton setBackgroundImage:[UIImage imageNamed:@"btn_set_emailchange.png"] forState:UIControlStateNormal];
}

- (IBAction)changeButtonPressed:(id)sender
{
    if ([fieldToChange isEqualToString:@"password"]) {
        [self changePassword];
    }else{
        [self sendChangeRequest];
    }
}

-(void)sendChangeRequest
{
//    UIView *dimViewForButton = [[UIView alloc] initWithFrame:changeButton.frame];
//    dimViewForButton.backgroundColor = [UIColor blackColor];
//    dimViewForButton.alpha = 0.6;
//    [changeButton addSubview:dimViewForButton];
    changeButton.enabled = NO;
    
    //Make sure the two text fields are the same
    if ([enterNewTextField.text isEqualToString:retypeNewTextField.text] && enterNewTextField.text != @"" && enterNewTextField.text != nil)
    {
        [errorMessageLabel setHidden:YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"token"], @"token", enterNewTextField.text, fieldToChange, nil] apiMethod:@"me/update" httpMethod:@"POST"];
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
         {
             if (error)
             {
                 [errorMessageLabel setText:error.message];
                 [errorMessageLabel setHidden:NO];
             }
             else
             {
                 PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
                 [popupAlert setupWithDescriptionText:[NSString stringWithFormat:@"Your %@ has been changed", [self getNameOfFieldWithCode:fieldToChange withCapital:NO]] andButtonText:@"OK"];
                 SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                 void (^cancelOrDoneBlock)() = ^{
                     // we must manually slide out the view out if we specify this block
                     [MFSlidingView slideOut];
                 };
                 [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                 
                 //Save the changes in NSUserDefaults
                 [defaults setObject:enterNewTextField.text forKey:fieldToChange];
                 //Transition back to the settings page
                 
                 if ([changeInfoDelegateProperty respondsToSelector:@selector(changeInfoBasedOnString:withFieldToChange:)]) {
                     
                     [changeInfoDelegateProperty changeInfoBasedOnString:enterNewTextField.text withFieldToChange:fieldToChange];
                 }
                 
                 [self.navigationController popViewControllerAnimated:YES];
                 changeButton.alpha = 1;
                 changeButton.enabled = YES;
             }
             changeButton.enabled = YES;
         }];
    }
    else
    {
        [errorMessageLabel setText:@"Your fields don't match!"];
        [errorMessageLabel setHidden:NO];
        changeButton.enabled = YES;
    }
}

-(void) changePassword{
    
    if ([enterNewTextField.text isEqualToString:retypeNewTextField.text] && ![enterNewTextField.text isEqualToString:@""] && ![currentTextField.text isEqualToString:@""] && ![retypeNewTextField.text isEqualToString:@""])
    {
        [errorMessageLabel setHidden:YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: currentTextField.text, @"old_password", enterNewTextField.text, @"new_password", nil] apiMethod:@"me/update" httpMethod:@"POST"];
        [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
         {
             if (error)
             {
                 [errorMessageLabel setText:error.message];
                 [errorMessageLabel setHidden:NO];
             }
             else
             {
                 PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
                 [popupAlert setupWithDescriptionText:[NSString stringWithFormat:@"Your %@ has been changed", [self getNameOfFieldWithCode:fieldToChange withCapital:NO]] andButtonText:@"OK"];
                 SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                 void (^cancelOrDoneBlock)() = ^{
                     // we must manually slide out the view out if we specify this block
                     [MFSlidingView slideOut];
                 };
                 [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                 
                 //Save the changes in NSUserDefaults
                 [defaults setObject:enterNewTextField.text forKey:fieldToChange];
                 //Transition back to the settings page
                 
                 if ([changeInfoDelegateProperty respondsToSelector:@selector(changeInfoBasedOnString:withFieldToChange:)]) {
                     
                     [changeInfoDelegateProperty changeInfoBasedOnString:enterNewTextField.text withFieldToChange:fieldToChange];
                 }
                 
                 [self.navigationController popViewControllerAnimated:YES];
                 changeButton.alpha = 1;
                 changeButton.enabled = YES;
             }
             changeButton.enabled = YES;
         }];
    }
    else
    {
        [errorMessageLabel setText:@"Your fields don't match!"];
        [errorMessageLabel setHidden:NO];
        changeButton.enabled = YES;
    }
    
    
}

//Handle single taps such that they hide the keyboard
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

// Code to move the view focus down with each text field
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

// Handles actions upon pressing return in text fields
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == self.retypeNewTextField)
    {
        [theTextField resignFirstResponder];
        [self sendChangeRequest];
    }
    else if (theTextField == self.currentTextField)
    {
        [self.enterNewTextField becomeFirstResponder];
    }
    else if (theTextField == self.enterNewTextField)
    {
        [self.retypeNewTextField becomeFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCurrentLabel:nil];
    [self setCurrentTextField:nil];
    [self setRetypeNewLabel:nil];
    [self setRetypeNewTextField:nil];
    [self setEnterNewLabel:nil];
    [self setEnterNewTextField:nil];
    [self setErrorMessageLabel:nil];
    [self setChangeButton:nil];
    [self setCurrentView:nil];
    [self setRetypeView:nil];
    [self setNuView:nil];
    [self setCurrentTextField:nil];
    [super viewDidUnload];
}

@end
