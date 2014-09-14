//
//  RDSDataStore.m
//  Radius
//
//  Created by Hud on 7/19/12.
//
//

#import "RDSDataStore.h"

@implementation RDSDataStore

+ (RDSDataStore *) sharedStore
{
    static RDSDataStore * feedStore = nil;
    if (!feedStore) {
        feedStore = [[RDSDataStore alloc] init];
    }
}

@end
