//
//  AsyncImageView.h
//  AsyncImageTest
//
//  Created by David Herzka on 10/14/12.
//  Copyright (c) 2012 David Herzka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AsyncImageViewDelegate;

@interface AsyncImageView : UIView {
    UIActivityIndicatorView *placeholder;
    NSString *urlKey;
    NSLock *cacheLock;
    BOOL shouldntLoad;
}


-(id) initWithFrame:(CGRect)frame imageURL:(NSURL *)url cache:(id)cache loadImmediately:(BOOL)loadImmediately;
-(id) initWithFrame:(CGRect)frame imageURL:(NSURL *)url cache:(id) cache;

-(void)loadImage;

// Call this if the view containing this image disappears so that once the image is downloaded, it isn't being displayed to a view that no longer exists
-(void)setShouldntLoad;

@property (readonly) BOOL loaded;
@property (readonly) UIImageView *imageView;
@property (weak,nonatomic) id<AsyncImageViewDelegate> delegate;
@property (strong,nonatomic) NSURL *imageURL;
@property (strong,nonatomic) id imageCache;

@end

@protocol AsyncImageViewDelegate <NSObject>

@optional
-(UIImage *) asyncImageView:(AsyncImageView *)imageView willShowImage:(UIImage *)image;

@end
