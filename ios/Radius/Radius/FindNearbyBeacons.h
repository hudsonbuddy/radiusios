//
//  FindNearbyBeacons.h
//  Radius
//
//  Created by Hud on 7/31/12.
//
//

#import <Foundation/Foundation.h>

@protocol FindNearbyBeaconsDelegate;

@interface FindNearbyBeacons : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connectionText;
@property(strong, nonatomic) NSMutableArray *jsonArray;

@property (nonatomic, assign) id <FindNearbyBeaconsDelegate> findNearbyBeaconsDelegate;

-(void) findNearbyBeaconsMethod:(float)latitude :(float)longitude;



@end


@protocol FindNearbyBeaconsDelegate <NSObject>

@optional
-(void) populateTableView: (NSMutableArray *)myArray;
-(void) populateMapAnnotations: (NSMutableArray *)myArray;


@end