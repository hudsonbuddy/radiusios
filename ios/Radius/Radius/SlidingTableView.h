//
//  SlidingTableView.h
//  radius
//
//  Created by Hud on 8/22/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfileViewController2.h"
#import "AsyncImageView.h"

@interface SlidingTableView : UIView <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableDictionary *imageCacheDictionary;
    
}
@property (strong, nonatomic) IBOutlet UITableView *slidingTableViewTableView;
@property (nonatomic, strong) NSMutableArray *responseArray;
@property (nonatomic, strong) NSMutableDictionary *responseDictionary;

@property (nonatomic, strong) NSString *slidingTableViewType;
@end
