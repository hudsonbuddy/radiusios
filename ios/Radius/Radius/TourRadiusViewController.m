//
//  TourRadiusViewController.m
//  radius
//
//  Created by Hud on 9/27/12.
//
//

#import "TourRadiusViewController.h"
#import "Flurry.h"
#import "MapViewController.h"

@interface TourRadiusViewController ()

@end

@implementation TourRadiusViewController
@synthesize getStartedButtonOutlet;
@synthesize tourView;
@synthesize pageNumber;

-(void) setupTourImagesWithPageNumber:(int)pageNumberInstance {
    
    NSLog(@"%f", self.view.frame.size.height);
    if (self.view.frame.size.height >500) {
        tourView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, 320, 400)];

    }else{
        tourView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 400)];

    }
    
    NSString *pageNumberImageString = [NSString stringWithFormat:@"pnl_tour_page%d@2x.png",pageNumberInstance];
    
    UIImageView *tourImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:pageNumberImageString]];
    tourImageView.frame = CGRectMake(tourView.frame.origin.x, tourView.frame.origin.y, tourView.frame.size.width, tourView.frame.size.height);
    [tourView addSubview:tourImageView];
    [self.view addSubview:tourView];
    
    
}

-(void) setupSwipeGestures {
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [tourView addGestureRecognizer:swipeRightRecognizer];
    [tourView addGestureRecognizer:swipeLeftRecognizer];
    
    
}

- (void) handleSwipeLeft: (UISwipeGestureRecognizer *)sender {
    

    if (pageNumber != 6 && pageNumber < 6) {

    NSLog(@"swiped left going forward");
        pageNumber++;
        [self setupGetStartedButton];
        
        [[tourView.subviews lastObject]removeFromSuperview];
        NSString *pageNumberImageString = [NSString stringWithFormat:@"pnl_tour_page%d@2x.png",pageNumber];
        
        UIImageView *tourImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:pageNumberImageString]];
        tourImageView.transform = CGAffineTransformMakeScale(0,0);
        tourImageView.frame = CGRectMake(0, 0, 0, tourImageView.frame.size.height);
        [tourView addSubview:tourImageView];
        
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             
                             tourImageView.transform = CGAffineTransformIdentity;
                             
                             tourImageView.frame = CGRectMake(tourView.frame.origin.x, tourView.frame.origin.y, tourView.frame.size.width, tourView.frame.size.height);
                             
                             
                         }completion:^(BOOL finished) {
                             
                         }];
        
        
//        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        [[tourView.subviews lastObject]removeFromSuperview];
//
//        NSString *pageNumberImageString = [NSString stringWithFormat:@"pnl_tour_page%d@2x.png",pageNumber];
//        
//        UIImageView *tourImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:pageNumberImageString]];
//        tourImageView.frame = CGRectMake(tourView.frame.origin.x, tourView.frame.origin.y, tourView.frame.size.width, tourView.frame.size.height);
//        [tourView addSubview:tourImageView];
//        [UIView commitAnimations];


    }
}

- (void) handleSwipeRight: (UISwipeGestureRecognizer *)sender {
    
    if (pageNumber != 1 && pageNumber > 1) {
        NSLog(@"swiped right going back");
        pageNumber--;
        [self setupGetStartedButton];
        [[tourView.subviews lastObject]removeFromSuperview];
        NSString *pageNumberImageString = [NSString stringWithFormat:@"pnl_tour_page%d@2x.png",pageNumber];
        
        UIImageView *tourImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:pageNumberImageString]];
        tourImageView.transform = CGAffineTransformMakeScale(0,0);
        tourImageView.frame = CGRectMake(0, 0, 0, tourImageView.frame.size.height);
        tourImageView.alpha = 0;
        [tourView addSubview:tourImageView];

        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {

                             tourImageView.transform = CGAffineTransformIdentity;
                             tourImageView.alpha = 1;
                             tourImageView.frame = CGRectMake(tourView.frame.origin.x, tourView.frame.origin.y, tourView.frame.size.width, tourView.frame.size.height);
 
                             
                         }completion:^(BOOL finished) {
                             
                         }];
        
//        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        [[tourView.subviews lastObject]removeFromSuperview];
//        
//        NSString *pageNumberImageString = [NSString stringWithFormat:@"pnl_tour_page%d@2x.png",pageNumber];
//        
//        UIImageView *tourImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:pageNumberImageString]];
//        tourImageView.frame = CGRectMake(tourView.frame.origin.x, tourView.frame.origin.y, tourView.frame.size.width, tourView.frame.size.height);
//        [tourView addSubview:tourImageView];
//        [UIView commitAnimations];

    }
}

-(void) setupGetStartedButton {
    
    if (pageNumber == 6) {
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        UIImage *letsGoExploring = [UIImage imageNamed:@"btn_tour_exploring@2x.png"];
        [getStartedButtonOutlet setImage:letsGoExploring forState:UIControlStateNormal];
        getStartedButtonOutlet.frame = CGRectMake(60, self.getStartedButtonOutlet.frame.origin.y, 200, 40);
        [UIView commitAnimations];

        
        
    }else if (pageNumber < 6 && pageNumber >= 1){
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        UIImage *getStartedImage = [UIImage imageNamed:@"btn_tour_next@2x.png"];
        [getStartedButtonOutlet setImage:getStartedImage forState:UIControlStateNormal];
        getStartedButtonOutlet.frame = CGRectMake(60, self.getStartedButtonOutlet.frame.origin.y, 200, 40);
        [UIView commitAnimations];


    }
    
    
}

- (void)viewDidLoad
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Started the Tour"];
#endif
    [Flurry logEvent:@"Toured" timed:YES];
    
    
    [super viewDidLoad];

//    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
//    
//    UIImageView *backgroundNotificationsView = [[UIImageView alloc] init];
//    backgroundNotificationsView.alpha = 01.0;
//    backgroundNotificationsView.backgroundColor = [UIColor blackColor];
//    
//    [self.view addSubview:backgroundNotificationsView];
//    [self.view sendSubviewToBack:backgroundNotificationsView];
    [self.view setBackgroundColor:[UIColor blackColor]];

    
    [self setPageNumber:1];
    [self setupGetStartedButton];
    [self setupTourImagesWithPageNumber:pageNumber];
    [self setupSwipeGestures];

	// Do any additional setup after loading the view.
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)getStartedButtonPressed:(id)sender {
    
    if (pageNumber < 6 && pageNumber >= 1){
        
        pageNumber++;
        [self setupGetStartedButton];
        
        [[tourView.subviews lastObject]removeFromSuperview];
        NSString *pageNumberImageString = [NSString stringWithFormat:@"pnl_tour_page%d@2x.png",pageNumber];
        
        UIImageView *tourImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:pageNumberImageString]];
        tourImageView.transform = CGAffineTransformMakeScale(0,0);
        tourImageView.frame = CGRectMake(0, 0, 0, tourImageView.frame.size.height);
        tourImageView.alpha = 0;
        [tourView addSubview:tourImageView];
        
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^ {
                             
                             tourImageView.transform = CGAffineTransformIdentity;
                             tourImageView.alpha = 1;
                             tourImageView.frame = CGRectMake(tourView.frame.origin.x, tourView.frame.origin.y, tourView.frame.size.width, tourView.frame.size.height);
                             
                             
                         }completion:^(BOOL finished) {
                             
                         }];
        
        
        
        
    }else if (pageNumber == 6) {
        
        [Flurry endTimedEvent:@"Toured" withParameters:nil];
    
        UIViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                            instantiateViewControllerWithIdentifier:@"mapViewID"];
        demoController.title = [NSString stringWithFormat:@"Discover"];
    
        [(MapViewController *)demoController setShowSuggestions:YES];
        
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
        [MFSideMenuManager sharedManager].navigationController.navigationBar.hidden = NO;

    }
}
@end
