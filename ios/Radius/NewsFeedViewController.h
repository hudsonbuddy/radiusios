//
//  NewsFeedViewController.h
//  Radius
//
//  Created by Fred Ehrsam on 9/17/12.
//
//

#import <UIKit/UIKit.h>
#import "ConvoFeedCell.h"
#import "FeedCell.h"
#import "PortraitContentFeedCell.h"
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"
#import "ConvoThreadViewController.h"
#import "RadiusViewController.h"

@interface NewsFeedViewController : RadiusViewController <CLLocationManagerDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *followedButton;
@property (weak, nonatomic) IBOutlet UIButton *nearbyButton;
@property (weak, nonatomic) IBOutlet UIButton *topButton;

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@property (nonatomic, retain) CLLocationManager* locationManager;

@end
