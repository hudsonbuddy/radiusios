//
//  BeaconConversationTable.m
//  Radius
//
//  Created by Fred Ehrsam on 9/4/12.
//
//

#import "BeaconConversationTable.h"

@implementation BeaconConversationTable

@synthesize conversationArray;

-(void) getConversationInfoForBeacon:(NSString *)beaconID
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:beaconID, @"beacon", nil] apiMethod:@"conversation"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        conversationArray = response;
        NSLog(@"conversation response: %@", response);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [conversationArray count];
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    NSLog(@"current index path is: %@", indexPath);
    NSIndexPath *myPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([indexPath isEqual:myPath])
    {
        cell.textLabel.text = @"Join the conversation!";
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]])
    {
        
    }
}

@end
