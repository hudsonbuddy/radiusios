//
//  RadiusContent.h
//  Radius
//
//  Created by Fred Ehrsam on 11/8/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    RadiusContentVoteUp = 1,
    RadiusContentVoteNone = 0,
    RadiusContentVoteDown = -1
} RadiusContentVote;


@interface RadiusContent : NSObject

+(RadiusContent *)contentWithDictionary:(NSDictionary *)contentDictionary;
-(id)initWithDictionary:(NSDictionary *)contentDictionary;
-(void)initializeContentDetailsWithDictionary:(NSDictionary *)contentDetailDictionary;

-(UIViewController *)linkViewController;

@property (nonatomic) NSInteger contentID;
@property (nonatomic, strong) NSDictionary *posterInfo;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic) NSInteger numComments;
@property (nonatomic) NSInteger score;
@property (nonatomic) RadiusContentVote vote;
@property (nonatomic, strong) NSString *description;

@end
