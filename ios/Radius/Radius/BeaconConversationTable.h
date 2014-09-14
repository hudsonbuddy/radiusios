//
//  BeaconConversationTable.h
//  Radius
//
//  Created by Fred Ehrsam on 9/4/12.
//
//

#import <Foundation/Foundation.h>
#import "RadiusRequest.h"

@interface BeaconConversationTable : NSObject <UITableViewDataSource, UITableViewDelegate>

-(void) getConversationInfoForBeacon:(NSString *)beaconID;
@property (nonatomic, strong) NSMutableArray *conversationArray;

@end
