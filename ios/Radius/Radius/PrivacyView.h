//
//  PrivacyView.h
//  radius
//
//  Created by Hud on 1/3/13.
//
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"

@interface PrivacyView : UIView


@property (strong, nonatomic) NSString *currentPrivacySetting;
@property (strong, nonatomic) NSString *beaconID;


@property (strong, nonatomic) IBOutlet UILabel *privacyLabelOutlet;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageViewOutlet;
@property (strong, nonatomic) IBOutlet UIButton *privacyButtonOutlet;
- (IBAction)privacyButtonPressed:(id)sender;


-(void) initializePrivacyView;
-(void) setupPrivacyViewWithArgument: (NSString *)privacyArgument;


@end
