//
//  UploadProgress.h
//  radius
//
//  Created by David Herzka on 8/17/12.
//
//

#import <UIKit/UIKit.h>

@interface RadiusProgressView : UIView

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (strong, nonatomic) IBOutlet UIView *justTheProgressViewAndLabel;

@end
