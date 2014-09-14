//
//  PostBeaconTags.h
//  Radius
//
//  Created by Hud on 8/6/12.
//
//

#import <Foundation/Foundation.h>

@interface PostBeaconTags : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connectionText;
@property(strong, nonatomic) NSMutableArray *jsonArray;
@property (strong, nonatomic) NSString *userTokenString;


-(void) postBeaconTagsMethod:(NSString *) myTagString theBeaconID:(NSString *)myBeaconID;

@end
