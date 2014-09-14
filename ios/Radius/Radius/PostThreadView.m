//
//  PostThreadView.m
//  radius
//
//  Created by Hud on 10/2/12.
//
//

#import "PostThreadView.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"

@interface PostThreadView() {
    BOOL placeholderSet;
}

@end


@implementation PostThreadView
@synthesize animatedDistance;
@synthesize userTokenString;
@synthesize sendingBeaconID;
@synthesize responseArray, responseDictionary;
@synthesize postThreadViewDelegate;
@synthesize userTaskString;
@synthesize threadContentTextView, threadTitleTextField;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

static const CGFloat DIMVIEW_BLOCKING_TAG = 100;
static const CGFloat POST_THREAD_TAG = 200;
static const CGFloat BUTTON_DIM_TAG = 300;
static const CGFloat ADD_CONTENT_TAG = 400;

- (void)setPlaceholderText {
    placeholderSet = YES;
    self.threadContentTextView.textColor = [UIColor lightGrayColor];
    self.threadContentTextView.text = @"What's going on?";
}

- (void)unsetPlaceholderText {
    placeholderSet = NO;
    self.threadContentTextView.textColor = [UIColor blackColor];
    self.threadContentTextView.text = @"";
}

- (IBAction)postThreadButtonPressed:(id)sender {
    
    if (self.threadTitleTextField.text.length == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Thread Title" message:@"Please type a thread title!" delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }else {
    
        [self.threadContentTextView resignFirstResponder];
        UIViewController *myControllerForOverlay = [self firstAvailableUIViewController];
        RadiusViewController *radiusViewControllerInstance = (RadiusViewController *)myControllerForOverlay;
        
        [radiusViewControllerInstance showLoadingOverlay];
        
        if (self.threadContentTextView.text.length != 0) {
            
            if ([self.threadContentTextView.text isEqualToString:@"What's going on?"]) {
                self.threadContentTextView.text = @" ";
            }
            
            NSLog(@"%@", self.threadContentTextView.text);
            NSLog(@"%@", sendingBeaconID);
            [self.threadContentTextView endEditing:YES];
            
            RadiusRequest *r;
            if (sendingBeaconID)
            {
                r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacon", self.threadContentTextView.text, @"text", self.threadTitleTextField.text, @"title", nil] apiMethod:@"conversation/thread" httpMethod:@"POST"];
            }
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                
                if(error) {
                    return;
                }
                
#ifdef CONFIGURATION_TestFlight
                [TestFlight passCheckpoint:@"Started a Conversation Thread"];
#endif
                NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
                [Flurry logEvent:@"Conversation_Thread_Started" withParameters:eventParameters];
                
                //                [radiusViewControllerInstance dismissLoadingOverlay];
                
                // deal with response object
                NSLog(@"working on creating thread, response is: %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
                
                
                //                UIViewController * myController = [self firstAvailableUIViewController];
                
                
                [postThreadViewDelegate postThreadViewDidCompleteRequest:self];
                
                
            }];
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    
    UIViewController * myController = [self firstAvailableUIViewController];
    [self.threadTitleTextField endEditing:YES];
    
    
    //    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapForTextView:)];
    //    [textView addGestureRecognizer:singleTapRecognizer];
    
    [self catchTapForView:myController.view];
    [self catchTapForView:myController.navigationController.navigationBar];
    
    
    if (placeholderSet) {
        [self unsetPlaceholderText];
    }
    
    CGRect textFieldRect =
    [myController.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect =
    [myController.view.window convertRect:myController.view.bounds fromView:myController.view];
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
    CGRect viewFrame = myController.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [myController.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    NSLog(@"self editing");
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self setPlaceholderText];
    }
    
    UIViewController * myController = [self firstAvailableUIViewController];
    
    CGRect viewFrame = myController.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [myController.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
//        [textView resignFirstResponder];
//        UIViewController *myControllerForOverlay = [self firstAvailableUIViewController];
//        RadiusViewController *radiusViewControllerInstance = (RadiusViewController *)myControllerForOverlay;
//        
//        [radiusViewControllerInstance showLoadingOverlay];
//        
//        if (textView.text.length != 0) {
//            
//            
//            NSLog(@"%@", textView.text);
//            NSLog(@"%@", sendingBeaconID);
//            [textView endEditing:YES];
//            
//            RadiusRequest *r;
//            if (sendingBeaconID)
//            {
//                r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacon", self.threadContentTextView.text, @"text", self.threadTitleTextField.text, @"title", nil] apiMethod:@"conversation/thread" httpMethod:@"POST"];
//            }
//            
//            [r startWithCompletionHandler:^(id response, RadiusError *error) {
//                
////                [radiusViewControllerInstance dismissLoadingOverlay];
//
//                // deal with response object
//                NSLog(@"working on creating thread, response is: %@", response);
//                if ([response isKindOfClass:[NSArray class]]) {
//                    responseArray = response;
//                }else if ([response isKindOfClass:[NSDictionary class]]){
//                    
//                    responseDictionary = response;
//                }
//                
//                
//                //                UIViewController * myController = [self firstAvailableUIViewController];
//                
//                
//                [postThreadViewDelegate postThreadViewDidCompleteRequest:self];
//                
//                        
//            }];
//        }
        // Return FALSE so that the final '\n' character doesn't get added
        return YES;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}


-(void)handleSingleTapForTextView:(UITapGestureRecognizer *)sender
{
    //    UIViewController * myController = [self firstAvailableUIViewController];
    //
    NSLog(@"Tapped");
    //    [myController.view endEditing:YES];
    //    [myController.view removeGestureRecognizer:[myController.view.gestureRecognizers lastObject]];
}

- (void)catchTapForView:(UIView *)view {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    button.tag = BUTTON_DIM_TAG;
    [button addTarget:self action:@selector(dismissButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)dismissButton:(UIButton *)button {
    [self.threadContentTextView endEditing:YES];
    [self.threadTitleTextField endEditing:YES];
    if ([[button superview] isKindOfClass:[UINavigationBar class]]) {
        [button removeFromSuperview];
        UIViewController * myController = [self firstAvailableUIViewController];
        [[[myController.view subviews]lastObject]removeFromSuperview];
        
    }else if ([[button superview] isKindOfClass:[UIView class]]){
        [button removeFromSuperview];
        UIViewController * myController = [self firstAvailableUIViewController];
        [[[myController.navigationController.navigationBar subviews]lastObject]removeFromSuperview];
        
    }
    //    [[self.view.subviews lastObject] removeFromSuperview];
    //    [[self.view.subviews lastObject] removeFromSuperview];
    //    [[self.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
    
    
}

- (void)catchTapForViewForNavBar:(UIView *)view {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    button.tag = BUTTON_DIM_TAG;
    [button addTarget:self action:@selector(dismissButtonFromNavBar:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)dismissButtonFromNavBar:(UIButton *)button {
    [self.threadContentTextView endEditing:YES];
    [self.threadTitleTextField endEditing:YES];
    [button removeFromSuperview];
    //    [[self.view.subviews lastObject] removeFromSuperview];
    //    [[self.view.subviews lastObject] removeFromSuperview];
    //    [[self.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
    
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.threadContentTextView endEditing:YES];
    
    UIViewController * myController = [self firstAvailableUIViewController];
    
    [self catchTapForView:myController.view];
    [self catchTapForView:myController.navigationController.navigationBar];
    
    
    CGRect textFieldRect =
    [myController.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [myController.view.window convertRect:myController.view.bounds fromView:myController.view];
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
    CGRect viewFrame = myController.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [myController.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    NSLog(@"self editing");
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    UIViewController * myController = [self firstAvailableUIViewController];
    
    CGRect viewFrame = myController.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [myController.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(id)initWithSendingBeaconID: (NSString *)theBeaconID andUserTokenString: (NSString *)theUserTokenString
{
    self = [super init];
    if(self) {
        [[NSBundle mainBundle]loadNibNamed:@"PostThreadView" owner:self options:nil];
        [self addSubview:self.view];
        
        self.frame= CGRectMake(10, 100, self.frame.size.width, self.frame.size.height);
        self.backgroundColor = [UIColor clearColor];
        self.threadContentTextView.delegate = self;
        self.threadTitleTextField.delegate = self;
        self.threadContentTextView.returnKeyType = UIReturnKeyDefault;
        self.sendingBeaconID= theBeaconID;
        self.userTokenString = theUserTokenString;
        self.threadContentTextView.font = [UIFont fontWithName:@"Quicksand" size:13.0];
        self.threadTitleTextField.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:13.0];
        self.threadContentTextView.layer.cornerRadius = 5;
        self.tag = POST_THREAD_TAG;
        self.layer.cornerRadius = 15;
        
        [self setPlaceholderText];
        [self.threadContentTextView setKeyboardAppearance:UIKeyboardAppearanceAlert];
        [self.threadTitleTextField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    }
    return self;
}

@end