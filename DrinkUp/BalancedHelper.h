//
//  BalancedHelper.h
//  DrinkUp
//
//  Created by Kinetic on 5/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPHCard.h"

@interface BalancedHelper : NSObject {
@private
    NSString *marketplaceURI;
}

- (id)initWithMarketplaceURI:(NSString *)uri;

- (NSDictionary *)tokenizeCard:(BPHCard *)card error:(NSError **)error;
//- (NSDictionary *)tokenizeBankAccount:(BPBankAccount *)bankAccount error:(NSError **)error;

@end
