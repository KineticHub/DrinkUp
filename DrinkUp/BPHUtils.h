//
//  BPHUtils.h
//  DrinkUp
//
//  Created by Kinetic on 5/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPHUtils : NSObject
+ (NSString *)queryStringFromParameters:(NSDictionary *)params;
+ (int)getTimezoneOffset;
+ (NSString *)getMACAddress;
+ (NSString *)getIPAddress;
+ (NSString *)userAgentString;
@end
