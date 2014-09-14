//
//  ImageContent.m
//  Radius
//
//  Created by Fred Ehrsam on 11/8/12.
//
//

#import "ImageContent.h"
#import "BeaconDetailContentImageViewController.h"

@implementation ImageContent

-(void)initializeContentDetailsWithDictionary:(NSDictionary *)contentDetailDictionary
{
    self.url = [contentDetailDictionary objectForKey:@"url"];
    self.thumbURL = [contentDetailDictionary objectForKey:@"thumb"];
    self.width = [[contentDetailDictionary objectForKey:@"width"] floatValue];
    self.height = [[contentDetailDictionary objectForKey:@"height"] floatValue];    
}

-(UIViewController *)linkViewController
{
    // TODO: Have this return the view controller to link to
    // How do we pass in the neighboring images and beacon info?
    
//    UIStoryboard *st = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
//    BeaconDetailContentImageViewController *newViewControllerInstance = [st instantiateViewControllerWithIdentifier:@"BeaconDetailImageContentID"];
////    [newViewControllerInstance setTitle:beaconNameOutlet.text];
//    [newViewControllerInstance setImageArray:jsonArray];
//    [newViewControllerInstance setBeaconIDString:];
//    [newViewControllerInstance setBeaconNameString:[self.beaconDictionary objectForKey:@"name"]];
//    [newViewControllerInstance setContentType:@"image"];
//    [newViewControllerInstance setBeaconContentDictionary:currDictionary];
//    [newViewControllerInstance initializeBeaconContentImage];
    return nil;
}

@end
