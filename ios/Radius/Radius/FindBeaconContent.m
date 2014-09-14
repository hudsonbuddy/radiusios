//
//  FindBeaconContent.m
//  Radius
//
//  Created by Hud on 7/25/12.
//
//

#import "FindBeaconContent.h"
#import "MFSlidingView.h"
#import "PopupView.h"

@implementation FindBeaconContent 

@synthesize jsonData, connection, jsonArray, beaconTextContent;

@synthesize findBeaconContentDelegate;
@synthesize userTokenString;

-(void)findBeaconContent:(int)beaconID{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    
    NSLog(@"Finding beacon content");
    NSString *urlString =[NSString stringWithFormat:@"http://sc2.pnptsg.com/api/beacon_content?beacon=%i&token=%@", beaconID, userTokenString];
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
    NSLog(@"this is the beacon content: %@", logString);
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
    
    PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
    [popupAlert setupWithDescriptionText:@"Sorry, your Facebook account is already connected to another Radius account" andButtonText:@"OK"];
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    //[MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    
}

-(void)connectionDidFinishLoading: (NSURLConnection *)conn {
    
    
    self.jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if ([jsonArray count] != 0) {
        
        if([findBeaconContentDelegate respondsToSelector:@selector(updateTextData:)]){
            
            [findBeaconContentDelegate updateTextData: jsonArray];
        }
    }
    else {
        NSDictionary *emptyBeaconDiction = [NSDictionary dictionaryWithObject:@"this beacon has no content" forKey:@"content"];
        jsonArray =[[NSMutableArray alloc] init];
        [jsonArray addObject:emptyBeaconDiction];
    }
        
//            NSString *firstBeacon= [jsonArray objectAtIndex:0];
//    NSLog(@"The first Beacon is %@", firstBeacon);
        
        
//        for (int counter=0; counter<[jsonArray count]; counter++) {
//            
//            if ([[[jsonArray objectAtIndex:counter] objectForKey:@"content"]objectForKey:@"text"] != nil) {
//                self.beaconTextContent = [[[jsonArray objectAtIndex:counter] objectForKey:@"content"]objectForKey:@"text"];
//            NSLog(@"setting the beacon text content to: %@", self.beaconTextContent);
//        
//            if([findBeaconContentDelegate respondsToSelector:@selector(updateTextData:)])
//                {
//            [findBeaconContentDelegate updateTextData:[[[jsonArray objectAtIndex:0] objectForKey:@"content"]objectForKey:@"text"]];
//            NSLog(@"sending delegate Method");
//            }
//            }else if ([[[jsonArray objectAtIndex:counter] objectForKey:@"content"]objectForKey:@"video"] != nil) {
//                
//                self.beaconTextContent = [[[jsonArray objectAtIndex:counter] objectForKey:@"content"]objectForKey:@"video"];
//                NSLog(@"setting the beacon text content to: %@", self.beaconTextContent);
//                
//                if([findBeaconContentDelegate respondsToSelector:@selector(updateTextData:)])
//                {
//                    [findBeaconContentDelegate updateTextData:[[[jsonArray objectAtIndex:0] objectForKey:@"content"]objectForKey:@"text"]];
//                    NSLog(@"sending delegate Method");
//                }
//                
//            }
//                
//
//        }

    
}

-(NSString *) returnTextContent {
    
    return self.beaconTextContent;
    
}


-(NSString *) returnVideoURLContent {
    
    NSString *videoURLContent = [[jsonArray objectAtIndex:0] objectForKey:@"content"];
    
    return videoURLContent;
}

-(NSString *) returnImageURLContent {
    
    NSString *imageURLContent = [[jsonArray objectAtIndex:0] objectForKey:@"content"];
    
    return imageURLContent;
}

-(NSString *) returnVideoIDContent {
    
    NSString *videoIDContent = [[jsonArray objectAtIndex:0] objectForKey:@"content"];
    
    return videoIDContent;
}
@end
