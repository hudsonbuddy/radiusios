//
//  PopupView.h
//  Radius
//
//  Created by Fred Ehrsam on 11/4/12.
//
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *primaryButton;

@property (strong, nonatomic) void(^doneBlock)(void);

-(void) setupWithDescriptionText:(NSString *) description andButtonText:(NSString *) buttonText;

@end
