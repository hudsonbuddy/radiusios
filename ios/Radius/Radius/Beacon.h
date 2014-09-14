//
//  Beacon.h
//  Radius
//
//  Created by Hudson Duan on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Beacon : NSObject {
    


}

@property (nonatomic, strong) NSString * beaconname;
@property (nonatomic, strong) NSString * beacontextcontent;
@property (nonatomic, strong) NSString * beaconlocation;
@property (nonatomic, strong) NSString * beaconcenterlat;
@property (nonatomic, strong) NSString * beaconcenterlong;
@property (nonatomic, strong) NSString * beaconspanlat;
@property (nonatomic, strong) NSString * beaconspanlong;
@property (nonatomic, strong) NSString * beaconimage;
@property (nonatomic, strong) NSNumber * beaconRadius;
@property (nonatomic, strong) NSNumber * beaconID;
@property (nonatomic, strong) NSDictionary *beaconDictionary;


@end
