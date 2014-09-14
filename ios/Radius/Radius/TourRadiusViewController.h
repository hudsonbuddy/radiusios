//
//  TourRadiusViewController.h
//  radius
//
//  Created by Hud on 9/27/12.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu/MFSideMenu.h"
#import "RadiusViewController.h"

@interface TourRadiusViewController : RadiusViewController
@property (strong, nonatomic) IBOutlet UIButton *getStartedButtonOutlet;
- (IBAction)getStartedButtonPressed:(id)sender;
@property (strong, nonatomic) UIView *tourView;
@property (nonatomic) int pageNumber;

@end
