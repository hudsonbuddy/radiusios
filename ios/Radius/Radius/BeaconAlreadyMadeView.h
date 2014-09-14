//
//  BeaconAlreadyMadeView.h
//  Radius
//
//  Created by Fred Ehrsam on 10/24/12.
//
//

#import <UIKit/UIKit.h>

@interface BeaconAlreadyMadeView : UIView

@property (weak, nonatomic) IBOutlet UIButton *beaconProfilePictureButton;
@property (weak, nonatomic) IBOutlet UILabel *beaconNameLabel;

-(void)setUpWithBeaconPicture:(UIImage *)picture andBeaconName:(NSString *)beaconName;

@end
