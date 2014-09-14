//
//  AddNewContentView.h
//  radius
//
//  Created by Hud on 10/2/12.
//
//

#import <UIKit/UIKit.h>
#import "PostContentView.h"
#import "NotificationsFind.h"
#import "RadiusProgressView.h"

@class BeaconContentViewController2;

@interface AddNewContentView : UIView <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    
}

@property (strong, nonatomic) NSString *addNewContentViewBeaconID;
@property (strong, nonatomic) NSString *test;
@property (strong, nonatomic) BeaconContentViewController2 *beaconContentViewController;

- (IBAction)postLinkButtonPressed:(id)sender;
- (IBAction)uploadPictureButtonPressed:(id)sender;
- (IBAction)takePictureButtonPressed:(id)sender;
- (IBAction)postImageLinkButtonPressed:(id)sender;
- (IBAction)postVideoLinkButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *takeAPhotoButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *mediaLibraryButtonOutlet;

@end
