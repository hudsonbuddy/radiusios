//
//  PrivacyManagerViewController.h
//  radius
//
//  Created by Hud on 1/3/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RadiusViewController.h"
#import "RadiusRequest.h"

@interface PrivacyManagerViewController : RadiusViewController <UITableViewDataSource, UITableViewDelegate> {
    
    
    
}

@property (strong, nonatomic) NSMutableArray *pendingRequestsArray;
@property (strong, nonatomic) NSMutableArray *preapprovedArray;
@property (strong, nonatomic) NSString *beaconID;
@property (strong, nonatomic) NSIndexPath *indexPathOfActionCell;


@property (strong, nonatomic) IBOutlet UITableView *privacyTableOutlet;

-(void) initializePrivacyManagerViewController;

@end
