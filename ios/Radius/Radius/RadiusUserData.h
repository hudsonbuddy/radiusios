//
//  RadiusUserData.h
//  radius
//
//  Created by Hud on 12/12/12.
//
//

#import <Foundation/Foundation.h>

@interface RadiusUserData : NSObject {
    
    
}

@property (strong, nonatomic) NSMutableArray *followedBeacons;
@property (strong, nonatomic) NSMutableArray *recentActivity;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableDictionary *asyncImageCache;




+ (RadiusUserData *) sharedRadiusUserData;
+ (void) resetRadiusUserData;

@end
