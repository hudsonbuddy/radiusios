//
//  JSONSerializable.h
//  Radius
//
//  Created by Hud on 7/19/12.
//
//

#import <Foundation/Foundation.h>

@protocol JSONSerializable <NSObject>

-(void) readFromJSONDictionary: (NSDictionary *) d;

@end
