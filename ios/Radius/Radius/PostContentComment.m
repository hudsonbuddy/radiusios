//
//  PostContentComment.m
//  Radius
//
//  Created by Hud on 8/6/12.
//
//

#import "PostContentComment.h"

@implementation PostContentComment

@synthesize connectionText, jsonArray, jsonData, userTokenString;
@synthesize postContentCommentDelegate;

-(void) postComment: (NSString *)commentText contentID:(NSString *)contentID {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    
    NSLog(@"Posting comment to the content ID: %@", contentID);
    NSLog(@"%@", commentText);
    
    int intMyNumber = [contentID integerValue];
    
    NSString *textURLString = [NSString stringWithFormat:@"http://sc2.pnptsg.com/api/comment"];
    NSLog(@" %@", textURLString);
    NSURL *urlText = [NSURL URLWithString:textURLString];
    NSMutableURLRequest *requestText = [NSMutableURLRequest requestWithURL:urlText];
    NSString *textDataString = [NSString stringWithFormat:@"token=%@&content_id=%i&text=%@",userTokenString, intMyNumber, commentText];
    
    NSData *textURLData = [textDataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *textPostlength = [NSString stringWithFormat:@"%d", [textURLData length]];
    [requestText setHTTPMethod:@"POST"];
    [requestText setValue:textPostlength forHTTPHeaderField:@"Content-Length"];
    [requestText setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requestText setHTTPBody:textURLData];
    connectionText = [[NSURLConnection alloc] initWithRequest:requestText
                                                     delegate:self startImmediately:YES];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [jsonData setLength:0];
}

-(void) connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    
    
    NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"this is the posting comment content: %@", logString);
    [jsonData appendData:data];
    
    if ([jsonArray count] != 0) {
        
        if([postContentCommentDelegate respondsToSelector:@selector(commentPosted:)]){
            
            [postContentCommentDelegate commentPosted];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no content" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
    
}

-(void)connection:(NSURLConnection *) conn didFailWithError:(NSError *)error {
    
    connectionText = nil;
    jsonData =nil;
    NSString *errorString = [NSString stringWithFormat:@"Fetch Failed: %@", [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    
}

-(void)connectionDidFinishLoading: (NSURLConnection *)conn {
    
    
    //    self.jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if ([jsonArray count] != 0) {
        
        if([postContentCommentDelegate respondsToSelector:@selector(commentPosted)]){
            
            [postContentCommentDelegate commentPosted];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no content" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
    
    
}



@end
