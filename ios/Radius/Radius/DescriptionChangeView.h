//
//  DescriptionChangeView.h
//  radius
//
//  Created by Hud on 11/17/12.
//
//

#import <UIKit/UIKit.h>
#import "RadiusRequest.h"
#import "MFSlidingView.h"

@interface DescriptionChangeView : UIView <UITextViewDelegate>

@property (strong, nonatomic) NSString *beaconID;
@property (strong, nonatomic) NSString *previousDescriptionString;
@property (strong, nonatomic) NSDictionary *beaconDictionary;


- (IBAction)postButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextViewOutlet;
-(void) setupDescriptionChangeView;

@end
