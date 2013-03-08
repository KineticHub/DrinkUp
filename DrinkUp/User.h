//
//  User.h
//  DrinkUp
//
//  Created by Kinetic on 3/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property int userId;
@property (nonatomic, strong) NSDictionary *userProfile;
@property (nonatomic, strong) NSMutableArray *userCards;
@property (nonatomic, strong) NSDictionary *userDefaultCard;

-(bool)isLoggedIn;

@end
