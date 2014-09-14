//
//  FindBeaconInfo.m
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import "FindBeaconInfo.h"

@implementation FindBeaconInfo

@synthesize jsonData, connection, jsonArray, userTokenString;

@synthesize findBeaconInfoDelegate;


-(void)findBeaconInfo:(int)beaconID{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    
    NSLog(@"Finding beacon info");
    NSString *urlString =[NSString stringWithFormat:@"http://sc2.pnptsg.com/api/beacon_info?beacons=%i&token=%@", beaconID,userTokenString];
    NSLog(@" %@", urlString);
    jsonData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [jsonData setLength:0];
}

-(void) connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    
    
    NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"this is the findbeaconinfo: %@", logString);
    [jsonData appendData:data];
    
}

-(void)connection:(NSURLConnection *) conn didFailWithError:(NSError *)error {
    
    connection = nil;
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
    
    
    self.jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if ([jsonArray count] != 0) {
        
        if([findBeaconInfoDelegate respondsToSelector:@selector(updateBeaconInfo:)]){
            
            [findBeaconInfoDelegate updateBeaconInfo: jsonArray];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no info" forKey:@"content"];
        jsonArray = emptyBeaconDiction;
    }
}
@end
