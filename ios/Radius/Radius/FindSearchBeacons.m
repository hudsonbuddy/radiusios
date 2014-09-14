//
//  FindSearchBeacons.m
//  Radius
//
//  Created by Hud on 8/9/12.
//
//

#import "FindSearchBeacons.h"

@implementation FindSearchBeacons

@synthesize jsonData, connection, jsonArray;

@synthesize findSearchBeaconsDelegate;

-(void)findSearchBeaconsMethod:(NSString *)mySearchString {
    
    NSLog(@"Finding search beacons");
    NSString *urlString =[NSString stringWithFormat:@"http://sc2.pnptsg.com/api/search?q=%@", mySearchString];
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
    NSLog(@"this is the search beacons: %@", logString);
    [jsonData appendData:data];
    //    if ([jsonArray count] != 0) {
    //
    //        if([findCommentsDelegate respondsToSelector:@selector(populateCommentsTable:)]){
    //
    //            [findCommentsDelegate populateCommentsTable: jsonArray];
    //        }
    //    }
    
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
        
        if([findSearchBeaconsDelegate respondsToSelector:@selector(populateSearchTable:)]){
            NSLog(@"sending search table");
            [findSearchBeaconsDelegate populateSearchTable: jsonArray];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this content has no comments" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
}


@end
