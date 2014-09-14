//
//  PostContentView.m
//  radius
//
//  Created by Hud on 8/15/12.
//
//

#import "PostContentView.h"

@implementation PostContentView

@synthesize postTextContentTextView;
@synthesize descriptionTextField;
@synthesize responseArray, responseDictionary;
@synthesize postSendingBeaconID, postSendingContentID;
@synthesize postContentViewDelegate;
@synthesize postContentType;
@synthesize userTokenString;
@synthesize userTask;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (IBAction)doSomething:(id)sender {
    
    if (userTask == @"PostContent") {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
        userTokenString = [userDefaults objectForKey:@"token"];
        
        
        if (postContentType == @"text") {
            
            if (postTextContentTextView.text.length != 0) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Posting" message:@"Text" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                NSLog(@"%@", postTextContentTextView.text);
                NSLog(@"%@", postSendingBeaconID);
                
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", postTextContentTextView.text, @"description",postSendingBeaconID, @"beacon", descriptionTextField.text, @"text", nil] apiMethod:@"post_text_content" httpMethod:@"POST"];
                
                [r startWithCompletionHandler:^(id response, RadiusError *error) {
                    
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([response isKindOfClass:[NSArray class]]) {
                        responseArray = response;
                    }else if ([response isKindOfClass:[NSDictionary class]]){
                        
                        responseDictionary = response;
                    }
                    
                    [MFSlidingView slideOut];
                    
                    if([postContentViewDelegate respondsToSelector:@selector(reloadBeaconContentDataTable)]){
                        
                        [postContentViewDelegate reloadBeaconContentDataTable];
                        [self resignFirstResponder];
                    }
                }];
            }
        }else if (postContentType == @"image"){
            
            
            if (postTextContentTextView.text.length != 0) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Posting Image" message:@"Please wait, will return you to Beacon" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                NSLog(@"%@", postTextContentTextView.text);
                NSLog(@"%@", postSendingBeaconID);
                
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", postTextContentTextView.text, @"description",postSendingBeaconID, @"beacon",descriptionTextField.text, @"image_url", nil] apiMethod:@"post_image_content" httpMethod:@"POST"];
                
                [r startWithCompletionHandler:^(id response, RadiusError *error) {
                    
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([response isKindOfClass:[NSArray class]]) {
                        responseArray = response;
                    }else if ([response isKindOfClass:[NSDictionary class]]){
                        
                        responseDictionary = response;
                    }
                    
                    [MFSlidingView slideOut];
                    
                    if([postContentViewDelegate respondsToSelector:@selector(reloadBeaconContentDataTable)]){
                        
                        [postContentViewDelegate reloadBeaconContentDataTable];
                        [self resignFirstResponder];
                    }
                }];
            }
            
            
        }else if (postContentType == @"video"){
            
            
            if (postTextContentTextView.text.length != 0) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Posting" message:@"Video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                NSLog(@"%@", postTextContentTextView.text);
                NSLog(@"%@", postSendingBeaconID);
                
                RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", postTextContentTextView.text, @"description",postSendingBeaconID, @"beacon",descriptionTextField.text, @"video_url", nil] apiMethod:@"post_video_content" httpMethod:@"POST"];
                
                [r startWithCompletionHandler:^(id response, RadiusError *error) {
                    
                    // deal with response object
                    NSLog(@"working %@", response);
                    if ([response isKindOfClass:[NSArray class]]) {
                        responseArray = response;
                    }else if ([response isKindOfClass:[NSDictionary class]]){
                        
                        responseDictionary = response;
                    }
                    
                    [MFSlidingView slideOut];
                    
                    if([postContentViewDelegate respondsToSelector:@selector(reloadBeaconContentDataTable)]){
                        
                        [postContentViewDelegate reloadBeaconContentDataTable];
                        [self resignFirstResponder];
                    }
                }];
            }
            
            
        }
        
    }
    
    
    
    if (userTask == @"PostComment")
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
        userTokenString = [userDefaults objectForKey:@"token"];
        
        
        
        
        if (postTextContentTextView.text.length != 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Posting" message:@"Comment" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            NSLog(@"%@", postTextContentTextView.text);
            NSLog(@"%@", postSendingBeaconID);
            
            RadiusRequest *r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token", postTextContentTextView.text, @"text",postSendingContentID, @"content_id", nil] apiMethod:@"comment" httpMethod:@"POST"];
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                
                // deal with response object
                NSLog(@"working %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
                
                [MFSlidingView slideOut];
                
                if([postContentViewDelegate respondsToSelector:@selector(reloadBeaconContentDataTable)]){
                    
                    [postContentViewDelegate reloadBeaconContentDataTable];
                    [self resignFirstResponder];
                }
            }];
        }
    }
    
    if (userTask == @"PostConversation")
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"user defaults token is: %@", [userDefaults objectForKey:@"token"]);
        userTokenString = [userDefaults objectForKey:@"token"];
        
        if (postTextContentTextView.text.length != 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Posting" message:@"Comment" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            NSLog(@"%@", postTextContentTextView.text);
            NSLog(@"%@", postSendingBeaconID);
            
            RadiusRequest *r;
            if (postSendingContentID)
            {
                r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",  postSendingBeaconID, @"beacon",postTextContentTextView.text, @"text", postSendingContentID, @"parent",nil] apiMethod:@"conversation/post" httpMethod:@"POST"];
            }
            else
            {
                r = [RadiusRequest requestWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:userTokenString, @"token",  postSendingBeaconID, @"beacon",postTextContentTextView.text, @"text", nil] apiMethod:@"conversation/post" httpMethod:@"POST"];
            }
            
            [r startWithCompletionHandler:^(id response, RadiusError *error) {
                
                // deal with response object
                NSLog(@"working on creating thread, response is: %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    responseArray = response;
                }else if ([response isKindOfClass:[NSDictionary class]]){
                    
                    responseDictionary = response;
                }
                
                [MFSlidingView slideOut];
                
                if([postContentViewDelegate respondsToSelector:@selector(reloadConversationTable)]){
                    
                    [postContentViewDelegate reloadConversationTable];
                    [self resignFirstResponder];
                }
            }];
        }
    }
    
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [descriptionTextField endEditing:YES];
    [postTextContentTextView endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == self.descriptionTextField)
    {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView.text isEqualToString:@"Post Text Here"]) {
        [textView setText:@""];
    }
    
}

@end