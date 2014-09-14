//
//  ContentPostEvent.m
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "ContentPostEvent.h"
#import "ContentFeedCell.h"
#import "DateAndTimeHelper.h"
#import "BeaconDetailContentImageViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BeaconDetailContentVideoViewController.h"

@interface ContentPostEvent() {
    NSDictionary *contentInfo;
}

@end

@implementation ContentPostEvent

-(id)initWithDictionary:(NSDictionary *)eventDictionary
{
    self = [super initWithDictionary:eventDictionary];
    if(self) {
        contentInfo = [[eventDictionary objectForKey:@"data"] objectForKey:@"content_item"];
    }
    return self;
}

-(FeedCell *)newsFeedCellForTableView:(UITableView *)tableView imageCache:(id)imageCache
{
    NSString *cellIdentifier = @"ContentPostEventCell";
    ContentFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ContentFeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [cell.mainImageView removeFromSuperview];
    cell.isVideo = NO;
    cell.beaconDictionary = self.beaconInfo;
    cell.contentInfo = contentInfo;
    NSLog(@"%@", contentInfo);
    NSDictionary *contentDict = [contentInfo objectForKey:@"content"];
    
    NSString *contentType = [contentInfo objectForKey:@"type"];
    
    if([contentType isEqualToString:@"image"]) {
        NSURL *imageURL = [NSURL URLWithString:[contentDict objectForKey:@"url"]];
        [cell setMainPictureButtonToPicture:imageURL cache:imageCache];
        [cell setupLikesAndComments];
        
    } else if([contentType isEqualToString:@"video_ext"]) {
        cell.isVideo = YES;
        NSString *site = [contentDict objectForKey:@"site"];
        NSString *videoID = [contentDict objectForKey:@"video_id"];
        if([site isEqualToString:@"youtube"]) {
            NSURL *thumbURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",videoID]];
            [cell setMainPictureButtonToPicture:thumbURL cache:imageCache];
        }
    }
    
    return cell;

}

-(AsyncImageView *) imageThumbWithFrame:(CGSize)size andImageCache:(id)cache
{
    NSDictionary *contentDict = [contentInfo objectForKey:@"content"];
    
    NSString *contentType = [contentInfo objectForKey:@"type"];
    CGRect imageFrame = CGRectMake(0,0,size.width,size.height);
    
    if([contentType isEqualToString:@"image"]) {
        NSURL *imageURL = [NSURL URLWithString:[contentDict objectForKey:@"url"]];
         return [[AsyncImageView alloc] initWithFrame:imageFrame imageURL:imageURL cache:cache];
    } else if([contentType isEqualToString:@"video_ext"]) {
        NSString *site = [contentDict objectForKey:@"site"];
        NSString *videoID = [contentDict objectForKey:@"video_id"];
        if([site isEqualToString:@"youtube"]) {
            NSURL *thumbURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",videoID]];
            return [[AsyncImageView alloc] initWithFrame:imageFrame imageURL:thumbURL cache:cache];
        }
    }
    return nil;
}

-(NSString *) eventImageURL
{
    NSDictionary *contentDict = [contentInfo objectForKey:@"content"];
    
    NSString *contentType = [contentInfo objectForKey:@"type"];
    
    if([contentType isEqualToString:@"image"]) {
        return [contentDict objectForKey:@"url"];
    } else if([contentType isEqualToString:@"video_ext"]) {
        NSString *site = [contentDict objectForKey:@"site"];
        NSString *videoID = [contentDict objectForKey:@"video_id"];
        if([site isEqualToString:@"youtube"]) {
            return [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",videoID];
        }
    }
    return nil;
}

-(CGFloat)newsFeedCellHeight
{
    return 260.0;
}

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    NSDictionary *contentDict = [contentInfo objectForKey:@"content"];
    NSString *contentType = [contentInfo objectForKey:@"type"];
    
    if([contentType isEqualToString:@"image"]) {
        BeaconDetailContentImageViewController *newViewControllerInstance = [st instantiateViewControllerWithIdentifier:@"BeaconDetailImageContentID"];
        
        [newViewControllerInstance setBeaconContentDictionary:contentInfo];
        [newViewControllerInstance setBeaconNameString:[self.beaconInfo objectForKey:@"name"]];
        [newViewControllerInstance setContentString:[contentDict objectForKey:@"url"]];
        [newViewControllerInstance setContentID:[contentInfo objectForKey:@"id"]];
        [newViewControllerInstance setBeaconIDString:[self.beaconInfo objectForKey:@"id"]];
        [newViewControllerInstance setContentType:@"image"];
        [newViewControllerInstance setContentImageHeight:[contentDict objectForKey:@"height"]];
        [newViewControllerInstance setContentImageWidth:[contentDict objectForKey:@"width"]];
        [newViewControllerInstance setCommentCountString:[NSString stringWithFormat:@"%@",[contentInfo objectForKey:@"num_comments"]]];
        [newViewControllerInstance setLikeCountString:[NSString stringWithFormat:@"%@",[contentInfo objectForKey:@"score"]]];
        [newViewControllerInstance setPosterIDString:[NSString stringWithFormat:@"%@",[contentInfo objectForKey:@"poster"]]];
        
        [newViewControllerInstance setUserNameString:[contentInfo objectForKey:@"poster"]];
        if ([[contentInfo objectForKey:@"vote"]integerValue] == -1) {
            [newViewControllerInstance setContentVotedDown:YES];
        }else if ([[contentInfo objectForKey:@"vote"]integerValue] == 0) {
            [newViewControllerInstance setContentNotVotedYet:YES];
        }else if ([[contentInfo objectForKey:@"vote"]integerValue] == 1) {
            [newViewControllerInstance setContentVotedUp:YES];
        }
        [newViewControllerInstance setContentVoteScore:[contentInfo objectForKey:@"score"]];
        
        return newViewControllerInstance;
    } else if([contentType isEqualToString:@"video_ext"]) {
        if([[contentDict objectForKey:@"site"] isEqualToString:@"youtube"]) {
            NSLog(@"%@",contentInfo);
            BeaconDetailContentVideoViewController *newViewControllerInstance = [st instantiateViewControllerWithIdentifier:@"BeaconDetailVideoContentID"];
            
            [newViewControllerInstance setTitle:[self.beaconInfo objectForKey:@"name"]];
            [newViewControllerInstance setBeaconContentDictionary:contentInfo];
            if ([[[contentInfo objectForKey:@"content"]objectForKey:@"site"] isEqualToString:@"youtube"]) {
                [newViewControllerInstance setContentString:[[contentInfo objectForKey:@"content"] objectForKey:@"video_id"]];
            }
            
            [newViewControllerInstance setContentID:[contentInfo objectForKey:@"id"]];
            [newViewControllerInstance setBeaconIDString:[self.beaconInfo objectForKey:@"id"]];
            [newViewControllerInstance setBeaconNameString:[self.beaconInfo objectForKey:@"name"]];
            [newViewControllerInstance setContentType:@"video_ext"];
            [newViewControllerInstance setCommentCountString:[NSString stringWithFormat:@"%@",[contentInfo objectForKey:@"num_comments"]]];
            [newViewControllerInstance setLikeCountString:[NSString stringWithFormat:@"%@",[contentInfo objectForKey:@"score"] ]];
            
            [newViewControllerInstance setUserNameString:[contentInfo objectForKey:@"poster"]];
            if ([[contentInfo objectForKey:@"vote"]integerValue] == -1) {
                [newViewControllerInstance setContentVotedDown:YES];
            }else if ([[contentInfo objectForKey:@"vote"]integerValue] == 0) {
                [newViewControllerInstance setContentNotVotedYet:YES];
            }else if ([[contentInfo objectForKey:@"vote"]integerValue] == 1) {
                [newViewControllerInstance setContentVotedUp:YES];
            }
            
            return newViewControllerInstance;
        }
    }
    
    return nil;

}

-(NSString *)recentActivityText
{
    NSString *contentType = [contentInfo objectForKey:@"type"];
    if([contentType isEqualToString:@"image"]) {
        return @"Posted an image";
    } else if([contentType isEqualToString:@"video_ext"]) {
        return @"Posted a video";
    } else {
        return @"Made a post";
    }
}

@end
