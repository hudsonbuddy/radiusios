//
//  CreateCheckExistingViewController.h
//  Radius
//
//  Created by Fred Ehrsam on 9/26/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RadiusViewController.h"

@interface CreateCheckExistingViewController : RadiusViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableBackgroundView;
@property (weak, nonatomic) IBOutlet UITableView *existingBeaconTable;
@property (weak, nonatomic) IBOutlet UIButton *nopeButton;
@property (nonatomic, retain) CLLocation* location;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) NSArray *nearbyRadiusBeaconsArray;
@property (strong, nonatomic) NSDictionary *googResponseDict;
@property (strong, nonatomic) NSMutableArray *googPlaces;
@end
