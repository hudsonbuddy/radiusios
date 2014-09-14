//
//  BeaconContentViewController.m
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BeaconContentViewController.h"
#import "RadiusProgressView.h"
#import "SlidingTableView.h"
#import "BeaconConversationTable.h"
#import "ConvoThreadViewController.h"


@interface BeaconContentViewController () <CLLocationManagerDelegate, MKMapViewDelegate, FindBeaconContentDelegate, UITableViewDelegate, UITableViewDataSource, PostBeaconContentDelegate, FindBeaconInfoDelegate, PostContentViewDelegate, UIImagePickerControllerDelegate, PostBeaconUploadImageContentDelegate,
NSURLConnectionDataDelegate>



@end

@implementation BeaconContentViewController
@synthesize postContentButton;

@synthesize contentTableView;

@synthesize currentBeacon;
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

RadiusProgressView *uploadProgressView;

#pragma mark Twitter Handle


//-(void) populateTweetTextView {
//    NSLog(@"performing twitter search");
//
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//
//    NSString *whitespaceString = self.title;
//
//    NSString *trimmedString = [whitespaceString
//                               stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"%@",trimmedString);
//
//    NSString *tweetHashString = [NSString stringWithFormat:@"#%@",trimmedString];
//
//    [params setObject:tweetHashString forKey:@"q"];
//    [params setObject:@"1" forKey:@"page"];
//    [params setObject:@"recent" forKey:@"result_type"];
//    [params setObject:@"20" forKey:@"rpp"];
//
//    NSURL *url =
//    [NSURL URLWithString:@"http://search.twitter.com/search.json"];
//
//    TWRequest *request = [[TWRequest alloc] initWithURL:url
//                                             parameters:params
//                                          requestMethod:TWRequestMethodGET];
//    [request performRequestWithHandler:
//     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//
//         if (responseData) {
//             NSError *jsonError;
//             twitterResponse=
//             [NSJSONSerialization JSONObjectWithData:responseData
//                                             options:NSJSONReadingMutableLeaves
//                                               error:&jsonError];
//             //             NSLog(@"%@",twitterResponse);
//
//             if ([[twitterResponse objectForKey:@"results"]count]) {
//
//                 //                 NSMutableArray *addedFinalTweetArray = [[NSMutableArray alloc] initWithObjects:@"this is the last tweet", nil];
//                 //                 NSMutableArray *addedFinalTweetArrayKeys = [[NSMutableArray alloc] initWithObjects:@"text", nil];
//                 //                 NSMutableDictionary *addedFinalTweetDictionary = [[NSMutableDictionary alloc] initWithObjects:addedFinalTweetArray forKeys:addedFinalTweetArrayKeys];
//                 //                 [[twitterResponse objectForKey:@"results"]addObject:addedFinalTweetDictionary];
//
//
//                 currentTweetToDisplay = [[[twitterResponse objectForKey:@"results"]objectAtIndex:swipeCount]objectForKey:@"text"];
//                 NSLog(@"%@", currentTweetToDisplay);
//                 //[self.tweetTextViewContent setText:currentTweetToDisplay];
//
//                 //                 NSLog(@"%X",(unsigned int)self);
//                 //                 NSLog(@"%X",(unsigned int)tweetTextViewContent);
//                 //                 NSLog(@"%X",(unsigned int)currentTweetToDisplay);
//
//
//                 [tweetTextViewContent performSelectorOnMainThread:@selector(setText:) withObject:currentTweetToDisplay waitUntilDone:NO];
//
//             }
//             else {
//                 NSLog(@"%@", jsonError);
//                 currentTweetToDisplay = @"No Tweets to Display";
//                 NSLog(@"%@", currentTweetToDisplay);
//                 [tweetTextViewContent performSelectorOnMainThread:@selector(setText:) withObject:currentTweetToDisplay waitUntilDone:NO];
//             }
//         }
//     }];
//
//}

//- (IBAction)handleGesture {
//
//    NSLog(@"swiped");
//    swipeCount++;
//    if ([[twitterResponse objectForKey:@"results"] count] > swipeCount) {
//
//        currentTweetToDisplay = [[[twitterResponse objectForKey:@"results"]objectAtIndex:swipeCount]objectForKey:@"text"];
//        [tweetTextViewContent setText:currentTweetToDisplay];
//
//    }else if ([[twitterResponse objectForKey:@"results"] count] <= swipeCount) {
//
//        currentTweetToDisplay = @"no more tweets newb";
//        [tweetTextViewContent setText:currentTweetToDisplay];
//    }
//
//}

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
    [followBeaconButtonOutlet setTitle:@"Followed!" forState:UIControlStateNormal];
    [followBeaconButtonOutlet setBackgroundImage:[UIImage imageNamed:@"btn_follow_green.png"] forState:UIControlStateNormal];
}

-(void) setFollowButtonNotFollowed
{
    [followBeaconButtonOutlet setTitle:@"Follow" forState:UIControlStateNormal];
    [followBeaconButtonOutlet setBackgroundImage:[UIImage imageNamed:@"btn_follow_red.png"] forState:UIControlStateNormal];
}

- (IBAction)followBeaconButton:(id)sender {
    
    if (currentBeaconisMeBeacon ==NO) {
        if (currentBeaconisFollowed == NO) {
            if (sendingBeaconID != nil) {
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",sendingBeaconID ,@"beacon",nil] apiMethod:@"follow" httpMethod:@"POST"];
                [r startWithCompletionHandler:^(id response) {
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([[response objectForKey:@"success"]integerValue] == YES) {
                        [self setFollowButtonFollowed];
                        currentBeaconisFollowed = YES;
                    }
                }];
            }else if ([currentBeacon.beaconDictionary objectForKey:@"id"] !=nil) {
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",[currentBeacon.beaconDictionary objectForKey:@"id"] ,@"beacon",nil] apiMethod:@"follow" httpMethod:@"POST"];
                [r startWithCompletionHandler:^(id response) {
                    
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([[response objectForKey:@"success"]integerValue] == YES) {
                        [self setFollowButtonFollowed];
                        currentBeaconisFollowed = YES;
                    }
                }];
            }
        }else if (currentBeaconisFollowed == YES) {
            
            if (sendingBeaconID != nil) {
                
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",sendingBeaconID ,@"beacon",nil] apiMethod:@"unfollow" httpMethod:@"POST"];
                
                [r startWithCompletionHandler:^(id response) {
                    
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([[response objectForKey:@"success"]integerValue] == YES) {
                        
                        [self setFollowButtonNotFollowed];
                        currentBeaconisFollowed = NO;
                    }
                    
                }];
            }else if ([currentBeacon.beaconDictionary objectForKey:@"id"] !=nil) {
                
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",[currentBeacon.beaconDictionary objectForKey:@"id"] ,@"beacon",nil] apiMethod:@"unfollow" httpMethod:@"POST"];
                
                [r startWithCompletionHandler:^(id response) {
                    
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([[response objectForKey:@"success"]integerValue] == YES) {
                        
                        [self setFollowButtonNotFollowed];
                        currentBeaconisFollowed = NO;
                    }
                    
                }];
                
            }
        }
        
        
    }else if (currentBeaconisMeBeacon == YES) {
        
        NSLog(@"sending heartbeat");
        NSLog(@"%f, lat, %f, long", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
        NSString *latString = [NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
        NSString *longString = [NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude];
        RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",latString, @"lat", longString, @"lng", nil] apiMethod:@"heartbeat" httpMethod:@"POST"];
        
        
        [r startWithCompletionHandler:^(id response) {
            
            // deal with response object
            NSLog(@"working %@", response);
            //            if ([response isKindOfClass:[NSArray class]]) {
            //                responseArray = response;
            //            }else if ([response isKindOfClass:[NSDictionary class]]){
            //
            //                responseDictionary = response;
            //            }
        }];
        
    }
    
    
}

-(void) seeBeaconFollowers {
    
    
    
    _customSlidingTableView = [[[NSBundle mainBundle]loadNibNamed:@"SlidingTableView" owner:self options:nil]objectAtIndex:0];
    _customSlidingTableView.slidingTableViewTableView.delegate = self;
    _customSlidingTableView.slidingTableViewTableView.dataSource = _customSlidingTableView;
    
//    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
//    [self.view addGestureRecognizer:singleTapRecognizer];
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID,@"beacon", nil] apiMethod:@"beacon/followers" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response) {
        
        // deal with response object
        NSLog(@"working %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseFollowedArray = response;
            [_customSlidingTableView setResponseArray:response];
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseFollowedDictionary = response;
            [_customSlidingTableView setResponseDictionary:response];
            
        }
        
        SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
        void (^cancelOrDoneBlock)() = ^{
            // we must manually slide out the view out if we specify this block
            [MFSlidingView slideOut];
        };
        
        
        [MFSlidingView slideView:_customSlidingTableView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Beacon Followers" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
        
    }];
    
    
    
    
    
}

#pragma mark Post Content Handle

- (IBAction)whosFollowingPressed
{
    [self seeBeaconFollowers];
}

-(void) newPostContentMethod {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"What Do You Want To Post?" delegate:self
                                  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                  otherButtonTitles:@"Text", @"Image URL",
                                  @"Video URL",
                                  @"Upload From Media Library", @"Take a Picture Now", @"Tweet",
                                  nil];
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sendingBeaconID != nil) {
        
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([buttonTitle isEqualToString:@"Text"]) {
            
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Text Here";
            customView.postSendingBeaconID = sendingBeaconID;
            customView.postContentType = @"text";
            customView.postContentViewDelegate =self;
            customView.userTask = @"PostContent";
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
                [customView.descriptionTextField resignFirstResponder];
                
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Post Text" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        } else if([buttonTitle isEqualToString:@"Image URL"]) {
            
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Image URL Here";
            customView.postSendingBeaconID = sendingBeaconID;
            customView.postContentType = @"image";
            customView.postContentViewDelegate =self;
            customView.userTask = @"PostContent";
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
                [customView.descriptionTextField resignFirstResponder];
                
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:RightOfScreen offScreenPosition:RightOfScreen title:@"Post Image URL" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        } else if([buttonTitle isEqualToString:@"Video URL"]) {
            
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Video from Youtube URL Here";
            customView.postSendingBeaconID = sendingBeaconID;
            customView.postContentType = @"video";
            customView.postContentViewDelegate =self;
            customView.userTask = @"PostContent";
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
                [customView.descriptionTextField resignFirstResponder];
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Post Video URL" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        } else if([buttonTitle isEqualToString:@"Upload From Media Library"]) {
            
            NSLog(@"uploading from media");
            [self startMediaBrowserFromViewController: self
                                        usingDelegate: self];
        }else if([buttonTitle isEqualToString:@"Take a Picture Now"]) {
            
            NSLog(@"taking a picture now");
            [self startCameraControllerFromViewController:self usingDelegate:self];
            
            
        }else if([buttonTitle isEqualToString:@"Post The Old Way"]) {
            
            [self goingToPostContent];
        }else if ([buttonTitle isEqualToString:@"Tweet"]){
            
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc]init];
            NSString *whitespaceString = self.title;
            
            NSString *trimmedString = [whitespaceString
                                       stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"%@",trimmedString);
            
            NSString *tweetHashString = [NSString stringWithFormat:@"#%@",trimmedString];
            [tweetSheet setInitialText:[NSString stringWithFormat:tweetHashString]];
            tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
                [self dismissModalViewControllerAnimated:YES];
            };
            [self presentModalViewController:tweetSheet animated:YES];
            
        }
        
        
    }else if ([currentBeacon.beaconDictionary objectForKey:@"id"] != nil){
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([buttonTitle isEqualToString:@"Text"]) {
            
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Text Here";
            customView.postSendingBeaconID = [currentBeacon.beaconDictionary objectForKey:@"id"];
            customView.postContentType = @"text";
            customView.postContentViewDelegate =self;
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Post Text" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        } else if([buttonTitle isEqualToString:@"Image URL"]) {
            
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Image URL Here";
            customView.postSendingBeaconID = [currentBeacon.beaconDictionary objectForKey:@"id"];
            customView.postContentType = @"image";
            customView.postContentViewDelegate =self;
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:RightOfScreen offScreenPosition:RightOfScreen title:@"Post Image URL" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        } else if([buttonTitle isEqualToString:@"Video URL"]) {
            
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Video from Youtube URL Here";
            customView.postSendingBeaconID = [currentBeacon.beaconDictionary objectForKey:@"id"];
            customView.postContentType = @"video";
            customView.postContentViewDelegate = self;
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Post Video URL" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        } else if([buttonTitle isEqualToString:@"Upload From Media Library"]) {
            
            NSLog(@"uploading from media");
            [self startMediaBrowserFromViewController: self
                                        usingDelegate: self];
            
            
        }else if([buttonTitle isEqualToString:@"Take a Picture Now"]) {
            
            NSLog(@"taking a picture now");
            [self startCameraControllerFromViewController:self usingDelegate:self];
            
        }else if([buttonTitle isEqualToString:@"Post The Old Way"]) {
            
            [self goingToPostContent];
            
        }else if ([buttonTitle isEqualToString:@"Tweet"]){
            
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc]init];
            NSString *whitespaceString = self.title;
            
            NSString *trimmedString = [whitespaceString
                                       stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"%@",trimmedString);
            
            NSString *tweetHashString = [NSString stringWithFormat:@"#%@",trimmedString];
            [tweetSheet setInitialText:[NSString stringWithFormat:tweetHashString]];
            tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
                [self dismissModalViewControllerAnimated:YES];
            };
            [self presentModalViewController:tweetSheet animated:YES];
            
        }
    }
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
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
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


- (void) uploadImage:(UIImage *)imageToUse {
    
    if(self.modalViewController) {
        [self performSelector:@selector(uploadImage:) withObject:imageToUse afterDelay:0.1f];
        return;
    }
    
    uploadProgressView = [[[NSBundle mainBundle]loadNibNamed:@"RadiusProgressView" owner:self options:nil]objectAtIndex:0];
    uploadProgressView.description.text = @"Uploading Image";
    [self.view addSubview:uploadProgressView];
    
    
    if ([currentBeacon.beaconDictionary objectForKey:@"id"] != nil) {
        PostBeaconUploadImageContent *postImage = [[PostBeaconUploadImageContent alloc] initWithDataDelegate:self];
        int beaconIntegerID = [[currentBeacon.beaconDictionary objectForKey:@"id"]integerValue];
        [postImage setPostBeaconUploadImageContentDelegate:self];
        [postImage uploadImage:imageToUse toBeacon:beaconIntegerID];
    }else if (sendingBeaconID != nil) {
        
        PostBeaconUploadImageContent *postImage = [[PostBeaconUploadImageContent alloc] initWithDataDelegate:self];
        int beaconIntegerID = [sendingBeaconID integerValue];
        [postImage setPostBeaconUploadImageContentDelegate:self];
        [postImage uploadImage:imageToUse toBeacon:beaconIntegerID];
    }
    
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
        
        
        //        UIAlertView *picked = [[UIAlertView alloc] initWithTitle:@"Picked" message:@"Susan Coffey is hot" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        //
        //        [picked show];
        
        
        [self uploadImage:imageToUse];
        
        // Do something with imageToUse
    }
    
    // Handle a movie picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        UIAlertView *pickedMovie = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You tried to pick a movie, try picking an image comma newb" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [pickedMovie show];
        
        // Do something with the picked movie available at moviePath
    }
    
    //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setUploadProgress:(NSNumber *)progress {
    float p = [progress floatValue];
    
    if(p >= 1.0f) {
        [uploadProgressView removeFromSuperview];
        
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
        return;
    }
    
    [uploadProgressView.progressView setProgress:p animated:YES];
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
    
    ProfileViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"meProfileViewID"];
    [newViewController setUserNameString:userNameString];
    [newViewController setTitle:[NSString stringWithFormat:@"%@", userNameString]];
    [self.navigationController pushViewController:newViewController animated:YES];
    
}

-(void) reloadBeaconContentDataTable {
    
    [self populateBeaconContent];
    
}


-(void) goingToPostContent{
    
    NSLog(@"trying to go to post content");
    
    if (sendingBeaconID != nil) {
        
        NSLog(@"has sendingbeaconID");
        CreateDetailViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                      instantiateViewControllerWithIdentifier:@"DetailCreate"];
        demoController.title = beaconNameOutlet.text;
        
        //        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        //        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        //        NSNumber * myNumber = [f numberFromString:sendingBeaconID];
        
        NSNumber *myOtherNumber = [NSNumber numberWithDouble:[sendingBeaconID doubleValue]];
        
        Beacon *createdBeaconInstance = [[Beacon alloc] init];
        [createdBeaconInstance setBeaconID:myOtherNumber];
        [createdBeaconInstance setBeaconname:beaconNameOutlet.text];
        [demoController setCurrentBeacon:createdBeaconInstance];
        [self.navigationController pushViewController:demoController animated:YES];
        //        NSArray *controllers = [NSArray arrayWithObject:demoController];
        //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
        //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
        
        
    }else if ([currentBeacon.beaconDictionary objectForKey:@"id"] !=nil ) {
        NSLog(@"has currentbeacondictionary");
        CreateDetailViewController *demoController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]
                                                      instantiateViewControllerWithIdentifier:@"DetailCreate"];
        demoController.title = [NSString stringWithFormat:currentBeacon.beaconname];
        demoController.currentBeacon = currentBeacon;
        
        NSString *sendingBeaconIDString = [NSString stringWithFormat:@"%@", [currentBeacon beaconID]];
        
        demoController.currentBeacon.beaconID = [currentBeacon.beaconDictionary objectForKey:@"id"];
        [self.navigationController pushViewController:demoController animated:YES];
        //        NSArray *controllers = [NSArray arrayWithObject:demoController];
        //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
        //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    }else {
        
        NSLog(@"no beacon ID to go to post to");
    }
    
    
}

-(void) reloadConversationTable
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[currentBeacon.beaconDictionary objectForKey:@"id"], @"beacon", nil] apiMethod:@"conversation"];
    [radRequest startWithCompletionHandler:^(id response) {
        NSLog(@"reloaded conversation for beacon is: %@", response);
        convoArray = response;
        [convoTable reloadData];
    }];
}

-(void) populateBeaconContent {
    
    
    
    if (sendingBeaconID == nil){
        FindBeaconContent *content = [[FindBeaconContent alloc] init];
        content.findBeaconContentDelegate = self;
        [content findBeaconContent:[[currentBeacon.beaconDictionary objectForKey:@"id"]integerValue]];
    }else {
        
        FindBeaconContent *content = [[FindBeaconContent alloc] init];
        content.findBeaconContentDelegate = self;
        [content findBeaconContent:sendingBeaconID.integerValue];
        
    }
    
    //    NSString * tempname = [currentBeacon beaconname];
    //    [beaconNameOutlet setText:tempname];
    //
    //
    //    NSString * templocation = [currentBeacon beaconlocation];
    //    [beaconLocationOutlet setText:templocation];
    
    
}

-(void) populateBeaconInfo {
    
    if (sendingBeaconID == nil){
        FindBeaconInfo *info =[[FindBeaconInfo alloc] init];
        info.findBeaconInfoDelegate = self;
        [info findBeaconInfo:[[currentBeacon.beaconDictionary objectForKey:@"id"]integerValue]];
    } else {
        
        FindBeaconInfo *info =[[FindBeaconInfo alloc] init];
        info.findBeaconInfoDelegate = self;
        [info findBeaconInfo:sendingBeaconID.integerValue];
    }
}

//-(void) populateConversationContent
//{
//    BeaconConversationTable *dataDelegate = [[BeaconConversationTable alloc] init];
//    conversationTable.delegate = dataDelegate;
//    conversationTable.dataSource = dataDelegate;
//    //[dataDelegate getConversationInfoForBeacon:[currentBeacon.beaconDictionary objectForKey:@"id"]];
//}

-(void) updateBeaconInfo:(NSDictionary *)myDictionary  {
    
    if (sendingBeaconID ==nil && [currentBeacon.beaconDictionary objectForKey:@"id"] != nil) {
        NSLog(@"updatingBeaconInfo");
        self.jsonInfoArray = myDictionary;
        NSString *newString = [NSString stringWithFormat:@"%d", [[currentBeacon.beaconDictionary objectForKey:@"id"]integerValue]];
        userNameString = [[jsonInfoArray objectForKey:newString] objectForKey:@"creator"];
        [self findUserInfo];
        NSLog(@"this is the user name string: %@", userNameString);
        [beaconNameOutlet setText:[[jsonInfoArray objectForKey:newString] objectForKey:@"name"]];
        if (currentBeaconisMeBeacon == NO) {
            if ([[[jsonInfoArray objectForKey:newString]objectForKey:@"followed"]integerValue] == YES) {
                self.currentBeaconisFollowed = YES;
                [self setUpFollowButtonWithArgs:currentBeaconisFollowed];
            }else if ([[[jsonInfoArray objectForKey:newString]objectForKey:@"followed"]integerValue] == NO) {
                self.currentBeaconisFollowed = NO;
                [self setUpFollowButtonWithArgs:currentBeaconisFollowed];
            }
            
        }else if (currentBeaconisMeBeacon == YES) {
            
            self.followBeaconButtonOutlet.alpha = 0;
            
        }
    }else if (sendingBeaconID != nil) {
        
        NSLog(@"updatingBeaconInfo");
        self.jsonInfoArray = myDictionary;
        NSString *newString = [NSString stringWithFormat:@"%d", [sendingBeaconID integerValue]];
        [beaconNameOutlet setText:[[jsonInfoArray objectForKey:newString] objectForKey:@"name"]];
        userNameString = [[jsonInfoArray objectForKey:newString] objectForKey:@"creator"];
        [self findUserInfo];
        NSLog(@"this is the user name string: %@", userNameString);
        
        NSString *beaconLat = [NSString stringWithFormat:@"%@", [[[jsonInfoArray objectForKey:newString]objectForKey:@"center"]objectAtIndex:0]];
        NSString *beaconLong = [NSString stringWithFormat:@"%@", [[[jsonInfoArray objectForKey:newString]objectForKey:@"center"]objectAtIndex:1]];
        NSString *beaconSpan = [NSString stringWithFormat:@"%@", [[jsonInfoArray objectForKey:newString]objectForKey:@"radius"]];
        
        [self location:beaconLat longitude:beaconLong spanlat:beaconSpan spanlong:beaconSpan];
        if (currentBeaconisMeBeacon == NO) {
            if ([[[jsonInfoArray objectForKey:newString]objectForKey:@"followed"]integerValue] == YES) {
                self.currentBeaconisFollowed = YES;
                [self setUpFollowButtonWithArgs:currentBeaconisFollowed];
            }else if ([[[jsonInfoArray objectForKey:newString]objectForKey:@"followed"]integerValue] == NO) {
                self.currentBeaconisFollowed = NO;
                [self setUpFollowButtonWithArgs:currentBeaconisFollowed];
            }
            
        }else if (currentBeaconisMeBeacon == YES) {
            
            [self.followBeaconButtonOutlet setTitle:@"Send Heartbeat" forState:UIControlStateNormal];
            
        }
        
    }
    
    
}

-(void) updateTextData:(NSMutableArray *)myArray {
    
    self.jsonArray = myArray;
    //    beaconContentOutlet.text= [[[jsonArray objectAtIndex:0] objectForKey:@"content"] objectForKey:@"text"];
    if (jsonArray != nil) {
        //[contentTableView reloadData];
        [myGridView reloadData];
    }else {
        
        [self populateBeaconContent];
        
    }
    
}

-(void) findUserInfo {
    
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userNameString ,@"user", nil] apiMethod:@"userinfo" httpMethod:@"GET"];
    
    [r startWithCompletionHandler:^(id response) {
        
        // deal with response object
        NSLog(@"working %@", response);
        if ([response isKindOfClass:[NSArray class]]) {
            responseArray = response;
        }else if ([response isKindOfClass:[NSDictionary class]]){
            
            responseDictionary = response;
            NSURL *imageURL = [NSURL URLWithString:[responseDictionary objectForKey:@"picture"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *profilePicture = [UIImage imageWithData:imageData];
            [self.beaconCreatorProfileButton setImage:profilePicture forState:UIControlStateNormal];
        }
    }];
    
}



-(void) location:(NSString *)latitude longitude:(NSString *)longitude spanlat:(NSString *)spanlat spanlong:(NSString *)spanlong  {
    
    MKCoordinateRegion dukeregion;
    
    NSString * tempcenterlat = latitude;
    double x1 = [tempcenterlat doubleValue];
    dukeregion.center.latitude= x1;
    
    NSString * tempcenterlong = longitude;
    double y1 = [tempcenterlong doubleValue];
    dukeregion.center.longitude = y1;
    
    NSString * tempspanlat = spanlat;
    double x2 = [tempspanlat doubleValue];
    dukeregion.span.longitudeDelta = x2/4000;
    
    NSString * tempspanlong = spanlong;
    double y2 = [tempspanlong doubleValue];
    dukeregion.span.latitudeDelta= y2/4000;
    
    [self.contentMapView setRegion: dukeregion animated:YES];
    [contentMapView removeOverlays: [contentMapView overlays]];
    
    MKCircle * circle = [MKCircle circleWithCenterCoordinate:dukeregion.center radius:([spanlat doubleValue])];
    [contentMapView addOverlay:circle];
    
}

#pragma mark View for Table Cells, Annotations and Overlays Handle

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.lineWidth = 1;
    return circleView;
}



//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [jsonArray count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    static NSString *MyIdentifier = @"MyIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//    }
//
//    //    if (tableView == contentTableView) {
//    //        if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"text"] != nil) {
//    //            cell.textLabel.text = [[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"text"];
//    //            cell.detailTextLabel.text = [NSString stringWithFormat:@"text content by %@",[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"poster"]] ;
//    //
//    //        }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"video_id"] != nil) {
//    //
//    //            cell.textLabel.text = [[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"video_id"];
//    //            cell.detailTextLabel.text = [NSString stringWithFormat:@"video content by %@",[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"poster"]];
//    //
//    //        }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"url"] != nil) {
//    //
//    //            cell.textLabel.text = [[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"url"];
//    //            cell.detailTextLabel.text = [NSString stringWithFormat:@"image content by %@",[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"poster"]];
//    //
//    //        }
//    //        cell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18.0];
//    //        cell.detailTextLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:13.0];
//    //        return cell;
//    //    }
//
//    NSLog(@"current index path is: %@", indexPath);
//
//    return cell;
//}
//
//-(void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (tableView == contentTableView)
//    {
//        if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"text"] != nil) {
//
//            BeaconDetailContentViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailContentID"];
//            [newViewControllerInstance setTitle:beaconNameOutlet.text];
//            [newViewControllerInstance setBeaconContentDictionary:[jsonArray objectAtIndex:indexPath.row]];
//            [newViewControllerInstance setContentString:[[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"text"]];
//            [newViewControllerInstance setContentID:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
//            [newViewControllerInstance setContentType:@"text"];
//            [newViewControllerInstance setUserNameString:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
//
//            if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == -1) {
//                [newViewControllerInstance setContentVotedDown:YES];
//            }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == 0) {
//                [newViewControllerInstance setContentNotVotedYet:YES];
//            }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == 1) {
//                [newViewControllerInstance setContentVotedUp:YES];
//            }
//            [newViewControllerInstance setContentVoteScore:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"score"]];
//            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
//
//            //        NSArray *controllers = [NSArray arrayWithObject:newViewControllerInstance];
//            //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//            //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
//
//        }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"video_id"] != nil) {
//
//            BeaconDetailContentViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailContentID"];
//            [newViewControllerInstance setTitle:beaconNameOutlet.text];
//            [newViewControllerInstance setBeaconContentDictionary:[jsonArray objectAtIndex:indexPath.row]];
//            [newViewControllerInstance setContentString:[[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"video_id"]];
//            [newViewControllerInstance setContentID:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
//            [newViewControllerInstance setContentType:@"video_ext"];
//            [newViewControllerInstance setUserNameString:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
//            if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == -1) {
//                [newViewControllerInstance setContentVotedDown:YES];
//            }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == 0) {
//                [newViewControllerInstance setContentNotVotedYet:YES];
//            }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == 1) {
//                [newViewControllerInstance setContentVotedUp:YES];
//            }
//            [newViewControllerInstance setContentVoteScore:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"score"]];
//            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
//
//            //        NSArray *controllers = [NSArray arrayWithObject:newViewControllerInstance];
//            //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//            //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
//
//        }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"url"] != nil) {
//
//            BeaconDetailContentViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailContentID"];
//            [newViewControllerInstance setTitle:beaconNameOutlet.text];
//            [newViewControllerInstance setBeaconContentDictionary:[jsonArray objectAtIndex:indexPath.row]];
//            [newViewControllerInstance setContentString:[[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"content"] objectForKey:@"url"]];
//            [newViewControllerInstance setContentID:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
//            [newViewControllerInstance setContentType:@"image"];
//            [newViewControllerInstance setUserNameString:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
//            if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == -1) {
//                [newViewControllerInstance setContentVotedDown:YES];
//            }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == 0) {
//                [newViewControllerInstance setContentNotVotedYet:YES];
//            }else if ([[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"vote"]integerValue] == 1) {
//                [newViewControllerInstance setContentVotedUp:YES];
//            }
//            [newViewControllerInstance setContentVoteScore:[[jsonArray objectAtIndex:indexPath.row] objectForKey:@"score"]];
//            [self.navigationController pushViewController:newViewControllerInstance animated:YES];
//
//            //        NSArray *controllers = [NSArray arrayWithObject:newViewControllerInstance];
//            //        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
//            //        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
//
//        }
//
//    }else if (tableView == _customSlidingTableView.slidingTableViewTableView) {
//
//        NSLog(@"going to new table");
//        ProfileViewController *newViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"meProfileViewID"];
//        [newViewController setUserNameString:[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
//        [newViewController setTitle:[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
//        [self.navigationController pushViewController:newViewController animated:YES];
//
//    }
//    else if (tableView == conversationTable)
//    {
//        NSLog(@"selected convo table");
//    }
//
//}

//-(void) setupAddButton
//{
//    UIImage *addImage = [UIImage imageNamed:@"add.png"];
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.bounds = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.height);
//    [addButton setImage:addImage forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector(newPostContentMethod) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
//    self.navigationItem.rightBarButtonItem = addButtonItem;
//}

//-(void) createTableHeader
//{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//    label.backgroundColor = [UIColor redColor];
//    label.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:17];
//    //label.shadowColor = [UIColor blackColor];
//    label.textAlignment = UITextAlignmentLeft;
//    label.textColor = [UIColor blackColor];
//    label.text = @"Join the conversation!";
//    conversationTable.tableHeaderView = label;
//}

#pragma mark Apple Methods Handle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [contentMapView setDelegate:self];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
    userTokenString = [userDefaults objectForKey:@"token"];
    
	// Do any additional setup after loading the view.
    [self setupSideMenuBarButtonItem];
    //[self populateConversationContent];
    
    CreateDetailViewController *test = [[CreateDetailViewController alloc] init];
    test.postBeaconContentDelegate=self;
    
    [self location:[currentBeacon beaconcenterlat] longitude:currentBeacon.beaconcenterlong spanlat:currentBeacon.beaconspanlat spanlong:currentBeacon.beaconspanlong];
    
    [self populateConvoTable];
    [self populateBeaconContent];
    [self populateBeaconInfo];
    //[self createTableHeader];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    [self setSwipeCount:0];
    RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID,@"beacon", nil] apiMethod:@"beacon/followers" httpMethod:@"GET"];
    NSLog(@"beacon id is: %@", sendingBeaconID);
    [r startWithCompletionHandler:^(id response) {
        int numFollowers = [response count];
        if (numFollowers == 1)
        {
            [numberFollowingButton setTitle:[NSString stringWithFormat:@"%i follower", numFollowers] forState:UIControlStateNormal];
        }
        else
        {
            [numberFollowingButton setTitle:[NSString stringWithFormat:@"%i followers", numFollowers] forState:UIControlStateNormal];
        }
    }];
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

#pragma mark UIGridViewMethods

//Code for UIGridView

- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{
	return 80;
}

- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{
	return 80;
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
	return 4;
}


- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
	return [jsonArray count]+1;
}


//Helper method to convert to linear index rather than row/column pairing
-(NSInteger) convertToCellNumberFromRow:(int)rowIndex AndColumn:(int)columnIndex
{
    return (rowIndex * [self numberOfColumnsOfGridView:nil])+(columnIndex);
}


// params should contain two key/value pairs: "cell", the cell to load the image to, and "urlString", the URL of the image to load
- (void)loadImage:(NSDictionary *)params
{
    NSString *urlString = [params objectForKey:@"urlString"];
    Cell *cell = [params objectForKey:@"cell"];
    UIActivityIndicatorView *activityIndicatorView = [params objectForKey:@"activityIndicatorView"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    
    [activityIndicatorView removeFromSuperview];
    cell.thumbnail.image = image;
}

- (void)loadImage:(NSString *)urlString toCell:(Cell *)cell
{
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.frame = cell.thumbnail.frame;
    [cell.thumbnail addSubview:aiv];
    [aiv startAnimating];
    
    [cell.thumbnail setNeedsDisplay];
    
    
    [self performSelectorInBackground:@selector(loadImage:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"cell",urlString,@"urlString",aiv,@"activityIndicatorView",nil]];

}


- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    if ([self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex] == 0)
    {
        static NSString *CellIdentifier = @"imagecell";
        Cell *cell = (Cell *)[grid dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[Cell alloc] init];
        }
        cell.thumbnail.image = [UIImage imageNamed:@"btn_add_newcontent.png"];
        return cell;
    }
    // Minus one here to make room for the add button
    NSDictionary *currDictionary = [jsonArray objectAtIndex:([self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex]-1)];
    
    //Content is text
    if ([[currDictionary objectForKey:@"content"] objectForKey:@"text"] != nil) {
        static NSString *CellIdentifier = @"textcell";
        TextCell *tCell = (TextCell *)[grid dequeueReusableCellWithIdentifier:CellIdentifier];
        if (tCell == nil)
        {
            tCell = [[TextCell alloc] init];
        }
        //If the text content has a desciption field, interpret as a title and use this for display on the thumbnail
        if ([currDictionary objectForKey:@"description"])
        {
            tCell.tlabel.text = [currDictionary objectForKey:@"description"];
        }
        //If no title, just use the text
        else
        {
            tCell.tlabel.text = [[currDictionary objectForKey:@"content"] objectForKey:@"text"];
        }
        return tCell;
        
    }
    //Content is a video
    else
    {
        static NSString *CellIdentifier = @"imagecell";
        Cell *cell = (Cell *)[grid dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[Cell alloc] init];
        }
        if ([[currDictionary objectForKey:@"content"] objectForKey:@"video_id"] != nil) {
            cell.label.text = [[currDictionary objectForKey:@"content"] objectForKey:@"video_id"];
            //YouTube video
            if ([[[currDictionary objectForKey:@"content"] objectForKey:@"site"] isEqualToString:@"youtube"])
            {
                NSString *urlString = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/%@.jpg", [[currDictionary objectForKey:@"content"] objectForKey:@"video_id"], @"2"];
                NSLog(@"youtube url is: %@", urlString);
                
                [self loadImage:urlString toCell:cell];
            }
            //        cell.detailTextLabel.text = [NSString stringWithFormat:@"video content by %@",[currDictionary objectForKey:@"poster"]];
            
        }
        //Content is a picture
        else if ([[currDictionary objectForKey:@"content"] objectForKey:@"url"] != nil) {
            
            //            cell.label.text = [[currDictionary objectForKey:@"content"] objectForKey:@"url"];
            NSMutableString *urlString = [[[currDictionary objectForKey:@"content"] objectForKey:@"url"] mutableCopy];
            [urlString replaceCharactersInRange:[urlString rangeOfString:@".us/"] withString:@".us/th_"];
            
            [self loadImage:urlString toCell:cell];
            //        cell.detailTextLabel.text = [NSString stringWithFormat:@"image content by %@",[currDictionary objectForKey:@"poster"]];
            //        [self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex];
        }
        //cell.label.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:18.0];
        //    cell.detailTextLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:13.0];
        
        //cell.label.text = [NSString stringWithFormat:@"(%d,%d)", rowIndex, columnIndex];
        
        return cell;
    }
}

- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    if ([self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex] == 0)
    {
        [self newPostContentMethod];
    }
    else
    {
        NSDictionary *currDictionary = [jsonArray objectAtIndex:([self convertToCellNumberFromRow:rowIndex AndColumn:columnIndex]-1)];
        
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
            
        }else if ([[currDictionary objectForKey:@"content"] objectForKey:@"url"] != nil) {
            
            BeaconDetailContentImageViewController *newViewControllerInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"BeaconDetailImageContentID"];
            [newViewControllerInstance setTitle:beaconNameOutlet.text];
            [newViewControllerInstance setBeaconContentDictionary:currDictionary];
            [newViewControllerInstance setContentString:[[currDictionary objectForKey:@"content"] objectForKey:@"url"]];
            [newViewControllerInstance setContentID:[currDictionary objectForKey:@"id"]];
            [newViewControllerInstance setContentType:@"image"];
            [newViewControllerInstance setUserNameString:[currDictionary objectForKey:@"poster"]];
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
            
            
        }
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
    static NSString *CellIdentifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    //Special cell at the beginning to start a new thread
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Join the conversation!";
    }
    else
    {
        if (convoArray && [convoArray isKindOfClass:[NSArray class]])
        {
            //cell.textLabel.text = @"This is the title of the thread.  It can be however long it needs to be beacuse it's really a long post.";
            //cell.detailTextLabel.text = @"Multi-Line\nText";
            NSDictionary *mostRecentPost = [convoArray objectAtIndex:(indexPath.row-1)];
            //If there are responses, display them in the subtext for the cell.
            //Otherwise, display nothing.
            if ([[mostRecentPost objectForKey:@"children"] count] >0)
            {
                while ([[mostRecentPost objectForKey:@"children"] count] >0) {
                    mostRecentPost = [[mostRecentPost objectForKey:@"children"] objectAtIndex:0];
                }
                cell.detailTextLabel.text = [mostRecentPost objectForKey:@"text"];
                cell.detailTextLabel.numberOfLines = 1;
                cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
            }
            //    NSIndexPath *myPath = [NSIndexPath indexPathForRow:0 inSection:0];
            //    if ([indexPath isEqual:myPath])
            //    {
            //        NSLog(@"current index paths are: %@ and %@", myPath, indexPath);
            //        cell.textLabel.text = @"Join the conversation!";
            //    }
            
            cell.textLabel.text = [[convoArray objectAtIndex:(indexPath.row-1)] objectForKey:@"text"];
            cell.textLabel.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:14];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"num of lines is: %i", [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.numberOfLines);
    //    NSLog(@"detail text label is: %@", [tableView cellForRowAtIndexPath:indexPath].detailTextLabel);
    //    if ([tableView cellForRowAtIndexPath:indexPath].detailTextLabel)
    //    {
    //        return (44.0 + ([tableView cellForRowAtIndexPath:indexPath].detailTextLabel.numberOfLines - 1) * 19.0);
    //    }
    return 44;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Responding to sliding view to see who's following the beacon
    if ([tableView.dataSource isMemberOfClass:[SlidingTableView class]])
    {
        ProfileViewController *meProfileController = [self.storyboard instantiateViewControllerWithIdentifier:@"meProfileViewID2"];
        //NSString *userIDString = [NSString stringWithFormat:@"%@",[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"] ];
        [meProfileController setUserNameString:[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
        [meProfileController setTitle:[[responseFollowedArray objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
        [self.navigationController pushViewController:meProfileController animated:YES];
    }
    else
    {
        if (indexPath.row == 0)
        {
            PostContentView *customView = [[[NSBundle mainBundle]loadNibNamed:@"PostContentView" owner:self options:nil]objectAtIndex:0];
            customView.postTextContentTextView.text = @"Post Text Here";
            customView.postSendingBeaconID = sendingBeaconID;
            customView.postContentType = @"text";
            customView.postContentViewDelegate =self;
            customView.userTask = @"PostConversation";
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.view addGestureRecognizer:singleTapRecognizer];
            [customView addGestureRecognizer:singleTapRecognizer];
            
            SlidingViewOptions options = ShowCancelButton|CancelOnBackgroundPressed|AvoidKeyboard;
            void (^cancelOrDoneBlock)() = ^{
                // we must manually slide out the view out if we specify this block
                [MFSlidingView slideOut];
                [customView.descriptionTextField resignFirstResponder];
                
            };
            
            [MFSlidingView slideView:customView intoView:self.view onScreenPosition:MiddleOfScreen offScreenPosition:MiddleOfScreen title:@"Post Text" options:options doneBlock:cancelOrDoneBlock cancelBlock:cancelOrDoneBlock];
            
        }
        else
        {
            ConvoThreadViewController *threadController = [self.storyboard instantiateViewControllerWithIdentifier:@"convoThreadID"];
            threadController.title =[[convoArray objectAtIndex:(indexPath.row-1)] objectForKey:@"text"];
            threadController.threadDict = [convoArray objectAtIndex:(indexPath.row-1)];
            threadController.beaconID = sendingBeaconID;
            [self.navigationController pushViewController:threadController animated:YES];
        }
    }
}

-(void)populateConvoTable
{
    RadiusRequest *radRequest = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:sendingBeaconID, @"beacon", nil] apiMethod:@"conversation"];
    [radRequest startWithCompletionHandler:^(id response) {
        convoArray = response;
        NSLog(@"conversation response: %@", response);
        [convoTable reloadData];
    }];
}

@end
