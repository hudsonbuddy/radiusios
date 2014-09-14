//
//  RadiusViewController.m
//  radius
//
//  Created by David Herzka on 11/9/12.
//
//

#import "RadiusViewController.h"
#import "MFSideMenu.h"
#import "RadiusRequest.h"

@interface RadiusViewController () {
    UIView *loadingOverlay;
    UIView *badConnectionWarning;
    
    // requests made while view is active that should be canceled if view is popped
    NSMutableArray *requests;
}

@property (strong,nonatomic) void(^onAppear)(void);

@end

@implementation RadiusViewController

@synthesize hasAppeared = _hasAppeared;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
}

-(void)viewDidAppear:(BOOL)animated
{    
    [super viewDidAppear:animated];
    _hasAppeared = YES;
    if(self.onAppear) {
        self.onAppear();
    }
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self dismissLoadingOverlay];
    [self dismissBadConnectionWarning];
    _hasAppeared = NO;
    
    if(self.navigationController == nil) {
        // hopefully, we're only in here if the view has been popped
        if(requests) {
            for(RadiusRequest *r in requests) {
                [r cancel];
            }
        }
    }
}

-(void)performOnAppear:(void (^)(void))block
{
    if(self.hasAppeared) {
        block();
    } else {
        self.onAppear = block;
    }
}

-(void)showBadConnectionWarning
{
    if(badConnectionWarning) return;
    
    badConnectionWarning = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar_noconnection"]];
    badConnectionWarning.frame = CGRectMake(0,-badConnectionWarning.frame.size.height,badConnectionWarning.frame.size.width,badConnectionWarning.frame.size.height);
    
    loadingOverlay.hidden = YES;
    [self.view addSubview:badConnectionWarning];
    
    [UIView animateWithDuration:0.5 animations:^{
        badConnectionWarning.frame = CGRectOffset(badConnectionWarning.frame, 0, badConnectionWarning.frame.size.height);
    }];
    
}

-(void)dismissBadConnectionWarning
{
    if(!badConnectionWarning) return;
    
    [UIView animateWithDuration:0.5 animations:^{
        badConnectionWarning.frame = CGRectOffset(badConnectionWarning.frame, 0, -badConnectionWarning.frame.size.height);
    }];
    
    [badConnectionWarning removeFromSuperview];
    loadingOverlay.hidden = NO;
    badConnectionWarning = nil;
    
//    [self refresh];
    
}

-(void)showLoadingOverlay
{
    if(loadingOverlay) return;
    
    loadingOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    loadingOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    myIndicator.frame = CGRectMake(loadingOverlay.center.x - 20,
                                   loadingOverlay.center.y - 20,
                                   40,
                                   40);
    [loadingOverlay addSubview:myIndicator];
    [myIndicator startAnimating];
    [self.view addSubview:loadingOverlay];

}

-(void)dismissLoadingOverlay
{
    if(!loadingOverlay) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingOverlay removeFromSuperview];
        loadingOverlay = nil;
    });
}

-(void)cancelRequestOnPop:(RadiusRequest *)request
{
    if(!requests) {
        requests = [[NSMutableArray alloc] init];
    }
    [requests addObject:request];
}

-(void)refresh
{
    [self viewDidLoad];
}


@end
