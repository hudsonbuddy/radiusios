//
//  ContentFeedCell.h
//  Radius
//
//  Created by Fred Ehrsam on 9/19/12.
//
//

#import <UIKit/UIKit.h>
#import "FeedCell.h"
#import "AsyncImageView.h"

@interface ContentFeedCell : FeedCell <AsyncImageViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *mainPictureButton;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton1;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton2;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) UIImage *mainPicture;
@property (weak, nonatomic) IBOutlet UIView *textNewBeaconView;
@property (nonatomic) BOOL isVideo;
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsLabel;
@property (strong, nonatomic) NSDictionary *contentInfo;

@property (readonly) AsyncImageView *mainImageView;

-(void) setMainPictureButtonToPicture:(UIImage *)picture;

-(void) setMainPictureButtonToPicture:(NSURL *)pictureURL cache:(id)cache;
-(void) setupLikesAndComments; 


@end
