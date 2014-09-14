//
//  FindComments.h
//  Radius
//
//  Created by Hud on 8/6/12.
//
//

#import <Foundation/Foundation.h>

@protocol FindCommentsDelegate;

@interface FindComments : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connection;
@property(strong, nonatomic) NSMutableArray *jsonArray;

@property (nonatomic, assign) id <FindCommentsDelegate> findCommentsDelegate;

-(void)findCommentsMethod:(NSString *)myContentID;

@end


@protocol FindCommentsDelegate <NSObject>

@optional
-(void) populateCommentsTable:(NSMutableArray *)myArray;

@end