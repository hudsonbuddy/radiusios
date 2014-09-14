//
//  ContentCreatorSettingsView.m
//  radius
//
//  Created by Hud on 11/20/12.
//
//

#import "ContentCreatorSettingsView.h"

@implementation ContentCreatorSettingsView

@synthesize contentIDString;
@synthesize userIsContentCreator;
@synthesize deleteFlagButton;
@synthesize beaconIDString;
@synthesize beaconNameString;

static const CGFloat DELETE_ALERTVIEW_TAG = 100;
static const CGFloat FLAG_ALERTVIEW_TAG = 200;


- (IBAction)deleteFlagButtonPressed:(id)sender {
    
    if (userIsContentCreator) {
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"This content will be gone forever" delegate:self cancelButtonTitle:@"Yes, delete" otherButtonTitles:@"Whoops!", nil];
        av.tag = DELETE_ALERTVIEW_TAG;
        [av show];
    }else{
        
        [self flagContentAsInappropriate];
        
    }
    

    
}

-(void) flagContentAsInappropriate{
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"This content will be flagged as inappropriate" delegate:self cancelButtonTitle:@"Yes, I'm sure" otherButtonTitles:@"Whoops!", nil];
    av.tag = FLAG_ALERTVIEW_TAG;
    
    [av show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == DELETE_ALERTVIEW_TAG) {
        
    
        if (buttonIndex == 0) {
            
            NSLog(@"Deleting Content");
            
            RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentIDString, @"content_id", nil] apiMethod:@"content/delete" httpMethod:@"POST"];
            
            [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
             {
                 [MFSlidingView slideOut];
                 NSLog(@"%@", response);
                 
                 
                 BeaconContentViewController2 *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"beaconContentID3"];
                 [demoController initializeWithBeaconID:beaconIDString];
                 
                 demoController.title = [NSString stringWithFormat:@"%@", beaconNameString];
                 
                 NSArray *controllers = [NSArray arrayWithObject:demoController];
                 
                 [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
                 [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
                 
             }];
        }else if (buttonIndex == 1){
            
            NSLog(@"Going back to beacon settings");
            [MFSlidingView slideOut];

            
        }
        
    }else if (alertView.tag == FLAG_ALERTVIEW_TAG){
        
        if (buttonIndex == 0) {

        
            RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:contentIDString, @"content_id", nil] apiMethod:@"content/flag" httpMethod:@"POST"];
            
            [radRequest startWithCompletionHandler:^(id response, RadiusError *error)
             {
                 [MFSlidingView slideOut];
                 NSLog(@"%@", response);
                 
             }];
        }else if (buttonIndex == 1){
            
            NSLog(@"Going back to beacon settings");
            [MFSlidingView slideOut];
            
            
        }
        
        
    }
    
    
}

- (void) setupContentCreatorSettingsView{
    
    if (userIsContentCreator == YES) {
        [deleteFlagButton setImage:[UIImage imageNamed:@"btn_cs_delete@2x.png"] forState:UIControlStateNormal];
    }else if (userIsContentCreator == NO){
        [deleteFlagButton setImage:[UIImage imageNamed:@"btn_cs_flag@2x.png"] forState:UIControlStateNormal];
    }else {
        [deleteFlagButton setImage:[UIImage imageNamed:@"btn_cs_flag@2x.png"] forState:UIControlStateNormal];
    }
    
}

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

@end
