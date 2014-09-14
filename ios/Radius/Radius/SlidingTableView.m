//
//  SlidingTableView.m
//  radius
//
//  Created by Hud on 8/22/12.
//
//

#import "SlidingTableView.h"
#import "ProfileViewController2.h"

@implementation SlidingTableView
@synthesize slidingTableViewTableView ,responseArray,responseDictionary;
@synthesize slidingTableViewType;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    if (responseArray !=nil) {
        return [responseArray count];

    }else if (responseDictionary != nil){
            return [responseDictionary count];

    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (responseArray != nil) {
        
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        }
        
        cell.textLabel.text = [[responseArray objectAtIndex:indexPath.row] objectForKey:@"display_name"];
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
        NSMutableString *urlString = [[[responseArray objectAtIndex:indexPath.row] objectForKey:@"picture_thumb"] mutableCopy];
//        [urlString replaceCharactersInRange:[urlString rangeOfString:@".us/"] withString:@".us/th_"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if (!imageCacheDictionary) {
            
            imageCacheDictionary = [[NSMutableDictionary alloc] init];
            
        }
        
        AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) imageURL:url cache:imageCacheDictionary loadImmediately:YES];
        cell.indentationWidth = asyncImageViewInstance.frame.size.width;
        cell.indentationLevel = 1;
        [cell addSubview:asyncImageViewInstance];
        
//        cell.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        
        return cell;
    }else if (responseDictionary != nil) {
        
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
            
        }
        
        cell.textLabel.text = [responseDictionary objectForKey:@"display_name"];
        cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    }
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = @"Fetching data!";
    cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    return cell;
}

@end
