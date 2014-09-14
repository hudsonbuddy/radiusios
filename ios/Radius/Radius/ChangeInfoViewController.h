//
//  ChangeInfoViewController.h
//  Radius
//
//  Created by Fred Ehrsam on 10/5/12.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
#import "RadiusViewController.h"

@protocol ChangeInfoDelegate;


@interface ChangeInfoViewController : RadiusViewController

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentTextField;
@property (weak, nonatomic) IBOutlet UILabel *enterNewLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterNewTextField;
@property (weak, nonatomic) IBOutlet UILabel *retypeNewLabel;
@property (weak, nonatomic) IBOutlet UITextField *retypeNewTextField;

@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@property (weak, nonatomic) NSString *fieldToChange;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@property (nonatomic, assign) id <ChangeInfoDelegate> changeInfoDelegateProperty;
@property (weak, nonatomic) IBOutlet UIView *currentView;
@property (weak, nonatomic) IBOutlet UIView *nuView;

@property (weak, nonatomic) IBOutlet UIView *retypeView;

@end

@protocol ChangeInfoDelegate <NSObject>

@optional
-(void) changeInfoBasedOnString: (NSString *)changedString withFieldToChange: (NSString *)fieldToChangeArgument;

@end