//
//  PostBeaconVideoURLContent.h
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import <Foundation/Foundation.h>

@protocol PostBeaconVideoURLContentDelegate;

@interface PostBeaconVideoURLContent : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connectionText;
@property(strong, nonatomic) NSMutableArray *jsonArray;

@property (nonatomic, assign) id <PostBeaconVideoURLContentDelegate> postBeaconVideoURLContentDelegate;

-(void) postBeaconVideoURLContentMethod:(NSNumber*) myNumber :(NSString *)myString;

@end

@protocol PostBeaconVideoURLContentDelegate <NSObject>

@optional

-(void) goToBeacon;

@end





