//
//  PostBeaconTags.m
//  Radius
//
//  Created by Hud on 8/6/12.
//
//

#import "PostBeaconTags.h"

@implementation PostBeaconTags

@synthesize connectionText, jsonArray, jsonData, userTokenString;

-(void) postBeaconTagsMethod:(NSString *) myTagString theBeaconID:(NSString *)myBeaconID {
    
    NSLog(@"Posting tags to the new Beacon");
    NSLog(@"%@", myBeaconID);
    
//    int intMyNumber = [myNumber integerValue];
    
    NSString *textURLString = [NSString stringWithFormat:@"http://sc2.pnptsg.com/api/add_tags"];
    NSLog(@" %@", textURLString);
    NSURL *urlText = [NSURL URLWithString:textURLString];
    NSMutableURLRequest *requestText = [NSMutableURLRequest requestWithURL:urlText];
    NSString *textDataString = [NSString stringWithFormat:@"token=%@&beacon=%@&tags=%@",userTokenString, myBeaconID, myTagString];
    NSLog(@" the args: %@", textDataString);
    
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
    NSLog(@"this is the post tag return content: %@", logString);
    [jsonData appendData:data];
    
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
    
    
}


@end
