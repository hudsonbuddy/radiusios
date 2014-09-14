//
//  ContentCreatorSettingsView.h
//  radius
//
//  Created by Hud on 11/20/12.
//
//

#import <UIKit/UIKit.h>
#import "MFSlidingView.h"
#import "RadiusRequest.h"
#import "BeaconContentViewController2.h"

@interface ContentCreatorSettingsView : UIView <UIAlertViewDelegate>

@property (strong, nonatomic) NSString *contentIDString;
@property (nonatomic) BOOL userIsContentCreator;
@property (strong, nonatomic) IBOutlet UIButton *deleteFlagButton;
- (IBAction)deleteFlagButtonPressed:(id)sender;
@property (strong, nonatomic) NSString *beaconIDString;
@property (strong, nonatomic) NSString *beaconNameString;



-(void) setupContentCreatorSettingsView;

@end
