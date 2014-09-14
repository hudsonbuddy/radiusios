//
//  ThreadCreatorSettingsView.h
//  radius
//
//  Created by Hud on 11/28/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"
#import "MFSlidingView.h"
#import "BeaconContentViewController2.h"

@interface ThreadCreatorSettingsView : UIView <UIAlertViewDelegate>

@property (strong, nonatomic) NSString *threadID;
@property (strong, nonatomic) NSString *beaconIDString;
@property (strong, nonatomic) NSString *beaconNameString;

@property (strong, nonatomic) IBOutlet UIButton *deleteThreadButtonOutlet;
- (IBAction)deleteThreadButtonPressed:(id)sender;

-(void) setupThreadCreatorSettingsView;

@end
