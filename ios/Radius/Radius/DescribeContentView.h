//
//  DescribeContentView.h
//  Radius
//
//  Created by Fred Ehrsam on 10/31/12.
//
//

#import <UIKit/UIKit.h>

@interface DescribeContentView : UIView <UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *contentThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *beaconNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) IBOutlet DescribeContentView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *postingToLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareToLabel;

-(id)initWithFrame:(CGRect)frame handler:(void (^)(DescribeContentView *describeView, NSString * description, BOOL fbShare) )handler;

-(void)setupWithBeaconName:(NSString *) name andThumbnail:(UIImage *) thumbnail;

@property (strong, nonatomic) void (^handler)(DescribeContentView *describeView, NSString * description, BOOL fbShare);
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)postPressed: (id) sender;


@end
