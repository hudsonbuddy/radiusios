//
//  TextCell.m
//  Radius
//
//  Created by Fred Ehrsam on 8/29/12.
//
//

#import "TextCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation TextCell

@synthesize tlabel;

- (id)init
{
    if (self = [super init]) {
		
        self.frame = CGRectMake(0, 0, 80, 80);
		
		[[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
		
        [self addSubview:self.view];
		
        self.tlabel.text = @"jason is gay";
        [self.tlabel setFont:[UIFont fontWithName:@"Quicksand" size:12.0]];
		//self.label.layer.cornerRadius = 4.0;
		//self.thumbnail.layer.masksToBounds = YES;
		//self.thumbnail.layer.borderColor = [UIColor lightGrayColor].CGColor;
		//self.thumbnail.layer.borderWidth = 1.0;
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

@end
