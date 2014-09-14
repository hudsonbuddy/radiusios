//
//  TwitterLoginViewController.h
//  TwitterTest
//
//  Created by David Herzka on 8/14/12.
//  Copyright (c) 2012 David Herzka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import "RadiusViewController.h"

@interface TwitterLoginViewController : RadiusViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
