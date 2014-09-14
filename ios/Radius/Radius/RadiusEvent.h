//
//  RadiusEvent.h
//  radius
//
//  Created by David Herzka on 10/26/12.
//
//

#import <Foundation/Foundation.h>
#import "FeedCell.h"

@interface RadiusEvent : NSObject

+(RadiusEvent *)eventWithDictionary:(NSDictionary *)eventDictionary;
-(id)initWithDictionary:(NSDictionary *)eventDictionary;

-(FeedCell *)newsFeedCellForTableView:(UITableView *)tableView imageCache:(id)imageCache;
-(CGFloat)newsFeedCellHeight;

-(NSString *)notificationText;

-(NSString *)recentActivityText;

-(UIViewController *)linkViewController;

-(NSString *) eventImageURL;

@property (strong,nonatomic) NSDictionary *performerInfo;
@property (strong,nonatomic) NSDictionary *beaconInfo;
@property (nonatomic) NSUInteger timestamp;
@property (nonatomic) NSUInteger eventID;

@end
