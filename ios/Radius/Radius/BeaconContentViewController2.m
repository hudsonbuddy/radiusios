//
//  BeaconContentViewController2.m
//  Radius
//
//  Created by Fred Ehrsam on 9/18/12.
//
//

#import "BeaconContentViewController2.h"
#import "RadiusProgressView.h"
#import "SlidingTableView.h"
#import "BeaconConversationTable.h"
#import "ConvoThreadViewController.h"
#import "UIImage+Scale.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PopupView.h"
#import "BeaconCreatorSettingsView.h"
#import "Flurry.h"

#import "CLTickerView.h"

@interface ThreadTableViewCell : UITableViewCell

-(id)initWithReuseIdentifier:(NSString *)identifier;
-(void) setupThreadDetails:(NSDictionary *)thread;

@end

@implementation ThreadTableViewCell

-(id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    if(self) {
        // do nothing
    }
    return self;
}

-(void) setupThreadDetails:(NSDictionary *)thread
{
    DateAndTimeHelper *dateHelper = [[DateAndTimeHelper alloc] init];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[[thread objectForKey:@"timestamp"] doubleValue]];
    NSString *dateString = [dateHelper timeIntervalWithStartDate:postDate withEndDate:[NSDate date]];
    
    //cell.contentView.frame = CGRectMake(0, 0, 290, cell.frame.size.height);
    self.textLabel.text = [thread objectForKey:@"text"];
    self.textLabel.font = [UIFont fontWithName:@"Quicksand" size:14];
    self.textLabel.numberOfLines = 1;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSString *spacer = @""; // to indent detailTextLabel without needing to subclass UITableViewCell
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@%@ said %@",spacer,[[thread objectForKey:@"poster_o"]objectForKey:@"display_name"], dateString];
    self.detailTextLabel.numberOfLines = 1;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.detailTextLabel.font = [UIFont fontWithName:@"Quicksand" size:12];
    
    UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    repliesLabel.text = [NSString stringWithFormat:@"%@",[thread objectForKey:@"num_replies"]];
    repliesLabel.textAlignment = NSTextAlignmentRight;
    repliesLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:14];
    repliesLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView *repliesIcon = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, 30, 30)];
    [repliesIcon setImage:[UIImage imageNamed:@"ico_bvp_reply"]];
    
    UIView *repliesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    [repliesView addSubview:repliesLabel];
    [repliesView addSubview:repliesIcon];
    
    if ([[thread objectForKey:@"num_replies"]integerValue] != 0) {
        [self setAccessoryView:repliesView];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.detailTextLabel.frame = CGRectOffset(self.detailTextLabel.frame, 0, 8);
}

@end

@interface BeaconContentViewController2 () <CLLocationManagerDelegate, MKMapViewDelegate, FindBeaconContentDelegate, UITableViewDelegate, UITableViewDataSource, FindBeaconInfoDelegate, PostContentViewDelegate, UIImagePickerControllerDelegate,
NSURLConnectionDataDelegate, UITextFieldDelegate, BeaconDetailContentImageDelegate, BeaconDetailContentVideoDelegate, BeaconCreatorSettingsDelegate> {
    UIView *contentRefreshView;
    UIView *convoRefreshView;
    UIPanGestureRecognizer *contentPanRecognizer;
    UIPanGestureRecognizer *convoPanRecognizer;
    
    NSInteger contentOffset;
	BOOL alreadyPostingChatter;
    UIImageView *transparencyImageView;
    RadiusUserData * _myUserData;
}


@property (strong, nonatomic) DescribeContentView *describe;
@property (strong, nonatomic) CLTickerView *ticker;
@end

@implementation BeaconContentViewController2
@synthesize postContentButton;

@synthesize contentTableView;

@synthesize beaconNameOutlet;
@synthesize beaconContentOutlet;

@synthesize beaconLocationOutlet;
@synthesize contentMapView;

@synthesize mapAnnotations;

@synthesize connection, jsonArray, jsonData;

@synthesize jsonInfoArray;
@synthesize beaconCreatorProfileButton;
@synthesize numberFollowingButton;
@synthesize followBeaconButtonOutlet;
@synthesize sendingBeaconID;
@synthesize currentBeaconisFollowed, currentBeaconisMeBeacon, locationManager;
@synthesize twitterResponse, currentTweetToDisplay, swipeCount;
@synthesize userTokenString, userNameString;
@synthesize responseArray, responseDictionary;
@synthesize myGridView;
@synthesize responseFollowedArray, responseFollowedDictionary;
@synthesize convoArray;
@synthesize convoTable;
@synthesize topContentButton, liveConversationButton, locationInfoButton;
@synthesize beaconPanel;
@synthesize locationInfoScrollView;
@synthesize animatedDistance;
@synthesize beaconJustCreated;
@synthesize beaconDictionary = _beaconDictionary;
@synthesize beaconFollowersTableViewOutlet;
@synthesize describeContentView;
@synthesize beaconFollowersDataSourceInstance;
@synthesize responseUserInfoArray, responseUserInfoDictionary;
@synthesize currentUserNameString;
@synthesize postThreadView;
@synthesize beaconCreatorSettingsButtonOutlet;
@synthesize beaconNameString;
@synthesize ticker;
@synthesize creatorView, creatorNameLabel;
@synthesize currentUserIsBeaconCreator, beaconIsPrivate;
@synthesize tapToEndTextViewEditingGestureRecognizer;
@synthesize happeningNowViewOutlet;
@synthesize myScrollViewOutlet;

MKAnnotationView *beaconAnnotationView;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat DIMVIEW_BLOCKING_TAG = 100;
static const CGFloat POST_THREAD_TAG = 200;
static const CGFloat BUTTON_DIM_TAG = 300;
static const CGFloat ADD_CONTENT_TAG = 400;
static const CGFloat ACTIVITY_INDICATOR_TAG = 500;
static const CGFloat CONGRATS_BEACON_TAG = 600;
static const CGFloat ADD_NEW_CONTENT_BUTTON_TAG =700;
static const CGFloat UPLOAD_SOMETHING_TAG =800;
static const NSInteger CONTENT_REFRESH_LABEL_TAG = 54278;
static const NSInteger CONTENT_REFRESH_AIV_TAG = 54279;
static const NSInteger CONVO_REFRESH_LABEL_TAG = 54378;
static const NSInteger CONVO_REFRESH_AIV_TAG = 54379;



static NSString * const REPLY_PLACEHOLDER = @"Join the Conversation!";


static const NSInteger CELL_IMAGEVIEW_TAG = 8945367;



RadiusProgressView *uploadProgressView;
UITextView *chatterTextView;
AsyncImageView *happeningNowImageView;

#pragma mark Initializers

-(void) initializeWithBeaconID:(NSString *)beaconID
{
    self.sendingBeaconID = beaconID;
    
}

-(void) initializeWithBeaconDictionary:(NSDictionary *)beaconDictionary
{
    self.sendingBeaconID = [beaconDictionary objectForKey:@"id"];
    
    _beaconDictionary = beaconDictionary;
}


#pragma mark Follow Beacon Handle

-(void) setUpFollowButtonWithArgs:(BOOL)beaconAlreadyFollowed {
    
    if (beaconAlreadyFollowed == YES) {
        [self setFollowButtonFollowed];
    }else if (beaconAlreadyFollowed ==NO) {
        [self setFollowButtonNotFollowed];
    }
    
}

-(void) setFollowButtonFollowed
{
    [followBeaconButtonOutlet setImage:[UIImage imageNamed:@"btn_bvp_followed"] forState:UIControlStateNormal];
    [numberFollowingButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:14]];

}

-(void) setFollowButtonNotFollowed
{
    [followBeaconButtonOutlet setImage:[UIImage imageNamed:@"btn_bvp_follow"] forState:UIControlStateNormal];
    [numberFollowingButton.titleLabel setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:14]];
}


- (IBAction)followBeaconButton:(id)sender {
    
    NSString *method = currentBeaconisFollowed?@"unfollow":@"follow";
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID ,@"beacon",nil] apiMethod:method httpMethod:@"POST"];
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        if(error) return;
        
        // deal with response object
        if ([[response objectForKey:@"success"]boolValue] == YES) {
            currentBeaconisFollowed = !currentBeaconisFollowed;
            [self setUpFollowButtonWithArgs:currentBeaconisFollowed];
            
            _myUserData.followedBeacons = nil;
            
            BOOL wasAlreadyFollowed = [[self.beaconDictionary objectForKey:@"followed"] boolValue];
            int numFollowers = [[self.beaconDictionary objectForKey:@"num_followers"] intValue];
            if(currentBeaconisFollowed && !wasAlreadyFollowed) {
                numFollowers++;
            } else if(!currentBeaconisFollowed && wasAlreadyFollowed) {
                numFollowers--;
            }
            [self setupNumberFollowersButton:numFollowers];
        }
    }];
    
}

//
//-(void) seeBeaconFollowers {
//    
//    _customSlidingTableView = [[[NSBundle mainBundle]loadNibNamed:@"SlidingTableView" owner:self options:nil]objectAtIndex:0];
//    _customSlidingTableView.slidingTableViewTableView.delegate = self;
//    _customSlidingTableView.slidingTableViewTableView.dataSource = _customSlidingTableView;
//    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
//    
//    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
//    //    backgroundNotificationsView.alpha = 0.3;
//    //
//    //    [_customSlidingTableView.slidingTableViewTableView addSubview:backgroundNotificationsView];
//    //    [_customSlidingTableView.slidingTableViewTableView sendSubviewToBack:backgroundNotificationsView];
//    [_customSlidingTableView.slidingTableViewTableView setBackgroundView:backgroundNotificationsView];
//    _customSlidingTableView.slidingTableViewTableView.backgroundView.contentMode = UIViewContentModeCenter;
//    
//    //    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
//    //    [self.view addGestureRecognizer:singleTapRecognizer];
//    
//    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//    void (^cancelOrDoneBlock)() = ^{
//        // we must manually slide out the view out if we specify this block
//        [MFSlidingView slideOut];
//    };
//    
//    [MFSlidingView slideView:_customSlidingTableView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Beacon Followers" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
//    
//    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID,@"beacon", nil] apiMethod:@"beacon/followers" httpMethod:@"GET"];
//    
//    [r startWithCompletionHandler:^(id response, RadiusError *error) {
//        
//        // deal with response object
//        NSLog(@"working %@", response);
//        if ([response isKindOfClass:[NSArray class]]) {
//            responseFollowedArray = response;
//            [_customSlidingTableView setResponseArray:response];
//            [_customSlidingTableView.slidingTableViewTableView reloadData];
//        }else if ([response isKindOfClass:[NSDictionary class]]){
//            
//            responseFollowedDictionary = response;
//            [_customSlidingTableView setResponseDictionary:response];
//            [_customSlidingTableView.slidingTableViewTableView reloadData];
//            
//            
//        }
//        
//        
//        
//        
//    }];
//    
//    
//    
//    
//    
//}

- (void) setupFollowersTab {
    
    self.beaconFollowersDataSourceInstance = [[BeaconFollowers alloc] init];
    //    BeaconFollowers *beaconFollowersDataSourceInstance = [[BeaconFollowers alloc] init];
    //    SlidingTableView *tableDataSourceInstance = [[SlidingTableView alloc]init];
    
    beaconFollowersTableViewOutlet.delegate = self;
    beaconFollowersTableViewOutlet.dataSource = beaconFollowersDataSourceInstance;
    
    //    UIImage *img = [UIImage imageNamed:@"bkgd_generic.png"];
    //
    //    UIImageView *backgroundNotificationsView = [[UIImageView alloc] initWithImage:img];
    //    [beaconFollowersTableViewOutlet setBackgroundView:backgroundNotificationsView];
    //    beaconFollowersTableViewOutlet.backgroundView.contentMode = UIViewContentModeCenter;
    
    //    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID,@"beacon", nil] apiMethod:@"beacon/followers" httpMethod:@"GET"];
    //
    //    [r startWithCompletionHandler:^(id response, RadiusError *error) {
    //
    //        // deal with response object
    //        NSLog(@"working %@", response);
    //        if ([response isKindOfClass:[NSArray class]]) {
    //
    //            responseFollowedArray = response;
    //            [tableDataSourceInstance setResponseArray:response];
    //            [beaconFollowersTableViewOutlet reloadData];
    //
    //        }else if ([response isKindOfClass:[NSDictionary class]]){
    //
    //            responseFollowedDictionary = response;
    //            [tableDataSourceInstance setResponseDictionary:response];
    //            [beaconFollowersTableViewOutlet reloadData];
    //
    //
    //        }
    //
    //    }];
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID,@"beacon", nil] apiMethod:@"beacon/followers" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(error) return;
        
        // deal with response object
        NSLog(@"working %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            
            responseFollowedArray = response;
            [beaconFollowersDataSourceInstance setResponseArray:response];
            [beaconFollowersTableViewOutlet reloadData];
            
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseFollowedDictionary = response;
            [beaconFollowersDataSourceInstance setResponseDictionary:response];
            [beaconFollowersTableViewOutlet reloadData];
            
            
        }
        
    }];
}

#pragma mark Post Content Handle

//- (IBAction)whosFollowingPressed
//{
//    [self seeBeaconFollowers];
//}

-(void) newPostContentMethod {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"What Do You Want To Post?" delegate:self
                                  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                  otherButtonTitles:@"Bulletin", @"Upload a Picture", @"Take a Picture Now", @"Post a Link", nil];
    [actionSheet showInView:self.view];
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark Media Picker and Camera Handle

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (void) getDescriptionWithThumbnail: (UIImage *) thumb AndCompletionHandler:( void ( ^ )(DescribeContentView *describeView,  NSString * description, BOOL fbShare ) )handler;
{
    
    // present view
    
    //describeContentView = [[[NSBundle mainBundle]loadNibNamed:@"DescribeContentView" owner:self options:nil]objectAtIndex:0];
    //describeContentView = [[DescribeContentView alloc] initWithFrame:CGRectMake(0, 0, 300, 345) handler:handler];
    self.describe = [[DescribeContentView alloc] initWithFrame:CGRectMake(0, 0, 300, 345) handler:handler];
    
    [self.describe setupWithBeaconName:[self.beaconDictionary objectForKey:@"name"] andThumbnail:thumb];
    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
    void (^cancelOrDoneBlock)() = ^{
        // we must manually slide out the view out if we specify this block
        [MFSlidingView slideOut];
    };
    
    [MFSlidingView slideView:self.describe intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
}

- (void) uploadImage:(UIImage *)imageToUse {
    
    if(self.modalViewController) {
        [self performSelector:@selector(uploadImage:) withObject:imageToUse afterDelay:0.1f];
        return;
    }
    
    double widthToHeightRatio = imageToUse.size.width/imageToUse.size.height;
    UIImage *croppedImg;
    
    //Creating square thumbnail for the description view
    if (widthToHeightRatio > 1)
    {
        int widthToChop = imageToUse.size.width - imageToUse.size.height;
        CGRect croppedRect = CGRectMake(widthToChop/2, 0, imageToUse.size.width-widthToChop, imageToUse.size.height);
        CGImageRef imageRef = CGImageCreateWithImageInRect([imageToUse CGImage], croppedRect);
        croppedImg = [UIImage imageWithCGImage:imageRef scale:imageToUse.scale orientation:imageToUse.imageOrientation];
    }
    else if (widthToHeightRatio < 1)
    {
        int heightToChop = imageToUse.size.height - imageToUse.size.width;
        CGRect croppedRect = CGRectMake(0, heightToChop/2, imageToUse.size.width, imageToUse.size.height-heightToChop);
        CGImageRef imageRef = CGImageCreateWithImageInRect([imageToUse CGImage], croppedRect);
        croppedImg = [UIImage imageWithCGImage:imageRef scale:imageToUse.scale orientation:imageToUse.imageOrientation];
    }
    else croppedImg = imageToUse;
    
    [self getDescriptionWithThumbnail:croppedImg AndCompletionHandler:^(DescribeContentView *describeView, NSString *description, BOOL fbShare) {
        
        // Block taps on entire screen while trying to upload
        UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
        UIView *tapBlockerView = [[UIView alloc] initWithFrame:keyWindow.bounds];
        [keyWindow addSubview:tapBlockerView];
        
        connectionResponseData = [[NSMutableData alloc] init];
        
        UIImage *resizedImage = [imageToUse scaleToSize:CGSizeMake(1200, 900)];
                
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.9f);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID,@"beacon", [defaults objectForKey:@"token"], @"token", nil]];
        if (fbShare) [paramsDict setObject:@"true" forKey:@"fb_share"];
        if (description != nil) [paramsDict setObject:description forKey:@"description"];
        
        RadiusRequest *r = [RadiusRequest requestWithParameters:paramsDict apiMethod:@"upload_image" multipartData:imageData,@"image/jpeg",@"image.jpg",@"image",nil];
        
        r.dataDelegate = self;
    
        void (^uploadError)() = ^{
            [tapBlockerView removeFromSuperview];
            
            [describeView.progressView setProgress:0 animated:NO];
            
            PopupView *uploadFailedAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
            [uploadFailedAlert setupWithDescriptionText:@"Upload failed.  Try again." andButtonText:@"OK"];
            SlidingViewOptions options = 0;// CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
            };
            [MFSlidingView slideView:uploadFailedAlert intoView:self.view.window onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        };
        
        [r startWithCompletionHandler:^(id response, RadiusError *error) {
            
            if(error) {
                uploadError();
                
                NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
                [Flurry logEvent:@"Content_Post_Image_Upload_Failed" withParameters:eventParameters];
                
            } else {
                
                NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
                [Flurry logEvent:@"Content_Post_Image_Posted" withParameters:eventParameters];
                
                [tapBlockerView removeFromSuperview];
                
                [MFSlidingView slideOut];
                [self dismissPostView];
                
                PopupView *uploadCompleteAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
                [uploadCompleteAlert setupWithDescriptionText:@"Upload Complete!" andButtonText:@"OK"];
                SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                void (^cancelOrDoneBlock)() = ^{
                    // we must manually slide out the view out if we specify this block
                    [MFSlidingView slideOut];
                };
                [MFSlidingView slideView:uploadCompleteAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                
                [self populateBeaconContent];
            }
        } failureHandler:^(NSError *error) {
            uploadError();
        }];
    }];
}

- (void) connectUserWithFacebook
{
    NSString *facebookAppID = [[NSBundle mainBundle].infoDictionary objectForKey:@"FacebookAppID"];
    FBSession *s = [[FBSession alloc] initWithAppID:facebookAppID permissions:[NSArray arrayWithObjects:@"email",@"publish_actions",nil] defaultAudience:FBSessionDefaultAudienceFriends urlSchemeSuffix:nil tokenCacheStrategy:nil];
    
    [FBSession setActiveSession:s];
    
    [s openWithCompletionHandler:^(FBSession *session,
                                   FBSessionState status,
                                   NSError *error)
     {
         
         // session might now be open.
         if (session.isOpen)
         {
             NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:session.accessToken,@"fb_access_token",nil];
             RadiusRequest *request = [RadiusRequest requestWithParameters:payload apiMethod:@"connect_facebook" httpMethod:@"POST"];
             [request startWithCompletionHandler:^(id response, RadiusError *error) {
                 if(error) {
                     // something went wrong
                     NSLog(@"%@",response);
                     
                     if(error.type==RadiusErrorFbAlreadyConnected) {
                         PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
                         [popupAlert setupWithDescriptionText:@"This Facebook account is already connected to a Radius account!" andButtonText:@"OK"];
                         SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
                         void (^cancelOrDoneBlock)() = ^{
                             // we must manually slide out the view out if we specify this block
                             [MFSlidingView slideOut];
                         };
                         [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
                     }
                 }
                 
             }];
         }
     }];
    
    NSLog(@"started to open session");
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        [self uploadImage:imageToUse];
        
        // Do something with imageToUse
    }
    
    // Handle a movie picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        PopupView *popupAlert = [[[NSBundle mainBundle]loadNibNamed:@"PopupView" owner:self options:nil]objectAtIndex:0];
        [popupAlert setupWithDescriptionText:@"You tried to pick a movie, try picking an image" andButtonText:@"OK"];
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:popupAlert intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        // Do something with the picked movie available at moviePath
    }
    
    //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setUploadProgress:(NSNumber *)progress {
    float p = [progress floatValue];
    //Set progress on a scale of 0-90% instead of 100% because of radius request at end
    [self.describe.progressView setProgress:(p*.9) animated:YES];
}

NSMutableData *connectionResponseData = nil;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [connectionResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    float progress = totalBytesWritten/ (float)totalBytesExpectedToWrite;
    
    [self performSelectorOnMainThread:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    //    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Beacon Information and Content Handle

- (IBAction)viewBeaconCreatorProfile:(id)sender {
    
    NSLog(@"profiling");
    
    ProfileViewController2 *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
    [newViewController initializeWithUserID:userNameString.integerValue];
    [self.navigationController pushViewController:newViewController animated:YES];
    
}

-(void) reloadBeaconContentDataTable {
    
    [self populateBeaconContent];
    
}

-(void) reloadConversationTable
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.sendingBeaconID, @"beacon", nil] apiMethod:@"conversation"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        if(error) return;
        
        NSLog(@"reloaded conversation for beacon is: %@", response);
        convoArray = response;
        [convoTable reloadData];
    }];
}

-(void) populateBeaconContent {
    
    RadiusRequest *beaconContentRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacon", @"10", @"limit", nil] apiMethod:@"beacon_content"];
    [beaconContentRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(error) return;
        
        //[[self.navigationController.view viewWithTag:DIMVIEW_BLOCKING_TAG] removeFromSuperview];
        [self dismissLoadingOverlay];
        
        jsonArray = [response mutableCopy];
        
        contentOffset = jsonArray.count;
        
        [self renderBeaconContent];
    }];
    
}

-(void) renderBeaconContent {
    [myGridView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self loadHappeningNowImage];
    
    int rowCount = jsonArray.count > 0 ? ceil(([jsonArray count]-1)/3.0) : 0;
    
    [self setupScrollViewForHappeningNowAndGridWithRowCount:rowCount];
}

-(void) getBeaconInfo:(NSUInteger)beaconID {
    RadiusRequest *beaconInfoRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacons", nil] apiMethod:@"beacon_info"];
    [beaconInfoRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        if(error) return;
        
        self.jsonInfoArray = response;
        NSString *idString = [NSString stringWithFormat:@"%d", beaconID];
        
        self.beaconDictionary = [jsonInfoArray objectForKey:idString];
        
        [self processBeaconInfo:self.beaconDictionary];
    }];
}

-(void) processBeaconInfo:(NSDictionary *)beaconDictionary
{
    userNameString = [beaconDictionary objectForKey:@"creator"];
    [self findUserInfo];
    
    NSString *beaconName = [beaconDictionary objectForKey:@"name"];
    [beaconNameOutlet setText:beaconName];
    beaconNameString = beaconName;
    self.title = beaconName;
    
    if ([[beaconDictionary objectForKey:@"followed"]integerValue] == YES) {
        self.currentBeaconisFollowed = YES;
    }else {
        self.currentBeaconisFollowed = NO;
    }
    
    [self setUpFollowButtonWithArgs:currentBeaconisFollowed];
    
    CLLocationDegrees beaconLat = [[[beaconDictionary objectForKey:@"center"] objectAtIndex:0] doubleValue];
    CLLocationDegrees beaconLng = [[[beaconDictionary objectForKey:@"center"] objectAtIndex:1] doubleValue];
    CLLocationDegrees beaconLatOffset = [[[beaconDictionary objectForKey:@"center"] objectAtIndex:0] doubleValue]+.0003;

    CLLocationDegrees beaconLngOffset = [[[beaconDictionary objectForKey:@"center"] objectAtIndex:1] doubleValue]+.0010;



    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(beaconLat, beaconLng);
    CLLocationCoordinate2D locationOffset = CLLocationCoordinate2DMake(beaconLatOffset, beaconLngOffset);

    
    [self setMapLocation:locationOffset];
//    [self setMapLocation:location];

    [contentMapView removeAnnotations:contentMapView.annotations];
    CreateBeaconAnnotation *newAnnotation = [[CreateBeaconAnnotation alloc] init];
    [newAnnotation setCoordinate:location];
    [contentMapView addAnnotation:newAnnotation];
    
    NSURL *pinURL = [NSURL URLWithString:[beaconDictionary objectForKey:@"pin"]];
    [self setPinFromURL:pinURL];
    
    [self setupNumberFollowersButton:[[beaconDictionary objectForKey:@"num_followers"] intValue]];
    
    if ([beaconDictionary objectForKey:@"access_status"]) {
        [self setupBeaconPrivacyWithArgument:[NSString stringWithFormat:@"%@",[beaconDictionary objectForKey:@"access_status"]]];
    }
    
    if ([[beaconDictionary objectForKey:@"private"]integerValue] == 1) {
        self.beaconIsPrivate = YES;
    }else if (![[beaconDictionary objectForKey:@"private"]integerValue] == 0){
        self.beaconIsPrivate = NO;
    }
}


-(void) findUserInfo {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userNameString ,@"user", nil] apiMethod:@"userinfo" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(error) return;
        
        // deal with response object
        NSLog(@"working %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseArray = response;
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseDictionary = response;
            NSURL *imageURL = [NSURL URLWithString:[responseDictionary objectForKey:@"picture_thumb"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *profilePicture = [UIImage imageWithData:imageData];
            [self.beaconCreatorProfileButton setImage:profilePicture forState:UIControlStateNormal];
            [creatorNameLabel setText:[responseDictionary objectForKey:@"display_name"]];
        }
    }];
    
}

static const CLLocationDegrees SPAN_LATITUDE = 0.001;
static const CLLocationDegrees SPAN_LONGITUDE = 0.002;

-(void) setMapLocation:(CLLocationCoordinate2D)location  {
    
    MKCoordinateRegion region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(SPAN_LATITUDE, SPAN_LONGITUDE));
    
    [self.contentMapView setRegion:region animated:NO];
}

- (void) findUserInfoForCurrentUser {
    
    currentUserNameString = [NSString stringWithFormat:@"%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] integerValue]];
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:currentUserNameString ,@"user", nil] apiMethod:@"userinfo" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(error) return;
        
        // deal with response object
        NSLog(@"working %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseArray = response;
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseUserInfoDictionary = response;
            [convoTable reloadData];
        }
    }];
    
}

#pragma mark View for Table Cells, Annotations and Overlays Handle

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.lineWidth = 1;
    return circleView;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    
    static NSString *annotationIdentifier=@"MyAnnotationIdentifier";
    
    beaconAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    beaconAnnotationView.draggable = NO;
    beaconAnnotationView.image = [UIImage imageNamed:@"ico_beaconpin_blank.png"];
    beaconAnnotationView.frame = CGRectMake(0, 0, ANNOTATION_SIZE, ANNOTATION_SIZE);
    beaconAnnotationView.centerOffset = CGPointMake(0,-ANNOTATION_SIZE/2);
    
    return beaconAnnotationView;
    
}

static const CGFloat ANNOTATION_SIZE = 50;

-(void)setPinFromURL:(NSURL*)pinURL
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSData *pinImageData = [NSData dataWithContentsOfURL:pinURL];
        UIImage *pinImage = [UIImage imageWithData:pinImageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect oldFrame = beaconAnnotationView.frame;
            beaconAnnotationView.image = pinImage;
            beaconAnnotationView.frame = oldFrame;
        });
    });
}




- (IBAction)topContentPressed:(id)sender{
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Looked at a Beacon's Content"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
    [Flurry logEvent:@"Beacon_Content_Pressed" withParameters:eventParameters];
    
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    [self setStateTopContentSelected];
}
- (IBAction)liveConversationPressed:(id)sender{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Looked at a Beacon's Conversation"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
    [Flurry logEvent:@"Beacon_Conversation_Pressed" withParameters:eventParameters];
    
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    [self setStateLiveConversationSelected];
}

- (IBAction)locationInfoPressed:(id)sender {
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Looked at a Beacon's Followers"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
    [Flurry logEvent:@"Beacon_Followers_Pressed" withParameters:eventParameters];
    
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    [self setStateLocationInfoSelected];
}

-(void)setStateTopContentSelected
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
//                         [topContentButton setSelected:YES];
//                         [liveConversationButton setSelected:NO];
//                         [locationInfoButton setSelected:NO];
                         
                         [topContentButton setAlpha:1];
                         [liveConversationButton setAlpha:.4];
                         [locationInfoButton setAlpha:.4];
                         
                         [myScrollViewOutlet setHidden:NO];
                         [convoTable setHidden:YES];
                         [locationInfoScrollView setHidden:YES];
                         [beaconFollowersTableViewOutlet setHidden:YES];
                         [creatorView setHidden:YES];
                         [[self.view viewWithTag:ADD_NEW_CONTENT_BUTTON_TAG] setHidden:NO];
                         [transparencyImageView setHidden:NO];

                         
                     }completion:^(BOOL finished) {
                         

                         
                     }];

}

-(void)setStateLiveConversationSelected
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
//                         [topContentButton setSelected:YES];
//                         [liveConversationButton setSelected:NO];
//                         [locationInfoButton setSelected:NO];
                         
                         [topContentButton setAlpha:.4];
                         [liveConversationButton setAlpha:1];
                         [locationInfoButton setAlpha:.4];
                         
                         [myScrollViewOutlet setHidden:YES];
                         [convoTable setHidden:NO];
                         [locationInfoScrollView setHidden:YES];
                         [beaconFollowersTableViewOutlet setHidden:YES];
                         [creatorView setHidden:YES];
                         [[self.view viewWithTag:ADD_NEW_CONTENT_BUTTON_TAG] setHidden:YES];
                         [transparencyImageView setHidden:YES];

                     }completion:^(BOOL finished) {
                         



                         
                     }];
    
//    [UIView beginAnimations:nil context:nil];
//    [topContentButton setSelected:NO];
//    [liveConversationButton setSelected:YES];
//    [locationInfoButton setSelected:NO];
//    [myGridView setHidden:YES];
//    [convoTable setHidden:NO];
//    [locationInfoScrollView setHidden:YES];
//    [beaconFollowersTableViewOutlet setHidden:YES];
//    [creatorView setHidden:YES];
//    [happeningNowViewOutlet setHidden:YES];
//
//    [UIView commitAnimations];
    
}

-(void)setStateLocationInfoSelected
{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         
//                         [topContentButton setSelected:YES];
//                         [liveConversationButton setSelected:NO];
//                         [locationInfoButton setSelected:NO];
                         
                         [topContentButton setAlpha:.4];
                         [liveConversationButton setAlpha:.4];
                         [locationInfoButton setAlpha:1];
                         
                         [myScrollViewOutlet setHidden:YES];
                         [convoTable setHidden:YES];
                         [locationInfoScrollView setHidden:YES];
                         [beaconFollowersTableViewOutlet setHidden:NO];
                         [creatorView setHidden:NO];
                         [[self.view viewWithTag:ADD_NEW_CONTENT_BUTTON_TAG] setHidden:YES];
                         [transparencyImageView setHidden:YES];

                         
                     }completion:^(BOOL finished) {
                         



                         
                     }];
    
//    [UIView beginAnimations:nil context:nil];
//    [topContentButton setSelected:NO];
//    [liveConversationButton setSelected:NO];
//    [locationInfoButton setSelected:YES];
//    [myGridView setHidden:YES];
//    [convoTable setHidden:YES];
//    [locationInfoScrollView setHidden:YES];
//    [beaconFollowersTableViewOutlet setHidden:NO];
//    [creatorView setHidden:NO];
//    [happeningNowViewOutlet setHidden:YES];
//    [UIView commitAnimations];
    
}

-(void) setupTabButtons
{
    [topContentButton setBackgroundImage:[UIImage imageNamed:@"btn_bvp_photos_highlight.png"] forState:UIControlStateSelected];
    [topContentButton setBackgroundImage:[UIImage imageNamed:@"btn_bvp_photos_highlight.png"] forState:UIControlStateHighlighted];
    [liveConversationButton setBackgroundImage:[UIImage imageNamed:@"btn_bvp_liveconversation_highlight.png"] forState:UIControlStateSelected];
    [liveConversationButton setBackgroundImage:[UIImage imageNamed:@"btn_bvp_liveconversation_highlight.png"] forState:UIControlStateHighlighted];
    [locationInfoButton setBackgroundImage:[UIImage imageNamed:@"btn_bvp_followers_highlight@2x.png"] forState:UIControlStateSelected];
    [locationInfoButton setBackgroundImage:[UIImage imageNamed:@"btn_bvp_followers_highlight@2x.png"] forState:UIControlStateHighlighted];
    [creatorNameLabel setFont:[UIFont fontWithName:@"Quicksand" size:creatorNameLabel.font.pointSize]];
    CALayer *layer = [beaconCreatorProfileButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0];
    [self setStateTopContentSelected];
}

-(void)setupNavTicker
{
    ticker = [[CLTickerView alloc] initWithFrame:CGRectMake(60, 0, 210, 44)];
    ticker.marqueeStr = @"Sunnyvale Sunoco Professional Motor Speedway          Sunnyvale Sunoco Professional Motor Speedway";
    //ticker.marqueeStr = self.navigationItem.title;
    self.navigationItem.title = @"";
    NSDictionary *textDict = self.navigationController.navigationBar.titleTextAttributes;
    ticker.marqueeFont = [UIFont fontWithName:@"QuicksandBold-Regular" size:18.0]; //[UIFont boldSystemFontOfSize:16];
    //ticker.marqueeFont = [self.navigationController.navigationBar.titleTextAttributes objectForKey:@"font"];
    
    [self.navigationController.navigationBar addSubview:ticker];
}

#pragma mark Apple Methods Handle


- (void)viewDidLoad
{
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Looked at a Beacon's Page"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
    [Flurry logEvent:@"Beacon_Viewed" withParameters:eventParameters];
    
    [super viewDidLoad];
    
    _myUserData = [RadiusUserData sharedRadiusUserData];

    
    [contentMapView setDelegate:self];
    [contentMapView setMapType:MKMapTypeSatellite];
    contentMapView.scrollEnabled = NO;
    contentMapView.zoomEnabled = NO;
    
    
    [self setupTabButtons];
    [self setupCreatorPanel];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    
	// Do any additional setup after loading the view.
    [self setupSideMenuBarButtonItem];
    //[self populateConversationContent];
    
    
    if(self.beaconDictionary) {
        [self processBeaconInfo:self.beaconDictionary];
    } else {
        [self getBeaconInfo:[sendingBeaconID integerValue]];
    }
    
    [self setupConvoTable];
    [self populateConvoTable];
    [self populateBeaconContent];
    [self populateLocationInfo];
    [self setupLocationInfoAppearance];
    [self setupFollowersTab];
    [self findUserInfoForCurrentUser];
    //[self setupActivityIndicatorAndDimView];
    
    [self setupDiscoverBeaconButton];
    
    [self setSwipeCount:0];
    alreadyPostingChatter = NO;

    [self.myGridView setBackgroundColor:[UIColor clearColor]];
    
    [self setupBeaconCongratsView];
    
    [self.convoTable setBackgroundColor:[UIColor clearColor]];
    [self.beaconFollowersTableViewOutlet setBackgroundColor:[UIColor clearColor]];
    
    [self setupHappeningNowView];
    [self setupTransparencyView];
    [self setupNewAddContentButton];
    
    [self showLoadingOverlay];

    
//    [self setupBeaconSettingsButtonWithCurrentUserBoolean:currentUserIsBeaconCreator];

    //[self setupNavTicker];
}



- (void)viewDidUnload
{
    [self setBeaconNameOutlet:nil];
    [self setBeaconContentOutlet:nil];
    [self setBeaconLocationOutlet:nil];
    [self setContentMapView:nil];
    [self setContentTableView:nil];
    
    [self setFollowBeaconButtonOutlet:nil];
    [self setPostContentButton:nil];
    [self setBeaconCreatorProfileButton:nil];
    [self setConvoTable:nil];
    [self setTopContentButton:nil];
    [self setLiveConversationButton:nil];
    [self setLocationInfoButton:nil];
    [self setBeaconCreatorSettingsButtonOutlet:nil];
    [ticker removeFromSuperview];
    [self setTicker:nil];
    [self setCreatorView:nil];
    [self setCreatorNameLabel:nil];
    [self setHappeningNowViewOutlet:nil];
    [self setMyScrollViewOutlet:nil];
    [self setNoContentMessageOutlet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor clearColor],
                                                                     UITextAttributeTextColor,
                                                                     [UIColor whiteColor],
                                                                     UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                                     UITextAttributeTextShadowOffset,
                                                                     [UIFont fontWithName:@"QuicksandBold-Regular" size:20.0],
                                                                     UITextAttributeFont,
                                                                     nil]];
    
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor clearColor],
                                                                     UITextAttributeTextColor,
                                                                     [UIColor whiteColor],
                                                                     UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                                     UITextAttributeTextShadowOffset,
                                                                     [UIFont fontWithName:@"QuicksandBold-Regular" size:24.0],
                                                                     UITextAttributeFont,
                                                                     nil]];
    
    
}

#pragma mark UIGridViewMethods

//Code for UIGridView

- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{
	return 106;
}

- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{
	return 106;
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
	return 3;
}


- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
    // subtract one for the featured item
    return [jsonArray count]-1;
}


//Helper method to convert to linear index rather than row/column pairing
-(NSInteger) convertToCellNumberFromRow:(int)rowIndex AndColumn:(int)columnIndex
{
    NSInteger result = (rowIndex * [self numberOfColumnsOfGridView:nil])+(columnIndex);
    result++; // add one to offset for the featured item
    return result;
}

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
        
    int cellNumber = [self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex];
    
    Cell *cell = (Cell *)[grid dequeueReusableCell];
    
    if (cell == nil)
    {
        cell = [[Cell alloc] init];
    }
    
    [[cell viewWithTag:CELL_IMAGEVIEW_TAG] removeFromSuperview];
    
    cell.thumbnail.image = nil;
    
    NSDictionary *currDictionary = [jsonArray objectAtIndex:(cellNumber)];
    
    AsyncImageView *aiv = [[AsyncImageView alloc] initWithFrame:cell.thumbnail.frame];
    aiv.imageView.contentMode = UIViewContentModeScaleAspectFill;
    aiv.clipsToBounds = YES;
    aiv.layer.cornerRadius = 5.0f;
    aiv.tag = CELL_IMAGEVIEW_TAG;
    [cell addSubview:aiv];
    
    if ([[currDictionary objectForKey:@"content"] objectForKey:@"url"] != nil) {
        
        NSMutableString *urlString = [[[currDictionary objectForKey:@"content"] objectForKey:@"thumb"] mutableCopy];

        
        aiv.imageURL = [NSURL URLWithString:urlString];
        [aiv loadImage];
    }

    return cell;
}

- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    
        NSDictionary *currDictionary = [jsonArray objectAtIndex:([self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex])];
        
        if ([[currDictionary objectForKey:@"content"] objectForKey:@"text"] != nil) {
            
            BeaconDetailContentViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailContentID"];
            [newViewControllerInstance setTitle:beaconNameOutlet.text];
            [newViewControllerInstance setBeaconContentDictionary:currDictionary];
            [newViewControllerInstance setContentString:[[currDictionary objectForKey:@"content"] objectForKey:@"text"]];
            [newViewControllerInstance setContentID:[currDictionary objectForKey:@"id"]];
            [newViewControllerInstance setContentType:@"text"];
            [newViewControllerInstance setUserNameString:[currDictionary objectForKey:@"display_name"]];
            
            if ([[currDictionary objectForKey:@"vote"]integerValue] == -1) {
                [newViewControllerInstance setContentVotedDown:YES];
            }else if ([[currDictionary objectForKey:@"vote"]integerValue] == 0) {
                [newViewControllerInstance setContentNotVotedYet:YES];
            }else if ([[currDictionary objectForKey:@"vote"]integerValue] == 1) {
                [newViewControllerInstance setContentVotedUp:YES];
            }
            [newViewControllerInstance setContentVoteScore:[currDictionary objectForKey:@"score"]];
            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
            
            //        NSArray *controllers = [NSArray arrayWithObject:newViewControllerInstance];
            //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            
        }else if ([[currDictionary objectForKey:@"content"] objectForKey:@"video_id"] != nil) {
            
            BeaconDetailContentVideoViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailVideoContentID"];
            
            [newViewControllerInstance setTitle:beaconNameOutlet.text];
            [newViewControllerInstance setBeaconContentDictionary:currDictionary];
            [newViewControllerInstance setContentString:[[currDictionary objectForKey:@"content"] objectForKey:@"video_id"]];
            [newViewControllerInstance setContentID:[currDictionary objectForKey:@"id"]];
            [newViewControllerInstance setContentType:@"video_ext"];
            [newViewControllerInstance setCommentCountString:[NSString stringWithFormat:@"%@",[currDictionary objectForKey:@"num_comments"]]];
            [newViewControllerInstance setLikeCountString:[NSString stringWithFormat:@"%@",[currDictionary objectForKey:@"score"]]];
            [newViewControllerInstance setUserNameString:[currDictionary objectForKey:@"display_name"]];
            if ([[currDictionary objectForKey:@"vote"]integerValue] == -1) {
                [newViewControllerInstance setContentVotedDown:YES];
            }else if ([[currDictionary objectForKey:@"vote"]integerValue] == 0) {
                [newViewControllerInstance setContentNotVotedYet:YES];
            }else if ([[currDictionary objectForKey:@"vote"]integerValue] == 1) {
                [newViewControllerInstance setContentVotedUp:YES];
            }
            [newViewControllerInstance setContentVoteScore:[currDictionary objectForKey:@"score"]];
            [newViewControllerInstance setBeaconDetailContentVideoDelegate:self];
            
            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
            
            //        NSArray *controllers = [NSArray arrayWithObject:newViewControllerInstance];
            //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
            
        }else if ([[currDictionary objectForKey:@"content"] objectForKey:@"url"] != nil) {
            
            BeaconDetailContentImageViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailImageContentID"];
            [newViewControllerInstance setTitle:beaconNameOutlet.text];
            [newViewControllerInstance setImageArray:jsonArray];
            [newViewControllerInstance setBeaconIDString:sendingBeaconID];
            [newViewControllerInstance setBeaconNameString:[self.beaconDictionary objectForKey:@"name"]];
            [newViewControllerInstance setContentType:@"image"];
            [newViewControllerInstance setBeaconContentDictionary:currDictionary];
            [newViewControllerInstance initializeBeaconContentImage];

            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
            

            
            
        }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [convoArray count]+1;
    //return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    //Special cell at the beginning to start a new thread
    if (indexPath.row == 0)
    {
        static NSString *convoCellIdentifier = @"MyJoinConvoCell";
        UITableViewCell *convoCell = [tableView dequeueReusableCellWithIdentifier:convoCellIdentifier];
        
        if (convoCell == nil) {
            convoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                               reuseIdentifier:convoCellIdentifier];
            
        }
        convoCell.textLabel.text = nil;
        convoCell.detailTextLabel.text = nil;
        convoCell.accessoryView = nil;
        
        chatterTextView = [[UITextView alloc] initWithFrame:convoCell.frame];
        chatterTextView.backgroundColor = [UIColor whiteColor];
        chatterTextView.layer.cornerRadius = 5;
        chatterTextView.text = REPLY_PLACEHOLDER;
        chatterTextView.textColor = [UIColor grayColor];

        chatterTextView.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:16];
        chatterTextView.returnKeyType = UIReturnKeySend;
        
        chatterTextView.delegate = self;

        [convoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [convoCell.contentView addSubview:chatterTextView];
        
//        convoCell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18];
//        UIView *bgColorView = [[UIView alloc] init];
//        [bgColorView setBackgroundColor:[UIColor colorWithRed:0.349 green:0.035 blue:0 alpha:1] /*#590900*/];
//        [convoCell setSelectedBackgroundView:bgColorView];
//        
//        
//        UIImage *joinConversationBubbleImage = [UIImage imageNamed:@"btn_bvp_joinconversation@2x.png"];
//        UIImageView *joinConversationBubbleImageView = [[UIImageView alloc]initWithImage:joinConversationBubbleImage];
//        joinConversationBubbleImageView.frame = CGRectMake(0, 0, 320, 60);
//        
//        NSURL *imageURL = [NSURL URLWithString:[responseUserInfoDictionary objectForKey:@"picture"]];
//        
//        AsyncImageView *profilePictureImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(8, 5, 50, 50) imageURL:imageURL cache:nil];
//        profilePictureImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        profilePictureImageView.layer.cornerRadius = 5;
//        
//        [joinConversationBubbleImageView addSubview:profilePictureImageView];
//        [convoCell addSubview:joinConversationBubbleImageView];
        
        
        
        return convoCell;
        
    }
    else
    {
        
        if (convoArray && [convoArray isKindOfClass:[NSArray class]])
        {
            static NSString *CellIdentifier = @"MyNormalCell";
            
            ThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[ThreadTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            cell.accessoryView = nil;
            //cell.textLabel.text = @"This is the title of the thread.  It can be however long it needs to be beacuse it's really a long post.";
            //cell.detailTextLabel.text = @"Multi-Line\nText";
            
            NSDictionary *thread = [convoArray objectAtIndex:(indexPath.row-1)];
            [cell setupThreadDetails:thread];
            
            
            return cell;
            
        }
        
        
    }
    return nil;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"num of lines is: %i", [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.numberOfLines);
    //    NSLog(@"detail text label is: %@", [tableView cellForRowAtIndexPath:indexPath].detailTextLabel);
    //    if ([tableView cellForRowAtIndexPath:indexPath].detailTextLabel)
    //    {
    //        return (44.0 + ([tableView cellForRowAtIndexPath:indexPath].detailTextLabel.numberOfLines - 1) * 19.0);
    //    }
    
    if (tableView == convoTable) {
        
        if (indexPath.row == 0) {
            return 60;
        }
        
    }
    
    return 50;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Responding to sliding view to see who's following the beacon
    if ([tableView.dataSource isMemberOfClass:[SlidingTableView class]] || [tableView.dataSource isMemberOfClass:[BeaconFollowers class]])
    {
        ProfileViewController2 *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
        //NSString *userIDString = [NSString stringWithFormat:@"%@",[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] ];
        [meProfileController initializeWithUserID:[[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]];
        
        [self.navigationController pushViewController:meProfileController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if([tableView.dataSource isMemberOfClass:[SlidingTableView class]]) {
            [MFSlidingView slideOut];
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            
            
//            self.postThreadView = [[PostThreadView alloc] initWithSendingBeaconID:sendingBeaconID andUserTokenString:userTokenString];
//            self.postThreadView.postThreadViewDelegate = self;
//            
//            //            UITapGestureRecognizer *recognizerForSubView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehindAgain:)];
//            //            [recognizerForSubView setNumberOfTapsRequired:1];
//            //            recognizerForSubView.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
//            //            [customView addGestureRecognizer:recognizerForSubView];
//            
//            
//            UIView *dimView = [[UIView alloc] init];
//            dimView.frame= CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
//            dimView.backgroundColor = [UIColor blackColor];
//            dimView.alpha = 0.6;
//            dimView.tag = DIMVIEW_BLOCKING_TAG;
//            [self.view addSubview:dimView];
//            
//            UIView *dimViewForNavBar = [[UIView alloc] init];
//            dimViewForNavBar.frame= CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
//            dimViewForNavBar.backgroundColor = [UIColor blackColor];
//            dimViewForNavBar.alpha = 0.6;
//            dimViewForNavBar.tag = DIMVIEW_BLOCKING_TAG;
//            
//            UIPanGestureRecognizer *recognizerToBlock = [[UIPanGestureRecognizer alloc]initWithTarget:self action:nil];
//            [dimViewForNavBar addGestureRecognizer:recognizerToBlock];
//            [self.navigationController.navigationBar addSubview:dimViewForNavBar];
//            
//            
//            [self catchTapForNavBar:dimViewForNavBar];
//            [self catchTapForView:self.view];
//            //            [self catchTapForView:self.navigationController.view];
//            
//            //            [customView setFrame:CGRectMake( 0.0f, -480.0f, customView.frame.size.width, customView.frame.size.height)];
//            //            [self.view addSubview:customView];
//            //
//            //            [UIView beginAnimations:@"animateThreadView" context:nil];
//            //            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//            //
//            //            [UIView setAnimationDuration:0.4];
//            //            customView.frame= CGRectMake(10, 100, customView.frame.size.width, customView.frame.size.height);
//            //            [UIView commitAnimations];
//            
//            self.postThreadView.frame= CGRectMake(0, 0, 0, 225);
//            self.postThreadView.transform = CGAffineTransformMakeScale(0,0);
//            
//            [self.view addSubview:self.postThreadView];
//            
//            
//            //    [customView setFrame:CGRectMake( 0.0f, 480.0f, customView.frame.size.width, customView.frame.size.height)];
//            
//            
//            [UIView animateWithDuration:0.4
//                                  delay:0
//                                options:UIViewAnimationCurveEaseInOut
//                             animations:^ {
//                                 
//                                 self.postThreadView.transform = CGAffineTransformIdentity;
//                                 self.postThreadView.frame = CGRectMake(10, 50, 300, 300);
//                                 [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                                 
//                                 
//                             }completion:^(BOOL finished) {
//                                 
//                             }];
            
        }
        else
        {
            ConvoThreadViewController *threadController = [self.storyboard instantiateViewControllerWithIdentifier:@"convoThreadID"];
            [threadController initializeWithThreadID:[[[convoArray objectAtIndex:(indexPath.row-1)] objectForKey:@"id"] integerValue] threadTitle:[[convoArray objectAtIndex:(indexPath.row-1)] objectForKey:@"title"] beaconName:self.title beaconID:[self.sendingBeaconID integerValue]];
            
            [self.navigationController pushViewController:threadController animated:YES];
        }
    }
}

- (void) postThreadViewDidCompleteRequest:(PostThreadView *)postThreadView {
    //    [postThreadView removeFromSuperview];
    //    [[self.view.subviews lastObject] removeFromSuperview];
    //    [[self.view.subviews lastObject] removeFromSuperview];
    //    [[self.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
    
    [self dismissPostView];
    [self dismissLoadingOverlay];
    [self populateConvoTable];
}

- (void)populateConvoTable
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacon", nil] apiMethod:@"conversation"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        if(error) return;
        
        convoArray = [response mutableCopy];
        [convoTable reloadData];
        [self.view removeGestureRecognizer:tapToEndTextViewEditingGestureRecognizer];
        [chatterTextView endEditing:YES];
    }];
}

- (void)populateLocationInfo
{
    
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys: sendingBeaconID, @"beacons", nil] apiMethod:@"beacon_info"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        
        if(error) return;
        
        NSString *userIDString1 = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
        NSString *userIDString2 = [NSString stringWithFormat:@"%@", [[response objectForKey:[NSString stringWithFormat:@"%@",sendingBeaconID]] objectForKey:@"creator"]];
        
        NSLog(@"%@", userIDString1);
        
        NSLog(@"%@", userIDString2);
        
        if ([userIDString1 isEqualToString:userIDString2]) {
        
            currentUserIsBeaconCreator = YES;
            [self setupBeaconSettingsButtonWithCurrentUserBoolean:currentUserIsBeaconCreator];
            
        }else {
            
            currentUserIsBeaconCreator = NO;
            [self setupBeaconSettingsButtonWithCurrentUserBoolean:currentUserIsBeaconCreator];
            
        }
        
        NSString *descriptionString = [[response objectForKey:[NSString stringWithFormat:@"%@",sendingBeaconID]] objectForKey:@"description"];
        if ([descriptionString length] > 0)
        {
            [locationInfoScrollView setText:descriptionString];
            locationInfoScrollView.backgroundColor = [UIColor clearColor];
            
            
        }
        else
        {
            [locationInfoScrollView setText:@"No description yet. Click here to add one!"];
            locationInfoScrollView.editable = YES;
            locationInfoScrollView.delegate = self;
            locationInfoScrollView.returnKeyType = UIReturnKeyDone;
            locationInfoScrollView.backgroundColor = [UIColor clearColor];
        }
    }];
}

- (void)setupLocationInfoAppearance
{
    [locationInfoScrollView setFont:[UIFont fontWithName:@"Quicksand" size:locationInfoScrollView.font.pointSize]];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if (textView == chatterTextView) {
        
        tapToEndTextViewEditingGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapForTextView:)];
        tapToEndTextViewEditingGestureRecognizer.cancelsTouchesInView = YES;
        [self.view addGestureRecognizer:tapToEndTextViewEditingGestureRecognizer];
        
        if ([textView.text isEqualToString:REPLY_PLACEHOLDER]) {
            [textView setText:@""];
            textView.textColor = [UIColor blackColor];
        }
        
        CGRect textFieldRect =
        [self.view.window convertRect:textView.bounds fromView:textView];
        CGRect viewRect =
        [self.view.window convertRect:self.view.bounds fromView:self.view];
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator =
        midline - viewRect.origin.y
        - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator =
        (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
        * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        }
        else
        {
            animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        }
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
        
        NSLog(@"self editing");
        
    }
    

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView == chatterTextView) {
        
        if ([textView.text isEqualToString:@""]) {
            [textView setText:REPLY_PLACEHOLDER];
            textView.textColor = [UIColor grayColor];
        }
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
        
    }
    

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if (textView == chatterTextView) {
        
        
        if ([text isEqualToString:@"\n"]) {
            
            if (!alreadyPostingChatter) {
                
                if (textView.text.length != 0) {
                    
                    NSLog(@"%@", textView.text);
                    NSLog(@"%@", sendingBeaconID);
                    
                    RadiusRequest *r;
                    
                    if (sendingBeaconID)
                    {
                        r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacon",textView.text, @"text", @"", @"title", nil] apiMethod:@"/conversation/thread" httpMethod:@"POST"];
                    }
                    alreadyPostingChatter = YES;
                    [r startWithCompletionHandler:^(id response, RadiusError *error) {
                        
                        if (response) {
                            NSLog(@"working on creating thread, response is: %@", response);
                            [textView endEditing:YES];
                            [self populateConvoTable];
                            alreadyPostingChatter = NO;
                            
                        }
                        
                        
                        if (error) {
                            
                            [textView endEditing:YES];
                            alreadyPostingChatter = NO;
                            
                        }
                        
                        
                        
                        
                    }];
                
                }
  
            }
            // Return FALSE so that the final '\n' character doesn't get added
            return NO;
        }
        // For any other character return TRUE so that the text gets added to the view
        return YES;

        
    }
    
    return NO;
}

-(void)handleSingleTapForTextView:(UITapGestureRecognizer *)sender
{
    NSLog(@"Tapped");
    //    [[[[[self.convoTable cellForRowAtIndexPath:0] contentView] subviews] lastObject] endEditing:YES];
    [chatterTextView endEditing:YES];
    [self.view removeGestureRecognizer:tapToEndTextViewEditingGestureRecognizer];
    tapToEndTextViewEditingGestureRecognizer = nil;
}

-(void) handleTapBehindAgain:(UITapGestureRecognizer *)sender {
    NSLog(@"tapped again");
    
    
}

- (void)dismissPostView {
    
    [[self.view viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    [[self.view viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    [[self.view viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    [[self.view viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    
    [[self.navigationController.navigationBar viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:BUTTON_DIM_TAG] removeFromSuperview];
    
    [[self.view viewWithTag:DIMVIEW_BLOCKING_TAG] removeFromSuperview];
    [[self.view viewWithTag:DIMVIEW_BLOCKING_TAG] removeFromSuperview];
    [[self.view viewWithTag:DIMVIEW_BLOCKING_TAG] removeFromSuperview];
    
    [[self.navigationController.navigationBar viewWithTag:DIMVIEW_BLOCKING_TAG] removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:DIMVIEW_BLOCKING_TAG] removeFromSuperview];
    
    [[self.view viewWithTag:POST_THREAD_TAG] removeFromSuperview];
    [[self.view viewWithTag:ADD_CONTENT_TAG] removeFromSuperview];
    [[self.view viewWithTag:CONGRATS_BEACON_TAG] removeFromSuperview];
    
}

- (void)catchTapForView:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    button.tag = BUTTON_DIM_TAG;
    [button addTarget:self action:@selector(dismissPostView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)catchTapForNavBar:(UIView *)view {
    [self resignFirstResponder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = view.bounds;
    button.tag = BUTTON_DIM_TAG;
    [button addTarget:self action:@selector(dismissPostView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (IBAction)noContentMessagePressed:(id)sender {
    [self newestPostContentMethod];
}


- (void) newestPostContentMethod {
    
    if ([self.view viewWithTag:ADD_CONTENT_TAG] == nil){
        
        AddNewContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"AddNewContentView" owner:self options:nil]objectAtIndex:0];
        customView.beaconContentViewController = self;
        
        customView.frame= CGRectMake(myGridView.frame.origin.x, myGridView.frame.origin.y, customView.frame.size.width, customView.frame.size.height);
        customView.mediaLibraryButtonOutlet.frame = CGRectMake(customView.mediaLibraryButtonOutlet.frame.origin.x, customView.mediaLibraryButtonOutlet.frame.origin.y, 70, 70);
        customView.takeAPhotoButtonOutlet.frame = CGRectMake(customView.takeAPhotoButtonOutlet.frame.origin.x, customView.takeAPhotoButtonOutlet.frame.origin.y, 70, 70);
        customView.backgroundColor = [UIColor clearColor];
        customView.tag = ADD_CONTENT_TAG;
        
        UITapGestureRecognizer *recognizerForSubView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehindAgain:)];
        [recognizerForSubView setNumberOfTapsRequired:1];
        recognizerForSubView.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
        [customView addGestureRecognizer:recognizerForSubView];
        customView.layer.cornerRadius = 15;
        UIView *dimView = [[UIView alloc] init];
        dimView.frame= CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
        dimView.backgroundColor = [UIColor blackColor];
        dimView.alpha = 0.6;
        dimView.tag = DIMVIEW_BLOCKING_TAG;
        [self.view addSubview:dimView];
        
        UIView *dimViewForNavBar = [[UIView alloc] init];
        dimViewForNavBar.frame= CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        dimViewForNavBar.backgroundColor = [UIColor blackColor];
        dimViewForNavBar.alpha = 0.6;
        dimViewForNavBar.tag = DIMVIEW_BLOCKING_TAG;
        
        UIPanGestureRecognizer *recognizerToBlock = [[UIPanGestureRecognizer alloc]initWithTarget:self action:nil];
        [dimViewForNavBar addGestureRecognizer:recognizerToBlock];
        [self.navigationController.navigationBar addSubview:dimViewForNavBar];
        
        [self catchTapForNavBar:dimViewForNavBar];
        [self catchTapForView:self.view];
        
        
        
        NSLog(@"yourview : %@",customView);
        
        
        NSLog(@"yourview : %@",customView);
        [self.view addSubview:customView];
        NSLog(@"yourview : %@",customView);
        
        
        //    [customView setFrame:CGRectMake( 0.0f, 480.0f, customView.frame.size.width, customView.frame.size.height)];
        
        if([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
            // Don't animate this
            customView.frame = CGRectMake(myGridView.frame.origin.x + 5, myGridView.frame.origin.y + myGridView.contentInset.top + 5, 310, 150);
        } else {
            customView.frame= CGRectMake(-100, self.navigationController.view.frame.size.height, 0, 150);
            [customView setAutoresizesSubviews:YES];
            customView.transform = CGAffineTransformMakeScale(0,0);
            [UIView animateWithDuration:0.4
                                  delay:0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^ {
                                 customView.transform = CGAffineTransformIdentity;
                                 
                                 customView.frame = CGRectMake(5, myScrollViewOutlet.frame.origin.y + myScrollViewOutlet.contentInset.top + 80, 310, 150);
                                 
                             }completion:^(BOOL finished) {
                                 
                             }];
        }
        
        

        
        //    [UIView beginAnimations:@"animateAddContentView" context:nil];
        //    [UIView setAnimationDuration:0.4];
        //
        //
        //    customView.frame= CGRectMake(myGridView.frame.origin.x +5, myGridView.frame.origin.y +5, 310, 150);
        //    [UIView commitAnimations];
        
    }

    
}

- (void) setupBeaconCongratsView {
    
    if (beaconJustCreated) {
        NSLog(@"beacon was just created, showing congrats view");
        
//        UIImageView *beaconCongratsView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 225)];
        UIImageView *beaconCongratsView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pnl_cbp_congratswdoit.png"]];
        beaconCongratsView.image = [UIImage imageNamed:@"pnl_cbp_congratswdoit.png"];
        beaconCongratsView.tag = CONGRATS_BEACON_TAG;
        
//        UIButton *newButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, beaconCongratsView.frame.size.width, beaconCongratsView.frame.size.height)];
//        [newButton addTarget:self action:@selector(slideOutMFSlidingView:) forControlEvents:UIControlEventTouchUpInside];
//        [beaconCongratsView addSubview:newButton];
        
        UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideOutMFSlidingView:)];
        [newTap setNumberOfTapsRequired:1];
        newTap.cancelsTouchesInView = NO;
        [beaconCongratsView addGestureRecognizer:newTap];
        [self.navigationController.view addGestureRecognizer:newTap];

//        UIView *dimView = [[UIView alloc] init];
//        dimView.frame= CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
//        dimView.backgroundColor = [UIColor blackColor];
//        dimView.alpha = 0.6;
//        dimView.tag = DIMVIEW_BLOCKING_TAG;
        
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
            [self newestPostContentMethod];
            [self.navigationController.view removeGestureRecognizer:newTap];
            self.beaconJustCreated = NO;
        };
        
        [MFSlidingView slideView:beaconCongratsView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
//        [self.view addSubview:dimView];
//        
//        [self catchTapForView:dimView];
//        
//        beaconCongratsView.transform = CGAffineTransformMakeScale(0,0);
//        
//        [self.view addSubview:beaconCongratsView];
//        
//            
//        
//        [UIView animateWithDuration:0.4
//                              delay:0
//                            options:UIViewAnimationCurveEaseInOut
//                         animations:^ {
//                             beaconCongratsView.transform = CGAffineTransformIdentity;
//                             beaconCongratsView.frame= CGRectMake(10, 100, 300, 225);
//                             
//                         }completion:^(BOOL finished) {
//                             
//                         }];
        
        
        
        
        
    }
}

-(void) setupActivityIndicatorAndDimView {
    
    UIView *dimViewForSearchBar = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
    dimViewForSearchBar.tag = ACTIVITY_INDICATOR_TAG;
    dimViewForSearchBar.backgroundColor = [UIColor blackColor];
    dimViewForSearchBar.alpha = 0.5;
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    myIndicator.frame = CGRectMake(self.navigationController.view.center.x - (myIndicator.frame.size.width / 2), self.navigationController.view.center.y + 20, myIndicator.frame.size.width, myIndicator.frame.size.height);
    [dimViewForSearchBar addSubview:myIndicator];
    [dimViewForSearchBar bringSubviewToFront:myIndicator];
    [myIndicator startAnimating];
    [self.navigationController.view addSubview:dimViewForSearchBar];
    
}

-(void) setupCreatorPanel
{
        [creatorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pnl_bvp_creator.png"]]];
}

-(void) setupNumberFollowersButton:(int)numFollowers {
//    [numberFollowingButton setTitle:[NSString stringWithFormat:@"%d follower%@",numFollowers,numFollowers==1?@"":@"s"] forState:UIControlStateNormal];
    
    [numberFollowingButton setTitle:[NSString stringWithFormat:@"%d",numFollowers] forState:UIControlStateNormal];

}

-(void) setupBeaconSettingsButtonWithCurrentUserBoolean: (BOOL) currentUserIsCreator {
    
    if (currentUserIsCreator) {
        
        [beaconCreatorSettingsButtonOutlet setHidden:NO];
    
    }else if (!currentUserIsCreator){
        
        [beaconCreatorSettingsButtonOutlet setHidden:NO];
    }
    
    
}

- (IBAction)beaconCreatorSettingsButtonPressed:(id)sender {
    
#ifdef CONFIGURATION_TestFlight
    [TestFlight passCheckpoint:@"Opened Beacon Creator Settings"];
#endif
    NSDictionary *eventParameters = [NSDictionary dictionaryWithObject:self.sendingBeaconID forKey:@"beacon"];
    [Flurry logEvent:@"Beacon_Settings_Opened" withParameters:eventParameters];
    
    if (currentUserIsBeaconCreator) {
        
    
    
        BeaconCreatorSettingsView *customBeaconCreatorSettingsViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"BeaconCreatorSettingsView" owner:self options:nil]objectAtIndex:0];

        [customBeaconCreatorSettingsViewInstance setBeaconID:sendingBeaconID];
        [customBeaconCreatorSettingsViewInstance setUserTokenString:userTokenString];
        [customBeaconCreatorSettingsViewInstance setBeaconIsPrivate:self.beaconIsPrivate];
        [customBeaconCreatorSettingsViewInstance setBeaconName:beaconNameString];
        [customBeaconCreatorSettingsViewInstance setupBeaconCreatorSettingsView];
        [customBeaconCreatorSettingsViewInstance setBeaconCreatorSettingsDelegate:self];

        
        if (_beaconDictionary) {
            [customBeaconCreatorSettingsViewInstance setBeaconDictionary:_beaconDictionary];
        }
        
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        [MFSlidingView slideView:customBeaconCreatorSettingsViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:LeftOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
    }else if (!currentUserIsBeaconCreator){
        
        InviteFriendsView *customBeaconCreatorSettingsViewInstance = [[[NSBundle mainBundle]loadNibNamed:@"InviteFriendsView" owner:self options:nil]objectAtIndex:0];
        
        [customBeaconCreatorSettingsViewInstance setBeaconID:sendingBeaconID];
        if (beaconNameString) {
            [customBeaconCreatorSettingsViewInstance setBeaconName:beaconNameString];
        }

        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        
        [MFSlidingView slideView:customBeaconCreatorSettingsViewInstance intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:LeftOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
    }
    
}

-(void) setupDiscoverBeaconButton {
    
    UIButton *discoverBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 20, 60, 60)];
    [discoverBeaconButton addTarget:self action:@selector(discoverBeacon:) forControlEvents:UIControlEventTouchUpInside];
    [contentMapView addSubview:discoverBeaconButton];
    
    
}

-(void) discoverBeacon: (id) sender {
    
    NSDictionary *currentFollowedBeaconInQuestion = _beaconDictionary;
    CLLocationDegrees nextFollowedBeaconLatitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:0]floatValue];;
    CLLocationDegrees nextFollowedBeaconLongitude = [[[currentFollowedBeaconInQuestion objectForKey:@"center"]objectAtIndex:1]floatValue];;
    CLLocation *nextFollowedBeaconLocation = [[CLLocation alloc] initWithLatitude:nextFollowedBeaconLatitude longitude:nextFollowedBeaconLongitude];
    
    MapViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"mapViewID"];
    
    [newViewController setDiscoverFollowedBeaconLocation:nextFollowedBeaconLocation];
    [newViewController setInitialLocationSet:YES];
    newViewController.beaconToSelect = [_beaconDictionary objectForKey:@"id"];
    
    NSArray *controllers = [NSArray arrayWithObject:newViewController];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    
//    [[MFSideMenuManager sharedManager].navigationController pushViewController:newViewController animated:YES];
    
}

-(void) slideOutMFSlidingView: (UITapGestureRecognizer *) sender{
    if (beaconJustCreated) {
        [MFSlidingView slideOut];

    }

}

-(void) setupBeaconPrivacyWithArgument: (NSString *)privacyArgument {
    
    if ([privacyArgument isEqualToString:@"public"]) {
//        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//        void (^cancelOrDoneBlock)() = ^{
//            // we must manually slide out the view out if we specify this block
//            [MFSlidingView slideOut];
//            [self.navigationController popViewControllerAnimated:YES];
//        };
//        
//        PrivacyView *privateView = [[[NSBundle mainBundle]loadNibNamed:@"PrivacyView" owner:self options:nil]objectAtIndex:0];
//        privateView.frame = CGRectMake(0, 0, 300, 200);
//        [privateView initializePrivacyView];
//        [privateView setupPrivacyViewWithArgument:privacyArgument];
//        [privateView setCurrentPrivacySetting:privacyArgument];
//        if (sendingBeaconID != nil) {
//            [privateView setBeaconID:sendingBeaconID];
//            
//        }
//        
//        [MFSlidingView slideView:privateView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        return;
    }else if ([privacyArgument isEqualToString:@"owner"]){
//        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//        void (^cancelOrDoneBlock)() = ^{
//            // we must manually slide out the view out if we specify this block
//            [MFSlidingView slideOut];
//            [self.navigationController popViewControllerAnimated:YES];
//        };
//        
//        PrivacyView *privateView = [[[NSBundle mainBundle]loadNibNamed:@"PrivacyView" owner:self options:nil]objectAtIndex:0];
//        privateView.frame = CGRectMake(0, 0, 300, 200);
//        [privateView initializePrivacyView];
//        [privateView setupPrivacyViewWithArgument:privacyArgument];
//        [privateView setCurrentPrivacySetting:privacyArgument];
//        if (sendingBeaconID != nil) {
//            [privateView setBeaconID:sendingBeaconID];
//
//        }
//
//        [MFSlidingView slideView:privateView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        return;
    }else if ([privacyArgument isEqualToString:@"restricted"]){
        
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        PrivacyView *privateView = [[[NSBundle mainBundle]loadNibNamed:@"PrivacyView" owner:self options:nil]objectAtIndex:0];
        privateView.frame = CGRectMake(0, 0, 300, 200);
        [privateView initializePrivacyView];
        [privateView setupPrivacyViewWithArgument:privacyArgument];
        [privateView setCurrentPrivacySetting:privacyArgument];
        
        if (sendingBeaconID != nil) {
            [privateView setBeaconID:sendingBeaconID];
            
        }

        [MFSlidingView slideView:privateView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        
        return;
    }else if ([privacyArgument isEqualToString:@"requested"]){
        
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        PrivacyView *privateView = [[[NSBundle mainBundle]loadNibNamed:@"PrivacyView" owner:self options:nil]objectAtIndex:0];
        privateView.frame = CGRectMake(0, 0, 300, 200);
        [privateView initializePrivacyView];
        [privateView setupPrivacyViewWithArgument:privacyArgument];
        [privateView setCurrentPrivacySetting:privacyArgument];
        
        if (sendingBeaconID != nil) {
            [privateView setBeaconID:sendingBeaconID];
            
        }
        
        [MFSlidingView slideView:privateView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        return;
    }else if ([privacyArgument isEqualToString:@"allowed"]){
        return;
    }else if ([privacyArgument isEqualToString:@"banned"]){
        
        SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        PrivacyView *privateView = [[[NSBundle mainBundle]loadNibNamed:@"PrivacyView" owner:self options:nil]objectAtIndex:0];
        privateView.frame = CGRectMake(0, 0, 300, 200);
        [privateView initializePrivacyView];
        [privateView setupPrivacyViewWithArgument:privacyArgument];
        [privateView setCurrentPrivacySetting:privacyArgument];
        
        if (sendingBeaconID != nil) {
            [privateView setBeaconID:sendingBeaconID];
            
        }
        
        [MFSlidingView slideView:privateView intoView:self.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
        return;
    }
    
    
}

-(void) updateBeaconPrivacy {
    
    if (beaconIsPrivate == YES) {
        beaconIsPrivate = NO;
    }else if (beaconIsPrivate == NO){
        beaconIsPrivate = YES;
    }
    
}

#pragma mark New Design Stuff

-(void) setupHappeningNowView {
    
//    self.happeningNowViewOutlet.layer.cornerRadius = 5;
//    
//    UILabel *happeningNowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, -(15 - self.happeningNowViewOutlet.frame.size.height), self.happeningNowViewOutlet.frame.size.width-10, 15)];
//    [self.happeningNowViewOutlet addSubview:happeningNowLabel];
//    happeningNowLabel.text = @"Happening now!";
//    happeningNowLabel.font = [UIFont fontWithName:@"Quicksand" size:14.0];
//    happeningNowLabel.textColor = [UIColor whiteColor];
//    happeningNowLabel.backgroundColor = [UIColor blackColor];
//    happeningNowLabel.textAlignment = UITextAlignmentCenter;
//    happeningNowLabel.layer.cornerRadius = 4;
    
    happeningNowImageView = [[AsyncImageView alloc]initWithFrame:CGRectMake(10, 6, self.happeningNowViewOutlet.frame.size.width-20, self.happeningNowViewOutlet.frame.size.height-12)];
    happeningNowImageView.layer.cornerRadius = 5;
    
    
    [self.happeningNowViewOutlet addSubview:happeningNowImageView];
    [self.happeningNowViewOutlet sendSubviewToBack:happeningNowImageView];
    
    [self setupHappeningNowButton];


    
    
}

-(void) loadHappeningNowImage{
    
    if ([jsonArray count] > 0) {
        NSDictionary *firstDictionary = [self.jsonArray objectAtIndex:0];
        NSString *contentImageHeight = [NSString stringWithFormat: @"%@", [[firstDictionary objectForKey:@"content"]objectForKey:@"height"]];
        NSString *contentImageWidth = [NSString stringWithFormat: @"%@", [[firstDictionary objectForKey:@"content"]objectForKey:@"width"]];
        NSString *imageURLString = [NSString stringWithFormat:@"%@", [[firstDictionary objectForKey:@"content"]objectForKey:@"url"]];
        NSURL *imageURL = [[NSURL alloc]initWithString:imageURLString];
        
        [[happeningNowViewOutlet viewWithTag:UPLOAD_SOMETHING_TAG]removeFromSuperview];
        [happeningNowImageView setImageCache:nil];
        [happeningNowImageView setImageURL:imageURL];
        [happeningNowImageView loadImage];
        

        
//        AsyncImageView *aiv = [[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, self.happeningNowViewOutlet.frame.size.width, self.happeningNowViewOutlet.frame.size.height) imageURL:imageURL cache:nil loadImmediately:YES];
//        
//        
//        
//        [self.happeningNowViewOutlet addSubview:aiv];
//        [self.happeningNowViewOutlet sendSubviewToBack:aiv];
        
        
        self.happeningNowViewOutlet.hidden = NO;
        self.noContentMessageOutlet.hidden = YES;

    }else{
        
//        UIImage *uploadSomething = [UIImage imageNamed:@"bkgd_generic.png"];
//        UIImageView *uploadSomethingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.happeningNowViewOutlet.frame.size.width, self.happeningNowViewOutlet.frame.size.height)];
//        [uploadSomethingImageView setImage:uploadSomething];
//        [self.happeningNowViewOutlet addSubview:uploadSomethingImageView];
//        [self.happeningNowViewOutlet sendSubviewToBack:uploadSomethingImageView];
        
//        [happeningNowImageView setImageCache:nil];
//        [happeningNowImageView setImageURL:nil];
//        [happeningNowImageView loadImage];
        
//        UILabel *uploadSomething = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.happeningNowViewOutlet.frame.size.width - 10, self.happeningNowViewOutlet.frame.size.height)];
//        uploadSomething.tag = UPLOAD_SOMETHING_TAG;
//        uploadSomething.textColor = [UIColor blackColor];
//        uploadSomething.text = [NSString stringWithFormat:@"Be the first to post to this beacon! What's happening here?"];
//        uploadSomething.textAlignment = UITextAlignmentCenter;
//        uploadSomething.font = [UIFont fontWithName:@"Quicksand" size:16.0];
//        uploadSomething.backgroundColor = [UIColor whiteColor];
//        uploadSomething.numberOfLines = 5;
//        [myScrollViewOutlet addSubview:uploadSomething];
//        [myScrollViewOutlet bringSubviewToFront:uploadSomething];
        
        self.happeningNowViewOutlet.hidden = YES;
        self.noContentMessageOutlet.hidden = NO;
        
    }
    
    
    
}

-(void) setupHappeningNowButton {
    
    UIButton *happeningNowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.happeningNowViewOutlet.frame.size.width, self.happeningNowViewOutlet.frame.size.height)];
    [self.happeningNowViewOutlet addSubview:happeningNowButton];
    [happeningNowButton addTarget:self action:@selector(discoverHappeningNowContent) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void) discoverHappeningNowContent {
    if ([jsonArray count] > 0) {
        
        
        NSDictionary *firstDictionary = [self.jsonArray objectAtIndex:0];
        if (firstDictionary) {
            BeaconDetailContentImageViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailImageContentID"];
            [newViewControllerInstance setTitle:beaconNameOutlet.text];
            [newViewControllerInstance setImageArray:jsonArray];
            [newViewControllerInstance setBeaconIDString:sendingBeaconID];
            [newViewControllerInstance setBeaconNameString:[self.beaconDictionary objectForKey:@"name"]];
            [newViewControllerInstance setContentType:@"image"];
            [newViewControllerInstance setBeaconContentDictionary:firstDictionary];
            [newViewControllerInstance initializeBeaconContentImage];
            
            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
        }
        
        
    }

}

-(void) setupNewAddContentButton {
    
    UIButton *addContentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 90 - 44, 90, 90)];
    [self.view addSubview:addContentButton];
    [self.view bringSubviewToFront:addContentButton];
    [addContentButton setImage:[UIImage imageNamed:@"btn_bvp_premiumcontent"] forState:UIControlStateNormal];
    [addContentButton addTarget:self action:@selector(newestPostContentMethod) forControlEvents:UIControlEventTouchUpInside];
    addContentButton.layer.cornerRadius = 5;
    [addContentButton setTag:ADD_NEW_CONTENT_BUTTON_TAG];
}

-(void) setupScrollViewForHappeningNowAndGridWithRowCount: (int)rowCount {
    
    myGridView.frame = CGRectMake(myGridView.frame.origin.x, myGridView.frame.origin.y, myGridView.frame.size.width, rowCount*106+40);
    myGridView.scrollEnabled = NO;

    CGFloat contentHeight = MAX(self.happeningNowViewOutlet.frame.size.height + self.myGridView.frame.size.height,self.myScrollViewOutlet.frame.size.height+1);
    [self.myScrollViewOutlet setContentSize:CGSizeMake(self.view.frame.size.width, contentHeight)];
    
    if(!contentRefreshView) {
        // Create refresh view
        
        contentRefreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -40, myScrollViewOutlet.frame.size.width, 40)];
        
        UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, contentRefreshView.bounds.size.width, 15)];
        refreshLabel.textAlignment = UITextAlignmentCenter;
        refreshLabel.text = @"Pull to Refresh";
        refreshLabel.backgroundColor = [UIColor clearColor];
        refreshLabel.tag = CONTENT_REFRESH_LABEL_TAG;
        refreshLabel.font = [UIFont fontWithName:@"Quicksand" size:14];
        [contentRefreshView addSubview:refreshLabel];
        
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiv.frame = contentRefreshView.bounds;
        aiv.tag = CONTENT_REFRESH_AIV_TAG;
        [contentRefreshView addSubview:aiv];
        
        [self.myScrollViewOutlet addSubview:contentRefreshView];
        
        // Add tap gesture recognizer to decide whether to refresh/load more
        
        contentPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPanned:)];
        [self.myScrollViewOutlet addGestureRecognizer:contentPanRecognizer];
        contentPanRecognizer.cancelsTouchesInView = NO;
        contentPanRecognizer.delegate = self;
    }

}

-(void) scrollViewPanned:(UIPanGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer==contentPanRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if(self.myScrollViewOutlet.contentOffset.y < -50) {
                [self refreshContent];
            } else if(self.myScrollViewOutlet.frame.size.height + self.myScrollViewOutlet.contentOffset.y > self.myScrollViewOutlet.contentSize.height + 10) {
                [self loadMoreContent];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            UILabel *refreshLabel = (UILabel *)[contentRefreshView viewWithTag:CONTENT_REFRESH_LABEL_TAG];
            if(self.myScrollViewOutlet.contentOffset.y < -50) {
                refreshLabel.text = @"Release to Refresh";
            } else {
                refreshLabel.text = @"Pull to Refresh";
            }
        }
    } else if(gestureRecognizer == convoPanRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if(self.convoTable.contentOffset.y < -50) {
                [self refreshConversation];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            UILabel *refreshLabel = (UILabel *)[convoRefreshView viewWithTag:CONVO_REFRESH_LABEL_TAG];
            NSLog(@"%f",self.convoTable.contentOffset.y);
            if(self.convoTable.contentOffset.y < -50) {
                refreshLabel.text = @"Release to Refresh";
            } else {
                refreshLabel.text = @"Pull to Refresh";
            }
        }
    }
}

-(void) refreshContent {
    [[contentRefreshView viewWithTag:CONTENT_REFRESH_LABEL_TAG] setHidden:YES];
    [(UIActivityIndicatorView *)[contentRefreshView viewWithTag:CONTENT_REFRESH_AIV_TAG] startAnimating];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        myScrollViewOutlet.contentInset = UIEdgeInsetsMake(50, 0, myScrollViewOutlet.contentInset.bottom, 0);
    }];
    
    NSString *since;
    if(jsonArray.count > 0) {
        since = [[jsonArray objectAtIndex:0] objectForKey:@"id"];
    } else {
        since = @"0";
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:since,@"since",sendingBeaconID,@"beacon", nil];
    RadiusRequest *refreshRequest = [RadiusRequest requestWithParameters:params apiMethod:@"beacon_content"];
    [refreshRequest startWithCompletionHandler:^(id result, RadiusError *error) {
        [[contentRefreshView viewWithTag:CONTENT_REFRESH_LABEL_TAG] setHidden:NO];
        [(UIActivityIndicatorView *)[contentRefreshView viewWithTag:CONTENT_REFRESH_AIV_TAG] stopAnimating];
        
        [UIView animateWithDuration:0.5 animations:^{
            myScrollViewOutlet.contentInset = UIEdgeInsetsMake(0, 0, myScrollViewOutlet.contentInset.bottom, 0);
        }];
        
        if(!error) {
            NSMutableArray *newContentArray = [(NSArray*)result mutableCopy];
            if(newContentArray.count > 0) {
                [newContentArray addObjectsFromArray:jsonArray];
                jsonArray = newContentArray;
                [self renderBeaconContent];
            }
        }
    }];
}



-(void) loadMoreContent {
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.frame = CGRectMake(0, myScrollViewOutlet.contentSize.height-15, myScrollViewOutlet.frame.size.width,30);
    
    [loadingIndicator startAnimating];
    [myScrollViewOutlet addSubview:loadingIndicator];
    
    [UIView animateWithDuration:0.5 animations:^{
        myScrollViewOutlet.contentInset = UIEdgeInsetsMake(myScrollViewOutlet.contentInset.top, 0, 50, 0);
    }];
    
    CGFloat originalContentHeight = myScrollViewOutlet.contentSize.height;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",contentOffset],@"offset",@"9",@"limit",sendingBeaconID,@"beacon", nil];
    RadiusRequest *refreshRequest = [RadiusRequest requestWithParameters:params apiMethod:@"beacon_content"];
    [refreshRequest startWithCompletionHandler:^(id result, RadiusError *error) {
        [loadingIndicator stopAnimating];
        [loadingIndicator removeFromSuperview];
        
        if(!error) {
            NSArray *additionalContent = (NSArray*)result;
            contentOffset += additionalContent.count;
            if(additionalContent.count > 0) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    myScrollViewOutlet.contentInset = UIEdgeInsetsMake(myScrollViewOutlet.contentInset.top, 0, 0, 0);
                    myScrollViewOutlet.contentOffset = CGPointMake(0, originalContentHeight-myScrollViewOutlet.frame.size.height+80);
                }];
                
                [jsonArray addObjectsFromArray:additionalContent];
                [self renderBeaconContent];
            } else {
                [UIView animateWithDuration:0.5 animations:^{
                    myScrollViewOutlet.contentInset = UIEdgeInsetsMake(myScrollViewOutlet.contentInset.top, 0, 0, 0);
                }];
            }
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                myScrollViewOutlet.contentInset = UIEdgeInsetsMake(myScrollViewOutlet.contentInset.top, 0, 0, 0);
            }];
        }
    }];

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



// Copied/pasted from above for time constraints.  This should be made generic.
-(void) refreshConversation {
    [[convoRefreshView viewWithTag:CONVO_REFRESH_LABEL_TAG] setHidden:YES];
    [(UIActivityIndicatorView *)[convoRefreshView viewWithTag:CONVO_REFRESH_AIV_TAG] startAnimating];
    
    [UIView animateWithDuration:0.5 animations:^{
        convoTable.contentInset = UIEdgeInsetsMake(40, 0, convoTable.contentInset.bottom, 0);
    }];
    
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.sendingBeaconID, @"beacon", nil] apiMethod:@"conversation"];
    [radRequest startWithCompletionHandler:^(id response, RadiusError *error) {
        [[convoRefreshView viewWithTag:CONVO_REFRESH_LABEL_TAG] setHidden:NO];
        [(UIActivityIndicatorView *)[convoRefreshView viewWithTag:CONVO_REFRESH_AIV_TAG] stopAnimating];
        
        [UIView animateWithDuration:0.5 animations:^{
            convoTable.contentInset = UIEdgeInsetsMake(0, 0, convoTable.contentInset.bottom, 0);
        }];
        
        if(error) return;        
        convoArray = response;
        [convoTable reloadData];
    }];
}

-(void) setupConvoTable {
    convoRefreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -40, convoTable.frame.size.width, 40)];
    
    UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, convoRefreshView.bounds.size.width, 15)];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    refreshLabel.text = @"Pull to Refresh";
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.tag = CONVO_REFRESH_LABEL_TAG;
    refreshLabel.font = [UIFont fontWithName:@"Quicksand" size:14];
    [convoRefreshView addSubview:refreshLabel];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.frame = convoRefreshView.bounds;
    aiv.tag = CONVO_REFRESH_AIV_TAG;
    [convoRefreshView addSubview:aiv];
    
    [self.convoTable addSubview:convoRefreshView];
    
    // Add tap gesture recognizer to decide whether to refresh/load more
    
    convoPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPanned:)];
    [convoTable addGestureRecognizer:convoPanRecognizer];
    convoPanRecognizer.cancelsTouchesInView = NO;
    convoPanRecognizer.delegate = self;
}

-(void) setupTransparencyView {
    
    UIImage *transparencyImage = [UIImage imageNamed:@"pnl_bottomtransparency"];
    transparencyImageView = [[UIImageView alloc] initWithImage:transparencyImage];
    transparencyImageView.frame = CGRectMake(0, self.view.frame.size.height - 240, 320, 240);
    [self.view addSubview:transparencyImageView];
}


@end

