//
//  FindSearchBeacons.h
//  Radius
//
//  Created by Hud on 8/9/12.
//
//

#import <Foundation/Foundation.h>

@protocol FindSearchBeaconsDelegate;

@interface FindSearchBeacons : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connection;
@property(strong, nonatomic) NSMutableArray *jsonArray;

@property (nonatomic, assign) id <FindSearchBeaconsDelegate> findSearchBeaconsDelegate;

-(void)findSearchBeaconsMethod:(NSString *)mySearchString;

@end

@protocol FindSearchBeaconsDelegate <NSObject>

@optional
-(void) populateSearchTable:(NSMutableArray *)myArray;

@end