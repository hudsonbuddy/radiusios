//
//  FindBeaconContent.h
//  Radius
//
//  Created by Hud on 7/25/12.
//
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

@protocol FindBeaconContentDelegate;

@interface FindBeaconContent : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
}

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connection;
@property(strong, nonatomic) NSMutableArray *jsonArray;
@property(strong, nonatomic) NSString *beaconTextContent;
@property (strong, nonatomic) NSString *userTokenString;




@property (nonatomic, assign) id <FindBeaconContentDelegate> findBeaconContentDelegate;


-(void) findBeaconContent:(int)beaconID;
-(NSString *) returnTextContent;
-(NSString *) returnVideoURLContent;
-(NSString *) returnVideoIDContent;
-(NSString *) returnImageURLContent;
@end



@protocol FindBeaconContentDelegate <NSObject>

@optional
-(void) updateTextData:(NSMutableArray *)myArray;

@end

