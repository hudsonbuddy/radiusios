//
//  BeaconSuggestionsView.m
//  radius
//
//  Created by David Herzka on 1/11/13.
//
//

#import "BeaconSuggestionsView.h"
#import "RadiusRequest.h"
#import "AsyncImageView.h"
#import "BeaconContentViewController2.h"

@interface BeaconSuggestionsView() {
    NSMutableArray *suggestions;
    NSMutableDictionary *imageCache;
    
    NSInteger offset;
    
    BOOL loading;
}

@end

@implementation BeaconSuggestionsView

@synthesize tableView,headerLabel;

const static NSInteger CELL_ASYNC_IMAGE_VIEW_TAG = 890412;

const static NSInteger LIMIT = 10;

- (id)init
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"BeaconSuggestionsView" owner:self options:nil]objectAtIndex:0];
    if (self) {
        imageCache = [[NSMutableDictionary alloc] init];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self loadSuggestions];
        [self setupAppearance];
        
    }
    return self;
}

-(void)loadSuggestions
{
    if(loading) return;
    loading = YES;
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.frame = CGRectMake(0, tableView.contentSize.height-50, tableView.frame.size.width, 50);
    [aiv startAnimating];
    [tableView addSubview:aiv];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",offset],@"offset",[NSString stringWithFormat:@"%d",LIMIT],@"limit", nil];
    RadiusRequest *request = [RadiusRequest requestWithParameters:params apiMethod:@"beacon/suggested"];
    [request startWithCompletionHandler:^(id result, RadiusError *error) {
        if(!error) {
            offset += LIMIT;
            
            if(!suggestions) {
                suggestions = [result mutableCopy];
            } else {
                [suggestions addObjectsFromArray:result];
            }
            
            [aiv removeFromSuperview];
            [tableView reloadData];
            loading = NO;
        }
    }];
}

-(void)setupAppearance
{
    [self.headerLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:16]];
    
    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:img];
    backgroundView.contentMode = UIViewContentModeCenter;
    backgroundView.alpha = 0.5;
    [self.tableView setBackgroundView:backgroundView];
    self.backgroundColor = [UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(suggestions) {
        return suggestions.count+1;
    } else {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(suggestions) {
        if(indexPath.row < suggestions.count) {
            static NSString *cellIdentifier = @"suggestion_cell";
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            NSDictionary *beaconInfo = [suggestions objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [beaconInfo objectForKey:@"name"];
            int numFollowers = [[beaconInfo objectForKey:@"num_followers"] intValue];
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d follower%@", numFollowers, numFollowers == 1 ? @"" : @"s"];
            cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:18];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
            
            AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,50,50) imageURL:[NSURL URLWithString:[beaconInfo objectForKey:@"picture_thumb"]] cache:imageCache];
            aiv.tag = CELL_ASYNC_IMAGE_VIEW_TAG;
            [[cell.contentView viewWithTag:CELL_ASYNC_IMAGE_VIEW_TAG] removeFromSuperview];
            [cell.contentView addSubview:aiv];
            cell.indentationWidth = 55;
            cell.indentationLevel = 1;
            
            
            
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"more...";
            cell.textLabel.font = [UIFont fontWithName:@"Quicksand" size:16];
            return cell;
        }
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiv.frame = CGRectMake(0,0,tableView.bounds.size.width,[self tableView:tableView heightForRowAtIndexPath:indexPath]);
        [cell.contentView addSubview:aiv];
        [aiv startAnimating];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(!suggestions) {
        return;
    }
    if(indexPath.row == suggestions.count) {
        [self loadSuggestions];
    } else {
        NSDictionary *beaconInfo = [suggestions objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        BeaconContentViewController2 *beaconViewController = [storyboard instantiateViewControllerWithIdentifier:@"beaconContentID3"];
        [beaconViewController initializeWithBeaconDictionary:beaconInfo];
        
        [[MFSideMenuManager sharedManager].navigationController pushViewController:beaconViewController animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!suggestions) {
        return NO;
    }
    return YES;
}

@end
