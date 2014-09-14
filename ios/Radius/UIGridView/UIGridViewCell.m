//
//  UIGridViewCell.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridViewCell.h"


@implementation UIGridViewCell

@synthesize rowIndex;
@synthesize colIndex;
@synthesize view;
@synthesize reuseIdentifier;

-(id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super init];
    if(self) {
        self.reuseIdentifier = identifier;
    }
    return self;
}

- (void) addSubview:(UIView *)v
{
	[super addSubview:v];
	v.exclusiveTouch = NO;
	v.userInteractionEnabled = NO;
}


@end
