//
//  AddNewContentView.m
//  radius
//
//  Created by Hud on 10/2/12.
//
//

#import "AddNewContentView.h"
#import "UIImage+Scale.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation AddNewContentView

@synthesize addNewContentViewBeaconID;
@synthesize test;

RadiusProgressView *uploadProgressView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}




//- (IBAction)postLinkButtonPressed:(id)sender {
//    
//    UIViewController * myController = [self firstAvailableUIViewController];
//
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
//    
//    PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
//    customView.postTextContentTextView.text = @"Post Text Here";
//    customView.postSendingBeaconID = addNewContentViewBeaconID;
//    customView.postContentType = @"text";
//    customView.postContentViewDelegate = myController;
//    customView.userTask = @"PostContent";
//    customView.backgroundColor = [UIColor clearColor];
////    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
////    [myController.view addGestureRecognizer:singleTapRecognizer];
////    [customView addGestureRecognizer:singleTapRecognizer];
//    
//    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//    void (^cancelOrDoneBlock)() = ^{
//        // we must manually slide out the view out if we specify this block
//        [MFSlidingView slideOut];
//        [customView.descriptionTextField resignFirstResponder];
//        
//    };
//    
//    [MFSlidingView slideView:customView intoView:myController.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
//}

- (IBAction)uploadPictureButtonPressed:(id)sender {
    UIViewController * myController = [self firstAvailableUIViewController];

    
    NSLog(@"uploading from media");
    [self startMediaBrowserFromViewController: myController
                                usingDelegate: myController];
}

- (IBAction)takePictureButtonPressed:(id)sender {
    UIViewController * myController = [self firstAvailableUIViewController];

    
    NSLog(@"taking a picture now");
    [self startCameraControllerFromViewController:myController usingDelegate:myController];
}

//- (IBAction)postImageLinkButtonPressed:(id)sender {
//    
//    UIViewController * myController = [self firstAvailableUIViewController];
//    
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.view.subviews lastObject] removeFromSuperview];
//    [[myController.navigationController.navigationBar.subviews lastObject] removeFromSuperview];
//    
//    PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
//    customView.postTextContentTextView.text = @"Post Image Link Here";
//    customView.postSendingBeaconID = addNewContentViewBeaconID;
//    customView.postContentType = @"text";
//    customView.postContentViewDelegate = myController;
//    customView.userTask = @"PostContent";
//    customView.backgroundColor = [UIColor clearColor];
////    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
////    [myController.view addGestureRecognizer:singleTapRecognizer];
////    [customView addGestureRecognizer:singleTapRecognizer];
//    
//    SlidingViewOptions options = CancelOnBackgroundPressed|AvoidKeyboard;
//    void (^cancelOrDoneBlock)() = ^{
//        // we must manually slide out the view out if we specify this block
//        [MFSlidingView slideOut];
//        [customView.descriptionTextField resignFirstResponder];
//        
//    };
//    
//    [MFSlidingView slideView:customView intoView:myController.navigationController.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:nil options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
//}

- (IBAction)postVideoLinkButtonPressed:(id)sender {
}

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
    [mediaUI.navigationBar setBackgroundImage:[UIImage imageNamed:@"pnl_navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    NSLog(@"%x",(NSUInteger)controller);
    
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

@end
