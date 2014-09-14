//
//  PostContentComment.h
//  Radius
//
//  Created by Hud on 8/6/12.
//
//

#import <Foundation/Foundation.h>

@protocol PostContentCommentDelegate;

@interface PostContentComment : NSObject

@property(strong, nonatomic) NSMutableData *jsonData;
@property(strong, nonatomic) NSURLConnection *connectionText;
@property(strong, nonatomic) NSMutableArray *jsonArray;
@property (strong, nonatomic) NSString *userTokenString;

@property (nonatomic, assign) id <PostContentCommentDelegate> postContentCommentDelegate;

-(void) postComment: (NSString *)commentText contentID:(NSString *)contentID;


@end

@protocol PostContentCommentDelegate <NSObject>

@optional
-(void) commentPosted;

@end