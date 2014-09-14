//
//  FindNearbyBeacons.m
//  Radius
//
//  Created by Hud on 7/31/12.
//
//

#import "FindNearbyBeacons.h"

@implementation FindNearbyBeacons

@synthesize connectionText, jsonArray, jsonData;
@synthesize findNearbyBeaconsDelegate;

-(void) findNearbyBeaconsMethod:(float) latitude :(float) longitude {
    
    NSLog(@"Finding nearby Beacons");
    NSString *urlString =[NSString stringWithFormat:@"http://sc2.pnptsg.com/api/beacons?lat=%f&lng=%f&max_beacons=40", latitude, longitude];
    NSLog(@" %@", urlString);
    jsonData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    connectionText = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self startImmediately:YES];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [jsonData setLength:0];
}

-(void) connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    
//    NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"this is the find nearby beacons: %@", logString);
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
    
    
    self.jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSString *firstBeacon= [jsonArray objectAtIndex:0];
    NSLog(@"The first Beacon is %@", firstBeacon);
    
    if ([jsonArray count] != 0) {
        
        if([findNearbyBeaconsDelegate respondsToSelector:@selector(populateTableView:)]){
            
            [findNearbyBeaconsDelegate populateTableView:jsonArray];
        }
        
        if ([findNearbyBeaconsDelegate respondsToSelector:@selector(populateMapAnnotations:)]) {
            [findNearbyBeaconsDelegate populateMapAnnotations:jsonArray];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no content" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
    
    
}



@end
