//
//  ShareToFacebookView.h
//  Radius
//
//  Created by Fred Ehrsam on 10/24/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface ShareToFacebookView : UIView <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *shareOnFBButton;

@property (weak, nonatomic) NSString *contentID;
@property (weak, nonatomic) NSString *beaconID;
@property (weak, nonatomic) NSString *shareContentType;


-(void) setupFBViewWithContentID:(NSString *) cID;
-(void) setupFBViewWithBeaconID: (NSString *) beaconID;

@end
