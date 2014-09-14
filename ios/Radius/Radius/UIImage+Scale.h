//
//  UIImage+Scale.h
//  radius
//
//  Created by David Herzka on 10/10/12.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

- (UIImage*)scaleToSize:(CGSize)maxSize;
- (UIImage*)scaleToWidth:(CGFloat)width;
- (UIImage*)scaleToHeight:(CGFloat)height;

@end
