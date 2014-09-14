//
//  PostBeaconImageURLContent.h
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import <Foundation/Foundation.h>


@protocol PostBeaconImageURLContentDelegate;

@interface PostBeaconImageURLContent : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connectionText;
@property(strong, nonatomic) NSMutableArray *jsonArray;

@property (nonatomic, assign) id <PostBeaconImageURLContentDelegate> postBeaconImageURLContentDelegate;

-(void) postBeaconImageURLContentMethod:(NSNumber*) myNumber :(NSString *)myString;

@end

@protocol PostBeaconImageURLContentDelegate <NSObject>

@optional

-(void) goToBeacon;

@end
