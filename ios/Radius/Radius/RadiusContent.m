//
//  RadiusContent.m
//  Radius
//
//  Created by Fred Ehrsam on 11/8/12.
//
//

#import "RadiusContent.h"
#import "ImageContent.h"

@implementation RadiusContent

+(RadiusContent *)contentWithDictionary:(NSDictionary *)contentDictionary
{
    NSString *contentType = [contentDictionary objectForKey:@"type"];
    
    Class contentClass = nil;
    if([contentType isEqualToString:@"image"]) {
        contentClass = [ImageContent class];
    }
    
    if(!contentClass) return nil;
    
    RadiusContent *content = [[contentClass alloc] initWithDictionary:contentDictionary];
    return content;
    
}

-(id)initWithDictionary:(NSDictionary *)contentDictionary
{
    self = [super init];
    if(self) {
        self.posterInfo = [contentDictionary objectForKey:@"poster_o"];
        self.contentID = [[contentDictionary objectForKey:@"id"] integerValue];
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[contentDictionary objectForKey:@"timestamp"] doubleValue]];
        self.numComments = [[contentDictionary objectForKey:@"num_comments"] integerValue];
        self.score = [[contentDictionary objectForKey:@"score"] integerValue];
        self.vote = [[contentDictionary objectForKey:@"vote"] integerValue];
        self.description = [contentDictionary objectForKey:@"description"];
        
        NSDictionary *contentDetailDictionary = [contentDictionary objectForKey:@"content"];
        [self initializeContentDetailsWithDictionary:contentDetailDictionary];
    }
    return self;
}

-(void)initializeContentDetailsWithDictionary:(NSDictionary *)contentDetailDictionary
{
    // Do nothing.  Override for each content type.
}

-(UIViewController *)linkViewController
{
    return nil;
}

@end
