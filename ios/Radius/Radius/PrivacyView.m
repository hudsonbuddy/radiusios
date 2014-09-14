//
//  PrivacyView.m
//  radius
//
//  Created by Hud on 1/3/13.
//
//

#import "PrivacyView.h"

@implementation PrivacyView
@synthesize privacyButtonOutlet, privacyLabelOutlet;
@synthesize backgroundImageViewOutlet;
@synthesize currentPrivacySetting, beaconID;


- (IBAction)privacyButtonPressed:(id)sender {
    
    if ([currentPrivacySetting isEqualToString:@"restricted"]) {
        
        privacyButtonOutlet.userInteractionEnabled = NO;
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:beaconID ,@"beacon",nil] apiMethod:@"beacon/privacy/request" httpMethod:@"POST"];
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            // deal with response object
            if ([[response objectForKey:@"success"]boolValue] == YES) {
                
                privacyButtonOutlet.userInteractionEnabled = YES;
                [self setCurrentPrivacySetting:@"requested"];
                [self setupPrivacyViewWithArgument:@"requested"];

            }
        }];

        
    }else if ([currentPrivacySetting isEqualToString:@"requested"]) {
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Requested" message:@"You have already tried to request access. Please wait until the owner approves your request" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        

        
    }
    
}

-(void) initializePrivacyView {
    
    [privacyButtonOutlet.titleLabel setFont:[UIFont fontWithName:@"Quicksand-Bold" size:16]];
    [privacyLabelOutlet setFont:[UIFont fontWithName:@"Quicksand" size:16]];
    [privacyLabelOutlet setTextAlignment:NSTextAlignmentCenter];
    [privacyLabelOutlet setTextColor:[UIColor whiteColor]];
    [privacyLabelOutlet setNumberOfLines:5];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.privacyButtonOutlet setBackgroundColor:[UIColor clearColor]];
    
}

-(void) setupPrivacyViewWithArgument: (NSString *)privacyArgument {
    
    
    if ([privacyArgument isEqualToString:@"restricted"]) {
        
//        [privacyButtonOutlet setTitle:@"Request Access" forState:UIControlStateNormal];
        [privacyButtonOutlet setImage:[UIImage imageNamed:@"btn_bvp_requestaccess"] forState:UIControlStateNormal];
        [privacyLabelOutlet setText:@"This Beacon is Private. You must request access from the owner before you can view this beacon"];

    }else if ([privacyArgument isEqualToString:@"requested"]) {
        
//        [privacyButtonOutlet setTitle:@"Access Requested" forState:UIControlStateNormal];
            [privacyButtonOutlet setImage:[UIImage imageNamed:@"btn_bvp_requested"] forState:UIControlStateNormal];
        [privacyLabelOutlet setText:@"This Beacon is Private. You must wait until the owner approves your request."];
        
        
    }else if ([privacyArgument isEqualToString:@"banned"]) {
        
        [privacyButtonOutlet setHidden:YES];
        [privacyButtonOutlet setUserInteractionEnabled:NO];
        [privacyLabelOutlet setText:@"This Beacon is Private. You are banned."];
        
        
    }
    
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


@end
