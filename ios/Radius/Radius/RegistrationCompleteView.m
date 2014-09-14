//
//  RegistrationCompleteView.m
//  Radius
//
//  Created by Fred Ehrsam on 9/28/12.
//
//

#import "RegistrationCompleteView.h"
#import "TourViewController.h"
#import "MapViewController.h"


@implementation RegistrationCompleteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"RegistrationCompleteView" owner:self options:nil];
        //[self addSubview:self.backgroundView];
        
        self.panelBackgroundView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_login_newuser.png"]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)takeATourPressed
{
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TourViewController *tourController = [myStoryboard instantiateViewControllerWithIdentifier:@"TourViewID"];
    UIViewController * myController = [self firstAvailableUIViewController];
//    [myController.navigationController.navigationBar setHidden:YES];

//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
    [myController.navigationController.navigationBar setHidden:YES];
    [[myController.navigationController.navigationBar.subviews lastObject]removeFromSuperview];
    [myController.navigationController pushViewController:tourController animated:YES];

}

- (IBAction)getStartedPressed:(id)sender
{
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MapViewController *mapController = [myStoryboard instantiateViewControllerWithIdentifier:@"mapViewID"];
    mapController.showSuggestions = YES;
    UIViewController *myController = [self firstAvailableUIViewController];
    //    [myController.navigationController.navigationBar setHidden:YES];
    
    //    [[myController.view.subviews lastObject] removeFromSuperview];
    //    [[myController.view.subviews lastObject] removeFromSuperview];
    //    [[myController.view.subviews lastObject] removeFromSuperview];
    //    [[myController.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
    [[myController.navigationController.navigationBar.subviews lastObject]removeFromSuperview];
//    [myController.navigationController pushViewController:mapController animated:YES];
    
    NSArray *controllers = [NSArray arrayWithObject:mapController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

@end
