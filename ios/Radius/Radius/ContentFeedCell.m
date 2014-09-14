//
//  FeedCell.m
//  Radius
//
//  Created by Fred Ehrsam on 9/19/12.
//
//

#import "ContentFeedCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Scale.h"

@implementation ContentFeedCell
@synthesize mainPictureButton, thumbnailButton1, thumbnailButton2;
@synthesize descriptionTextView;
@synthesize mainPicture;
@synthesize textNewBeaconView;
@synthesize mainImageView = _mainImageView;
@synthesize likesLabel, commentsLabel;
@synthesize contentInfo;

static const NSInteger ASYNC_IMAGE_TAG = 8786;

-(void) setMainPictureButtonToPicture:(NSURL *)pictureURL cache:(id)cache
{
    CGRect imageFrame = CGRectMake(0,0,self.mainPictureButton.frame.size.width,self.mainPictureButton.frame.size.height);
    _mainImageView = [[AsyncImageView alloc] initWithFrame:imageFrame imageURL:pictureURL cache:cache];
    self.mainImageView.delegate = self;
    self.mainImageView.opaque = YES;
    [self.mainPictureButton addSubview:self.mainImageView];
}

-(void) setMainPictureButtonToPicture:(UIImage *)picture
{
    //Handle portrait - crop
    NSLog(@"picture.size.width is: %f", picture.size.width);
    NSLog(@"picture.size.height is: %f", picture.size.height);

    double widthToHeightRatio = picture.size.width/picture.size.height;
    double correctRatio = 600/450;
    
    //Picture is too wide to fit - chop some width
    if (widthToHeightRatio > correctRatio)
    {
        double heightRatio = picture.size.height/450;
        int correctWidth = heightRatio * picture.size.width;
        int widthToChop = correctWidth - 600;
        CGRect croppedRect = CGRectMake(widthToChop/2, 0, 600, 450);
        CGImageRef imageRef = CGImageCreateWithImageInRect([picture CGImage], croppedRect);
        UIImage *croppedImg = [UIImage imageWithCGImage:imageRef scale:picture.scale orientation:picture.imageOrientation];
        NSLog(@"cropped img width and height in too wide is: %f, %f", croppedImg.size.width, croppedImg.size.height);
        [self.mainPictureButton setImage:croppedImg forState:UIControlStateNormal];
    }
    //Picture is too tall - chop some height
    else
    {
        double widthRatio = picture.size.width/600;
        int correctHeight = widthRatio * picture.size.height;
        int heightToChop = correctHeight - 450;
        CGRect croppedRect = CGRectMake(0, heightToChop/2, 600, 450);
        CGImageRef imageRef = CGImageCreateWithImageInRect([picture CGImage], croppedRect);
        UIImage *croppedImg = [UIImage imageWithCGImage:imageRef scale:picture.scale orientation:picture.imageOrientation];
        NSLog(@"cropped img width and height in too tall is: %f, %f", croppedImg.size.width, croppedImg.size.height);
        [self.mainPictureButton setImage:croppedImg forState:UIControlStateNormal];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ContentFeedCell" owner:self options:nil];
        //[self addSubview:self.backgroundView];

        self.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pnl_nfp_photocell.png"]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //[self setButtonImagesRoundedRects];
        [self setupFonts];
        [mainPictureButton addTarget:self
                              action:@selector(mainPictureButtonPressed:)
               forControlEvents:UIControlEventTouchDown];
        
        [self
         addSubview:self.cellView];
    }
    
    return self;
}

- (IBAction)mainPictureButtonPressed:(UIButton*)button
{
    NSLog(@"main button pressed");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) setButtonImagesRoundedRects
{
    CALayer *layer = [mainPictureButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10.0];
    
    CALayer *layer2 = [thumbnailButton1 layer];
    [layer2 setMasksToBounds:YES];
    [layer2 setCornerRadius:10.0];
    
    CALayer *layer3 = [thumbnailButton2 layer];
    [layer3 setMasksToBounds:YES];
    [layer3 setCornerRadius:10.0];
}

-(void) setupFonts
{
    self.descriptionTextView.font = [UIFont fontWithName:@"Quicksand" size:descriptionTextView.font.pointSize];
    [self.timePostedLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.timePostedLabel.font.pointSize]];
    [self.distanceLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.distanceLabel.font.pointSize]];
    [self.beaconNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.beaconNameLabel.font.pointSize]];
    [self.numberOfFollowersLabel setFont:[UIFont fontWithName:@"Quicksand" size:self.numberOfFollowersLabel.font.pointSize]];
    [self.likesLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.beaconNameLabel.font.pointSize]];
    [self.commentsLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:self.beaconNameLabel.font.pointSize]];



}

-(void) setupLikesAndComments {
    
    NSLog(@"%@", self.contentInfo);
    if ([[self.contentInfo objectForKey:@"score"]integerValue] !=0) {
        [self.likesLabel setHidden:NO];
        if ([[self.contentInfo objectForKey:@"score"]integerValue] == 1) {
            [self.likesLabel setText:[NSString stringWithFormat:@"%@ like", [self.contentInfo objectForKey:@"score"]]];

        }else {
            [self.likesLabel setText:[NSString stringWithFormat:@"%@ likes", [self.contentInfo objectForKey:@"score"]]];

        }

    }else {
        
        [self.likesLabel setHidden:YES];
        
    }
    
    if ([[self.contentInfo objectForKey:@"num_comments"]integerValue] !=0) {
        [self.commentsLabel setHidden:NO];
        if([[self.contentInfo objectForKey:@"num_comments"]integerValue] ==1){
            [self.commentsLabel setText:[NSString stringWithFormat:@"%@ comment", [self.contentInfo objectForKey:@"num_comments"]]];

        }else{
            [self.commentsLabel setText:[NSString stringWithFormat:@"%@ comments", [self.contentInfo objectForKey:@"num_comments"]]];

        }

    }else {
        
        [self.commentsLabel setHidden:YES];
        
    }
    
}

-(UIImage *)cropImage:(UIImage *)image toSize:(CGSize)size
{
    double widthToHeightRatio = image.size.width/image.size.height;
    double correctRatio = size.width/size.height;

    //Picture is too wide to fit - chop some width
    if (widthToHeightRatio > correctRatio)
    {
        double heightRatio = image.size.height/size.height;
        int correctWidth = heightRatio * image.size.width;
        int widthToChop = correctWidth - size.width;
        CGRect croppedRect = CGRectMake(widthToChop/2, 0, size.width, size.height);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croppedRect);
        UIImage *croppedImg = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        return croppedImg;
    }
    //Picture is too tall - chop some height
    else
    {
        double widthRatio = image.size.width/size.width;
        int correctHeight = widthRatio * image.size.height;
        int heightToChop = correctHeight - size.height;
        CGRect croppedRect = CGRectMake(0, heightToChop/2, size.width, size.height);
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croppedRect);
        UIImage *croppedImg = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        return croppedImg;
    }
}

-(UIImage *)addVideoOverlay:(UIImage *)image
{
    UIImage *overlayImage = [UIImage imageNamed:@"btn_videoplay_full.png"];
    
    image = [image scaleToWidth:600];
    
    UIGraphicsBeginImageContextWithOptions(image.size, FALSE, 0.0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [overlayImage drawInRect:CGRectMake( image.size.width/2-overlayImage.size.width, image.size.height/2-overlayImage.size.height, overlayImage.size.width*2, overlayImage.size.height*2)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)asyncImageView:(AsyncImageView *)imageView willShowImage:(UIImage *)image
{
    imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if(self.isVideo) {
        image = [self addVideoOverlay:image];
    }
    
    return image;
}

@end
