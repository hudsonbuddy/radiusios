//
//  ThreadCreatorSettingsView.m
//  radius
//
//  Created by Hud on 11/28/12.
//
//

#import "ThreadCreatorSettingsView.h"

@implementation ThreadCreatorSettingsView
@synthesize threadID;
@synthesize beaconIDString, beaconNameString;
@synthesize deleteThreadButtonOutlet;

static const CGFloat DELETE_ALERTVIEW_TAG = 100;


-(void) setupThreadCreatorSettingsView{
    
    self.deleteThreadButtonOutlet.layer.cornerRadius = 5;
    self.deleteThreadButtonOutlet.titleLabel.font = [UIFont fontWithName:@"Quicksand" size:18.0];
    self.deleteThreadButtonOutlet.titleLabel.textColor = [UIColor whiteColor];
    
}

- (IBAction)deleteThreadButtonPressed:(id)sender {
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"This thread will be gone forever" delegate:self cancelButtonTitle:@"Yes, delete" otherButtonTitles:@"Whoops!", nil];
    av.tag = DELETE_ALERTVIEW_TAG;
    [av show];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == DELETE_ALERTVIEW_TAG) {
        
        
        if (buttonIndex == 0) {
            
            NSLog(@"Deleting Content");
            
            RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:threadID, @"thread", nil] apiMethod:@"conversation/thread/delete" httpMethod:@"POST"];
            
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


@end
