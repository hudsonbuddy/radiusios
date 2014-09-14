//
//  AsyncImageView.m
//  AsyncImageTest
//
//  Created by David Herzka on 10/14/12.
//  Copyright (c) 2012 David Herzka. All rights reserved.
//

#import "AsyncImageView.h"

@implementation AsyncImageView

@synthesize loaded = _loaded;

BOOL _loaded = NO;

-(id)initWithFrame:(CGRect)frame imageURL:(NSURL *)url cache:(id)cache loadImmediately:(BOOL)loadImmediately {
    self = [super initWithFrame:frame];
    if (self) {        
        imageCache = cache;
        urlKey = [NSString stringWithFormat:@"%X",url.hash];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [imageCache objectForKey:urlKey];
        
            if(image) {
                [self placeImage:image];
            } else {
            
                // Create placeholder (activity indicator view for now)
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [aiv startAnimating];
                placeholder = aiv;
                
                // Center placeholder
                placeholder.frame = CGRectMake(self.frame.size.width/2-placeholder.frame.size.width/2,
                                               self.frame.size.height/2-placeholder.frame.size.height/2,
                                               placeholder.frame.size.width,
                                               placeholder.frame.size.height);
                [self addSubview:placeholder];
                
                imageURL = url;
                
                if(loadImmediately) {
                    [self loadImage];
                }
            }
        });
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame imageURL:(NSURL *)url cache:(id)cache {
    return [self initWithFrame:frame imageURL:url cache:cache loadImmediately:YES];
}

-(void)loadImage {
    if(self.loaded) return;
        
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        
        // For now, do all cache reads and writes in the main thread
        // later, should make cache a thread-safe data structure
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageCache setObject:image forKey:urlKey];
        });
        
        [self placeImage:image];
    });
}

-(void)placeImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    
    if(!shouldntLoad) {
        dispatch_async(dispatch_get_main_queue(),^{
            [placeholder removeFromSuperview];
            [self addSubview:imageView];
            [self setNeedsDisplay];
        });
        _loaded = YES;
    }
}

-(void)setShouldntLoad {
    shouldntLoad = YES;
}

@end
