//
//  PostBeaconImageURLContent.m
//  Radius
//
//  Created by Hud on 7/30/12.
//
//

#import "PostBeaconImageURLContent.h"

@implementation PostBeaconImageURLContent

@synthesize connectionText, jsonArray, jsonData;
@synthesize postBeaconImageURLContentDelegate;

-(void) postBeaconImageURLContentMethod:(NSNumber*) myNumber :(NSString *)myString {
    
    
    NSLog(@"Posting image url content to the new Beacon");
    NSString *imageURLString = [NSString stringWithFormat:@"http://sc2.pnptsg.com/api/post_image_content"];
    NSLog(@" %@", imageURLString);
    NSURL *urlImage = [NSURL URLWithString:imageURLString];
    NSMutableURLRequest *requestImage = [NSMutableURLRequest requestWithURL:urlImage];
    NSString *imageDataString = [NSString stringWithFormat:@"token=74EQux7jsmRvQP0nvxbK8FUsxuDok9Z3loWRH79IW8d7KtRp07&beacon=%@&image_url=%@", myNumber, myString];

    NSData *imageURLData = [imageDataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *imagePostLength = [NSString stringWithFormat:@"%d", [imageURLData length]];
    [requestImage setHTTPMethod:@"POST"];
    [requestImage setValue:imagePostLength forHTTPHeaderField:@"Content-Length"];
    [requestImage setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requestImage setHTTPBody:imageURLData];
    connectionText = [[NSURLConnection alloc] initWithRequest:requestImage delegate:self startImmediately:YES];
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [jsonData setLength:0];
}

-(void) connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    
    
    NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"this is the image url return content: %@", logString);
    [jsonData appendData:data];
    if ([jsonArray count] != 0) {
        
        if([postBeaconImageURLContentDelegate respondsToSelector:@selector(goToBeacon)]){
            
            [postBeaconImageURLContentDelegate goToBeacon];
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
        
        if([postBeaconImageURLContentDelegate respondsToSelector:@selector(goToBeacon)]){
            
            [postBeaconImageURLContentDelegate goToBeacon];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no content" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
    
    
}



@end
