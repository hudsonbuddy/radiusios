//
//  PostBeaconContent.h
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import <Foundation/Foundation.h>

@protocol PostBeaconTextContentDelegate;

@interface PostBeaconTextContent : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connectionText;
@property(strong, nonatomic) NSMutableArray *jsonArray;

@property (nonatomic, assign) id <PostBeaconTextContentDelegate> postBeaconTextContentDelegate;

-(void) postBeaconTextContentMethod:(NSNumber*) myNumber :(NSString *)myString;

@end

@protocol PostBeaconTextContentDelegate <NSObject>

@optional
-(void) goToBeacon;


@end