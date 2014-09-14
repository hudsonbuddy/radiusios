//
//  FindBeaconInfo.h
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import <Foundation/Foundation.h>

@protocol FindBeaconInfoDelegate;

@interface FindBeaconInfo : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connection;
@property(strong, nonatomic) NSDictionary *jsonArray;
@property (strong, nonatomic) NSString *userTokenString;

@property (nonatomic, assign) id <FindBeaconInfoDelegate> findBeaconInfoDelegate;

-(void) findBeaconInfo:(int)beaconID;


@end


@protocol FindBeaconInfoDelegate <NSObject>


@optional
-(void) updateBeaconInfo: (NSDictionary *) myDictionary;

@end