//
//  ImageContent.h
//  Radius
//
//  Created by Fred Ehrsam on 11/8/12.
//
//

#import "RadiusContent.h"

@interface ImageContent : RadiusContent

@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *thumbURL;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@end
