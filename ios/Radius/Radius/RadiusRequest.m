//
//  RadiusRequest.m
//  radius
//
//  Created by David Herzka on 8/7/12.
//
//

#import "RadiusRequest.h"
#import "NSString+URLEncoding.h"

@interface RadiusRequest() {
    RadiusResponseHandler _completionHandler;
    RadiusResponseFailureHandler _failureHandler;
    
    NSMutableData *_receivedData;
    
    NSURLConnection *_connection;
}

@end

static BOOL _tokenRejected;
static NSString *_token = nil;
static id<RadiusRequestDelegate> _requestDelegate;
static BOOL _lowConnection;

const static NSString *MULTIPART_BOUNDARY = @"a0z1X2weoif2h030f3hu93ifj9eurhliuhlsidjfnvieurh9384750h298fj49uhf294f93fhisduhf0284hfisudiushf084";

static NSString *DISPOSITION_TEMPLATE = @"Content-Disposition: form-data; name=\"%@\"";

@implementation RadiusRequest

@synthesize underlyingRequest;

/// create a request sent using the POST method and the multipart/form-data content type
/// the data parameter should be a null-terminated list of data, content type, filename, parameter name tuples
+(RadiusRequest *)requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod multipartData:(id)data, ...
{
    RadiusRequest *radiusRequest = [[RadiusRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@%@%@",API_DOMAIN,API_BASE_PATH,apiMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",MULTIPART_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];

    
    if(_token) {
        //params = [NSMutableDictionary dictionaryWithDictionary:params];
        //[params setValue:_token forKey:@"token"];
    } else if (!params) {
        params = [[NSDictionary alloc] init];
    }
    
    NSMutableData *body = [[NSMutableData alloc] init];
    
    // Append parameters
    NSEnumerator *e = params.keyEnumerator;
    NSString *key;
    while((key=e.nextObject)) {
        
        id value = [params objectForKey:key];
    
        NSString *disposition = [NSString stringWithFormat:DISPOSITION_TEMPLATE,key];
        
        [body appendData:[disposition dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n\r\n%@\r\n--%@\r\n",value,MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    }
    
    // Append data
    
    va_list args;
    va_start(args, data);
    id value = data;
    while(1) {
        NSData *d = value;
        if(!d) break;
        NSString *contentType = va_arg(args, NSString *);
        if(!contentType) return nil;
        NSString *fileName = va_arg(args, NSString *);
        if(!fileName) return nil;
        NSString *name = va_arg(args, NSString *);
        if(!name) return nil;
        
        NSString *type = [NSString stringWithFormat:@"Content-Type: %@",contentType];
        NSString *disposition = [NSString stringWithFormat:DISPOSITION_TEMPLATE,name];
        
        [body appendData:[[NSString stringWithFormat:@"%@; filename=\"%@\"\r\n%@\r\n\r\n",disposition,fileName,type] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:d];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        
        value = va_arg(args,id);
    }
    
    if(_token) {
        // Add token to request as cookie
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    API_DOMAIN,NSHTTPCookieDomain,
                                    @"\\",NSHTTPCookiePath,
                                    @"token",NSHTTPCookieName,
                                    _token,NSHTTPCookieValue, nil];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        NSArray *cookies = [NSArray arrayWithObject:cookie];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    }
    
    va_end(args);
    
    request.HTTPBody = body;
    
    NSString * length = [NSString stringWithFormat:@"%d",[body length]];
    [request setValue:length forHTTPHeaderField:@"Content-Length"];
    
    
    radiusRequest.underlyingRequest = request;
    return radiusRequest;
}

+(RadiusRequest *)requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod httpMethod:(NSString *)httpMethod
{
    RadiusRequest *radiusRequest = [[RadiusRequest alloc] init];
    
    NSMutableURLRequest *request;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@%@%@",API_DOMAIN,API_BASE_PATH,apiMethod];
    
    if(_token) {
        //params = [NSMutableDictionary dictionaryWithDictionary:params];
        //[params setValue:_token forKey:@"token"];
    } else if (!params) {
        params = [[NSDictionary alloc] init];
    }
    
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSEnumerator *e = params.keyEnumerator;
    NSString *key;
    BOOL first = YES;
    while((key = e.nextObject)) {
        if (!first) {
            [paramString appendString:@"&"];
        }
        else {
            first = NO;
        }
        id value = [params objectForKey:key];
        if([value isKindOfClass:[NSString class]]) {
            value = [value urlEncodeUsingEncoding:NSUTF8StringEncoding];
        }
        [paramString appendFormat:@"%@=%@",[key urlEncodeUsingEncoding:NSUTF8StringEncoding],value];
    }
    
    if([httpMethod isEqualToString:@"GET"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
        
        request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
    } else if([httpMethod isEqualToString:@"POST"]) {
        NSURL *url = [NSURL URLWithString:urlString];
        request = [NSMutableURLRequest requestWithURL:url];
        
        request.HTTPMethod = @"POST";
        
        NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = body;
        
        NSString *length = [NSString stringWithFormat:@"%d",body.length];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
    } else {
        return nil;
    }
    
    if(_token) {
        // Add token to request as cookie
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    API_DOMAIN,NSHTTPCookieDomain,
                                    @"\\",NSHTTPCookiePath,
                                    @"token",NSHTTPCookieName,
                                    _token,NSHTTPCookieValue, nil];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        NSArray *cookies = [NSArray arrayWithObject:cookie];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    }
    
    radiusRequest.underlyingRequest = request;
    
    return radiusRequest;
}

+(RadiusRequest *)requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod
{
    return [self requestWithParameters:params apiMethod:apiMethod httpMethod:@"GET"];
}

+(RadiusRequest *) requestWithAPIMethod:(NSString *)apiMethod
{
    return [self requestWithParameters:nil apiMethod:apiMethod];
}

+(void)setToken:(NSString *)token {
    _token = token;
    _tokenRejected = NO;
}

+(NSString *)token
{
    return _token;
}

+(void)setRequestDelegate:(id<RadiusRequestDelegate>)delegate
{
    _requestDelegate = delegate;
}

-(void)start
{
    [self startWithCompletionHandler:nil];
}

-(void)startWithCompletionHandler:(RadiusResponseHandler)handler
{
    [self startWithCompletionHandler:handler failureHandler:nil];
}

-(void)startWithCompletionHandler:(RadiusResponseHandler)completionHandler failureHandler:(RadiusResponseFailureHandler)failureHandler
{
    _completionHandler = completionHandler;
    _failureHandler = failureHandler;
    
    _connection = [NSURLConnection connectionWithRequest:self.underlyingRequest delegate:self];
    
    _receivedData = [[NSMutableData alloc] init];
    
    [_connection start];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if([self.dataDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.dataDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([self.dataDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.dataDelegate connection:connection didReceiveResponse:response];
    }
    
    _receivedData.length = 0;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if([self.dataDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.dataDelegate connection:connection didReceiveData:data];
    }
    
    [_receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    

    if([self.dataDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.dataDelegate connectionDidFinishLoading:connection];
    }
    
    if(_lowConnection) {
        _lowConnection = NO;
        if([_requestDelegate respondsToSelector:@selector(radiusRequestDidDetectRecoveredConnection:)]) {
            [_requestDelegate radiusRequestDidDetectRecoveredConnection:self];
        }
    }
    
    NSError *jsonError;
    id response = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if(!response) {
        // bad response from backend
        RadiusError *error = [[RadiusError alloc] initWithType:RadiusErrorBadResponse message:@""];
        
        if(_completionHandler) {
            _completionHandler(nil,error);
        }
        return;
    }
    
    
    if([response isKindOfClass:[NSDictionary class]] && [response objectForKey:@"error"]) {
        RadiusError *error = [[RadiusError alloc] initWithResponseObject:response];
        
        if(error.type == RadiusErrorBadToken) {
            if([_requestDelegate respondsToSelector:@selector(radiusRequestDidFailWithBadToken:)] && !_tokenRejected) {
                [_requestDelegate radiusRequestDidFailWithBadToken:self];
            }
            _tokenRejected = YES;
            return;
        }
        
        if(_completionHandler) {
            _completionHandler(nil,error);
        }
        return;
    }

    
    if(_completionHandler) {
        _completionHandler(response,nil);
    }
    
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if([_dataDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [_dataDelegate connection:connection didFailWithError:error];
    }
    
    if(_failureHandler) {
        _failureHandler(error);
        return;
    } else {
        if(!_lowConnection) {
            _lowConnection = YES;
            if([_requestDelegate respondsToSelector:@selector(radiusRequestDidDetectBadConnection:errorCode:)]) {
                [_requestDelegate radiusRequestDidDetectBadConnection:self errorCode:error.code];
            }
        }
    }
    
    
    // try again after a few seconds
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self retry];
    });
}

-(void)cancel
{
    [_connection cancel];
}

-(void)retry
{
    [self startWithCompletionHandler:_completionHandler];
}

+(BOOL)lowConnection
{
    return _lowConnection;
}


@end
