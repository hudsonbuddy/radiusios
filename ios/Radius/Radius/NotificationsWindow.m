//
//  NotificationsWindow.m
//  Radius
//
//  Created by Fred Ehrsam on 9/9/12.
//
//

#import "NotificationsWindow.h"
#import "Notification.h"

@interface NotificationsWindow() {
    NSMutableDictionary *profilePictureCache;
}

@end

@implementation NotificationsWindow
@synthesize notificationsTable;
@synthesize titleLabel;
@synthesize notifications = _notifications;

@synthesize notificationResponseArray, notificationResponseDictionary;
static const NSInteger CELL_IMAGEVIEW_TAG = 8945367;

//@synthesize superView = _superView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self attachDismissGestureRecognizer];
        [[NSBundle mainBundle] loadNibNamed:@"NotificationsWindow" owner:self options:nil];
        [self.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:17]];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

- (void)setNotifications:(NSArray *)notifications
{
    _notifications = [notifications copy];
    [self.notificationsTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    UIFont *cellFont = notification.isRead?[UIFont fontWithName:@"Quicksand" size:16.0]:[UIFont fontWithName:@"QuicksandBold-Regular" size:16];
    CGSize constraintSize = CGSizeMake(215.0f, CGFLOAT_MAX);
    
    
    NSString *cellText = [notification.event notificationText];
    
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
    
    return labelSize.height + 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    
    int profPicTag = 4325;
    
    [[cell viewWithTag:profPicTag] removeFromSuperview];
    
    cell.textLabel.text = [notification.event notificationText];
    cell.textLabel.font = notification.isRead?[UIFont fontWithName:@"Quicksand" size:16.0]:[UIFont fontWithName:@"QuicksandBold-Regular" size:16];
        
    DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:notification.event.timestamp];
    NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]]; //[NSDate date] gets the current date
    cell.detailTextLabel.text = dateString;
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
    [cell setSelectedBackgroundView:bgColorView];


    NSMutableString *urlString = [notification.event.performerInfo objectForKey:@"picture_thumb"];
    NSURL *url = [NSURL URLWithString:urlString];

    if(!profilePictureCache) {
        profilePictureCache = [[NSMutableDictionary alloc] init];
    }
    
    AsyncImageView *asyncImageViewInstance = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60) imageURL:url cache:profilePictureCache loadImmediately:YES];
    asyncImageViewInstance.layer.cornerRadius = 5;
    asyncImageViewInstance.clipsToBounds = YES;
    asyncImageViewInstance.tag = profPicTag;
    cell.indentationWidth = asyncImageViewInstance.frame.size.width;
    cell.indentationLevel = 1;
    if ([cell viewWithTag:CELL_IMAGEVIEW_TAG]) {
        [[cell viewWithTag:CELL_IMAGEVIEW_TAG]removeFromSuperview];
    }
    [cell addSubview:asyncImageViewInstance];
    
    
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:13];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    UIViewController *viewToPush = [notification.event linkViewController];
    
    UIViewController *vc = self.firstAvailableUIViewController;
    [vc.navigationController pushViewController:viewToPush animated:YES];
    [vc dismissNotifications];
    
    [notification markRead];
    
}


- (IBAction)dismiss:(id)sender {
    [self removeFromSuperview];
}
@end
