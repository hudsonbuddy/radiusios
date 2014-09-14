//
//  RadiusRequest.h
//  radius
//
//  Created by David Herzka on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import "RadiusError.h"

@protocol RadiusRequestDelegate;

typedef void(^RadiusResponseHandler)(id result, RadiusError *error);
typedef void(^RadiusResponseFailureHandler)(NSError *error);

@interface RadiusRequest : NSObject <NSURLConnectionDataDelegate>

+(RadiusRequest *) requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod;
+(RadiusRequest *) requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod httpMethod:(NSString *)httpMethod;
+(RadiusRequest *) requestWithAPIMethod:(NSString *)apiMethod;
+(RadiusRequest *) requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod multipartData:(id)data,... NS_REQUIRES_NIL_TERMINATION;

+(NSString *)token;
+(void) setToken:(NSString *)token;
+(void) setRequestDelegate:(id<RadiusRequestDelegate>)delegate;
+(BOOL) lowConnection;

-(void) start;
-(void) startWithCompletionHandler:(RadiusResponseHandler)handler;
-(void) startWithCompletionHandler:(RadiusResponseHandler)completionHandler failureHandler:(RadiusResponseFailureHandler)failureHandler;

-(void) cancel;
-(void) retry;

@property (strong,nonatomic) NSURLRequest *underlyingRequest;
@property (strong,nonatomic) id <NSURLConnectionDataDelegate> dataDelegate;

@end


@protocol RadiusRequestDelegate <NSObject>

-(void)radiusRequestDidDetectRecoveredConnection:(RadiusRequest *)request;
-(void)radiusRequestDidDetectBadConnection:(RadiusRequest *)request errorCode:(NSInteger)urlError;
-(void)radiusRequestDidFailWithBadToken:(RadiusRequest *)request;

@optional
-(void)radiusRequestDidFail:(RadiusRequest *)request;



@end

