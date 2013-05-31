//
//  BPHCard.h
//  DrinkUp
//
//  Created by Kinetic on 5/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPHCard : NSObject
{
    @private
    NSUInteger expirationMonth;
    NSUInteger expirationYear;
    NSString *securityCode;
    NSString *number;
    NSDictionary *optionalFields;
}

- (id)initWithNumber:(NSString *)cardNumber
  andExperationMonth:(NSString *)expMonth
   andExperationYear:(NSString *)expYear
     andSecurityCode:(NSString *)code;

- (id)initWithNumber:(NSString *)cardNumber
  andExperationMonth:(NSString *)expMonth
   andExperationYear:(NSString *)expYear
     andSecurityCode:(NSString *)code
   andOptionalFields:(NSDictionary *)optParams;

- (NSString *)number;
- (NSString *)expirationMonth;
- (NSString *)expirationYear;
- (NSString *)type;
- (NSDictionary *)optionalFields;
- (BOOL)valid;
- (BOOL)numberValid;
- (BOOL)securityCodeValid;
- (BOOL)expired;

@property (nonatomic, strong) NSMutableArray *errors;
@end
