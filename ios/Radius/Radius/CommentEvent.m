//
//  CommentEvent.m
//  radius
//
//  Created by David Herzka on 10/26/12.
//
//

#import "CommentEvent.h"
#import "BeaconDetailContentViewController.h"
#import "BeaconDetailContentImageViewController.h"
#import "BeaconDetailContentVideoViewController.h"

@interface CommentEvent() {
    NSDictionary *commentInfo;
    NSDictionary *contentInfo;
}

@end

@implementation CommentEvent

-(id)initWithDictionary:(NSDictionary *)eventDictionary
{
    self = [super initWithDictionary:eventDictionary];
    if(self) {
        NSDictionary *eventData = [eventDictionary objectForKey:@"data"];
        
        commentInfo = [eventData objectForKey:@"comment"];
        contentInfo = [eventData objectForKey:@"content_item"];
    }
    return self;
}

-(NSString *)notificationText
{
    NSString *displayNameString = [[commentInfo objectForKey:@"author_o"]objectForKey:@"display_name"];
    
    NSString *commentTextString = [commentInfo objectForKey:@"text"];
    
    NSString *text = nil;
    if([[contentInfo objectForKey:@"poster"] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]]) {
        text = [NSString stringWithFormat:@"%@ commented on your %@: \"%@\"", displayNameString,[self contentTypeDisplayString], commentTextString];
    } else {
        text = [NSString stringWithFormat:@"%@ also commented on a %@: \"%@\"",displayNameString,[self contentTypeDisplayString], commentTextString];
    }
    
    return text;
}

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    NSString *contentType = [contentInfo objectForKey:@"type"];
    
    if([contentType isEqual:@"image"]) {
        NSLog(@"%@",contentInfo);
        BeaconDetailContentImageViewController *newViewControllerInstance = [st instantiateViewControllerWithIdentifier:@"BeaconDetailImageContentID"];

        [newViewControllerInstance setTitle:[self.beaconInfo objectForKey:@"name"]];
        [newViewControllerInstance setBeaconContentDictionary:contentInfo];
        [newViewControllerInstance setContentString:[[contentInfo objectForKey:@"content"] objectForKey:@"url"]];
        [newViewControllerInstance setContentID:[contentInfo objectForKey:@"id"]];
        [newViewControllerInstance setBeaconIDString:[self.beaconInfo objectForKey:@"id"]];
        [newViewControllerInstance setBeaconNameString:[self.beaconInfo objectForKey:@"name"]];
        [newViewControllerInstance setContentType:@"image"];
        [newViewControllerInstance setContentImageHeight:[[contentInfo objectForKey:@"content"] objectForKey:@"height"]];
        [newViewControllerInstance setContentImageWidth:[[contentInfo objectForKey:@"content"] objectForKey:@"width"]];
        [newViewControllerInstance setCommentCountString:[NSString stringWithFormat:@"%@",[[contentInfo objectForKey:@"content"] objectForKey:@"num_comments"]]];
        [newViewControllerInstance setLikeCountString:[NSString stringWithFormat:@"%@",[[contentInfo objectForKey:@"content"] objectForKey:@"score"]]];
        
        [newViewControllerInstance setUserNameString:[contentInfo objectForKey:@"poster"]];
        if ([[contentInfo objectForKey:@"vote"]integerValue] == -1) {
            [newViewControllerInstance setContentVotedDown:YES];
        }else if ([[contentInfo objectForKey:@"vote"]integerValue] == 0) {
            [newViewControllerInstance setContentNotVotedYet:YES];
        }else if ([[contentInfo objectForKey:@"vote"]integerValue] == 1) {
            [newViewControllerInstance setContentVotedUp:YES];
        }

        return newViewControllerInstance;
    } else if([contentType isEqual:@"video_ext"]) {
        
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
    return nil;
}

-(NSString *)recentActivityText
{
    NSString *commentText = [commentInfo objectForKey:@"text"];
    
    return [NSString stringWithFormat:@"Commented on a %@: \"%@\"",[self contentTypeDisplayString], commentText];
}

-(NSString *)contentTypeDisplayString
{
    NSString *contentType = [contentInfo objectForKey:@"type"];
    
    NSString *displayString = @"post";
    if([contentType isEqualToString:@"image"]) {
        displayString = @"photo";
    } else if([contentType isEqualToString:@"video_ext"]) {
        displayString = @"video";
    }
    
    return displayString;
}



@end
