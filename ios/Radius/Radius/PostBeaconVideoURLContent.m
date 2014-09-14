//
//  PostBeaconVideoURLContent.m
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import "PostBeaconVideoURLContent.h"

@implementation PostBeaconVideoURLContent

@synthesize connectionText, jsonArray, jsonData;
@synthesize postBeaconVideoURLContentDelegate;

-(void) postBeaconVideoURLContentMethod:(NSNumber *) myNumber :(NSString *)myString {
    
    NSLog(@"Posting video url content to the new Beacon");
    NSLog(@"%@", myNumber);
    
    int intMyNumber = [myNumber integerValue];
    
    NSString *textURLString = [NSString stringWithFormat:@"http://sc2.pnptsg.com/api/post_video_content"];
    NSLog(@" %@", textURLString);
    NSURL *urlText = [NSURL URLWithString:textURLString];
    NSMutableURLRequest *requestText = [NSMutableURLRequest requestWithURL:urlText];
    NSString *textDataString = [NSString stringWithFormat:@"token=74EQux7jsmRvQP0nvxbK8FUsxuDok9Z3loWRH79IW8d7KtRp07&beacon=%d&video_url=%@", intMyNumber, myString];
    
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
    NSLog(@"this is the video url return content: %@", logString);
    [jsonData appendData:data];
    
    if ([jsonArray count] != 0) {
        
        if([postBeaconVideoURLContentDelegate respondsToSelector:@selector(goToBeacon)]){
            
            [postBeaconVideoURLContentDelegate goToBeacon];
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
        
        if([postBeaconVideoURLContentDelegate respondsToSelector:@selector(goToBeacon)]){
            
            [postBeaconVideoURLContentDelegate goToBeacon];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no content" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
    
    
}
@end


