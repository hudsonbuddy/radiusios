//
//  ConversationThreadCreateEvent.m
//  radius
//
//  Created by David Herzka on 10/29/12.
//
//

#import "ConversationThreadCreateEvent.h"
#import "ConvoFeedCell.h"
#import "ConvoThreadViewController.h"

@implementation ConversationThreadCreateEvent

-(id)initWithDictionary:(NSDictionary *)eventDictionary
{
    self = [super initWithDictionary:eventDictionary];
    if(self) {
        self.threadInfo = [[eventDictionary objectForKey:@"data"] objectForKey:@"thread"];
    }
    return self;
}

-(FeedCell *)newsFeedCellForTableView:(UITableView *)tableView imageCache:(id)imageCache
{
    NSString *MyIdentifier = @"ConversationThreadCreateEventCell";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    //Check if we already have a cell of that type created
    if (cell == nil) {
        cell = [[ConvoFeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ConvoFeedCell *convoFeedCell = (ConvoFeedCell *) cell;
    
    [convoFeedCell.threadTitleButton setTitle:[self.threadInfo objectForKey:@"title"] forState:UIControlStateNormal];
    [convoFeedCell.postTextView setText:[self.threadInfo objectForKey:@"text"]];
    [convoFeedCell.repliesTextButton setTitle:@"Reply!" forState:UIControlStateNormal];
    convoFeedCell.cellView.layer.cornerRadius = 5;
    convoFeedCell.postTextView.backgroundColor = [UIColor clearColor];
    convoFeedCell.cellView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bck_GraphTexture60.png"]];
    convoFeedCell.beaconDictionary = self.beaconInfo;
    
    
    convoFeedCell.postTextView.frame = CGRectMake(convoFeedCell.postTextView.frame.origin.x, convoFeedCell.postTextView.frame.origin.y, convoFeedCell.postTextView.contentSize.width, convoFeedCell.postTextView.frame.size.height);
    
    convoFeedCell.repliesTextButton.userInteractionEnabled = NO;
    convoFeedCell.threadTitleButton.userInteractionEnabled = NO;
    convoFeedCell.timePostedLabel.userInteractionEnabled = NO;
    convoFeedCell.numberOfFollowersLabel.userInteractionEnabled = NO;
    


    
    return convoFeedCell;
}

-(CGFloat)newsFeedCellHeight
{
    return 160;
}

-(NSString *)recentActivityText
{
    return [NSString stringWithFormat:@"Started a new thread \"%@\"",[self.threadInfo objectForKey:@"title"]];
}

-(UIViewController *)linkViewController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    ConvoThreadViewController *threadController = [st instantiateViewControllerWithIdentifier:@"convoThreadID"];
    
    [threadController initializeWithThreadID:[[self.threadInfo objectForKey:@"id"] integerValue] threadTitle:[self.threadInfo objectForKey:@"title"] beaconName:[self.beaconInfo objectForKey:@"name"] beaconID:[[self.beaconInfo objectForKey:@"id"] integerValue]];
    
    return threadController;
}

@end
