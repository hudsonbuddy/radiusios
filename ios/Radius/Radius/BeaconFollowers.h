//
//  BeaconFollowers.h
//  radius
//
//  Created by Hud on 10/29/12.
//
//

#import <Foundation/Foundation.h>
#import "AsyncImageView.h"
#import "ProfileViewController2.h"

@interface BeaconFollowers : NSObject <UITableViewDataSource> {
    

    
}

@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;


@end
