//
//  DescriptionChangeView.m
//  radius
//
//  Created by Hud on 11/17/12.
//
//

#import "DescriptionChangeView.h"

@implementation DescriptionChangeView

@synthesize beaconID, previousDescriptionString, beaconDictionary;

static const CGFloat ACTIVITY_INDICATOR_TAG = 500;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (IBAction)postButtonPressed:(id)sender {
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.frame = self.frame;
    aiv.tag = ACTIVITY_INDICATOR_TAG;
    [aiv startAnimating];
    [self addSubview:aiv];
    
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", self.descriptionTextViewOutlet.text, @"description", nil] apiMethod:@"/beacon/update" httpMethod:@"POST"];
    
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
     {
         
         [[self viewWithTag:ACTIVITY_INDICATOR_TAG]removeFromSuperview];
         [MFSlidingView slideOut];
         NSLog(@"%@", response);
         
         UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"New Beacon Description Posted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
         [av show];

         
     }];
    
}

-(void) dismissKeyboardForDescriptionChangeView {
    
    [self.descriptionTextViewOutlet endEditing:YES];
    
    
}

-(void) setupDescriptionChangeView {
    
    
    UITapGestureRecognizer *tapToDismissRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardForDescriptionChangeView)];
    [self addGestureRecognizer:tapToDismissRecognizer];
    
    NSLog(@"%@", beaconDictionary);
    if (![[beaconDictionary objectForKey:@"description"] isEqualToString:@""]) {
        self.descriptionTextViewOutlet.text = [beaconDictionary objectForKey:@"description"];
    }else{
        self.descriptionTextViewOutlet.text = @"Enter a short description!";
    }
    self.descriptionTextViewOutlet.textColor = [UIColor whiteColor];
    self.descriptionTextViewOutlet.backgroundColor = [UIColor clearColor];
    self.descriptionTextViewOutlet.font = [UIFont fontWithName:@"Quicksand" size:self.descriptionTextViewOutlet.font.pointSize];

    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView.text isEqualToString:@"Enter a short description!"]) {
        textView.text = @"";
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView endEditing:YES];
        
        return NO;
        
    }else
        return YES;
}
@end
