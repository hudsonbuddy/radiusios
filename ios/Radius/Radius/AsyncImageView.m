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
@synthesize imageView = _imageView;
@synthesize imageURL = _imageURL;
@synthesize imageCache = _imageCache;

BOOL _loaded = NO;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.clipsToBounds = YES;
        
                
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Create placeholder (activity indicator view for now)
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [aiv startAnimating];
        placeholder = aiv;
        [self centerPlaceholder];
        [self addSubview:placeholder];


    }
    return self;
}

-(id)initWithFrame:(CGRect)frame imageURL:(NSURL *)url cache:(id)cache loadImmediately:(BOOL)loadImmediately {
    self = [self initWithFrame:frame];
    if (self) {        
        self.imageCache = cache;
        
        if(url) {
        
            self.imageURL = url;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(loadImmediately) {
                    [self loadImage];
                }
                
            });
            
        }
    }
    return self;
}

-(void)setImageURL:(NSURL *)imageURL {
    if(self.loaded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView removeFromSuperview];
            self.imageView.image = nil;
            [placeholder startAnimating];
            [self setNeedsDisplay];
        });
    
       
    }
    _loaded = NO;
    _imageURL = imageURL;
    urlKey = [NSString stringWithFormat:@"%X",imageURL.hash];
}

-(id)initWithFrame:(CGRect)frame imageURL:(NSURL *)url cache:(id)cache {
    return [self initWithFrame:frame imageURL:url cache:cache loadImmediately:YES];
}

-(void)loadImage {
    if(self.loaded) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = self.imageCache?[self.imageCache objectForKey:urlKey]:nil;
        
        if(image) {
            [self placeImage:image];
        } else {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(queue, ^{
                NSError *downloadError;
                NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL options:NSDataReadingUncached error:&downloadError];
                
                if(downloadError)
                    NSLog(@"Download error: %@",downloadError);
                
                UIImage *downloadedImage = nil;
                if(imageData) {
                    downloadedImage = [UIImage imageWithData:imageData];
                    
                    // For now, do all cache reads and writes in the main thread
                    // later, should make cache a thread-safe data structure
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self.imageCache && downloadedImage) {
                            @try {
                                [self.imageCache setObject:downloadedImage forKey:urlKey];
                            }
                            @catch (NSException *exception) {
                                NSLog(@"download error");
                            };
                        }
                    });
                }
                
                [self placeImage:downloadedImage];
            });
        }
    });
    
}

-(void)placeImage:(UIImage *)image {
    
    if([self.delegate respondsToSelector:@selector(asyncImageView:willShowImage:)]) {
        image = [self.delegate asyncImageView:self willShowImage:image];
    }
    
    if(!shouldntLoad) {
        dispatch_async(dispatch_get_main_queue(),^{
            [placeholder stopAnimating];
            self.imageView.image = image;
            [self addSubview:self.imageView];
            [self setNeedsDisplay];
        });
        _loaded = YES;
    }
}

-(void)setShouldntLoad {
    shouldntLoad = YES;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
    [self centerPlaceholder];
    [self.imageView setNeedsDisplay];
    [self setNeedsDisplay];
}

-(void)centerPlaceholder {
    placeholder.frame = CGRectMake(self.frame.size.width/2-placeholder.frame.size.width/2,
                                   self.frame.size.height/2-placeholder.frame.size.height/2,
                                   placeholder.frame.size.width,
                                   placeholder.frame.size.height);
}

@end
