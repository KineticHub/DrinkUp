//
//  BalancedHelper.m
//  DrinkUp
//
//  Created by Kinetic on 5/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BalancedHelper.h"
#import "BPHUtils.h"

#define API_URL @"https://js.balancedpayments.com"

@implementation BalancedHelper
- (id)initWithMarketplaceURI:(NSString *)uri {
    self = [super init];
    if (self) {
        marketplaceURI = uri;
    }
    return self;
}

- (NSDictionary *)tokenizeCard:(BPHCard *)card error:(NSError **)error {
    NSError *tokenizeError;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/cards", API_URL, marketplaceURI]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLResponse *response;
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"application/json", @"accept",
                             @"application/x-www-form-urlencoded charset=utf-8", @"Content-Type",
                             [BPHUtils userAgentString], @"User-Agent", nil];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    NSMutableDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [card number], @"card_number",
                                   [card expirationMonth], @"expiration_month",
                                   [card expirationYear], @"expiration_year",
                                   [NSNumber numberWithInt:[BPHUtils getTimezoneOffset]], @"system_timezone",
                                   [[[NSLocale currentLocale] localeIdentifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"], @"language",
                                   nil];
    NSString *requestBody = [BPHUtils queryStringFromParameters:params];
    if ([card optionalFields] != NULL && [[card optionalFields] count] > 0) {
        requestBody = [requestBody stringByAppendingString:[BPHUtils queryStringFromParameters:[card optionalFields]]];
    }
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&tokenizeError];
    
    if (tokenizeError == nil) {
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&tokenizeError];
        if (tokenizeError == nil) {
            return responseJSON;
        }
        *error = tokenizeError;
        return nil;
    }
    else {
        *error = tokenizeError;
    }
    
    return nil;
}


//- (NSDictionary *)tokenizeBankAccount:(BPBankAccount *)bankAccount error:(NSError **)error {
//    NSError *tokenizeError;
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/bank_accounts", API_URL, marketplaceURI]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSURLResponse *response;
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"application/json", @"accept",
//                             @"application/x-www-form-urlencoded charset=utf-8", @"Content-Type",
//                             [BPUtilities userAgentString], @"User-Agent", nil];
//    [request setHTTPMethod:@"POST"];
//    [request setAllHTTPHeaderFields:headers];
//    NSMutableDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [bankAccount routingNumber], @"routing_number",
//                                   [bankAccount accountNumber], @"account_number",
//                                   [bankAccount accountType], @"type",
//                                   [bankAccount name], @"name",
//                                   [NSNumber numberWithInt:[BPUtilities getTimezoneOffset]], @"system_timezone",
//                                   [[[NSLocale currentLocale] localeIdentifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"], @"language",
//                                   nil];
//    NSString *requestBody = [BPUtilities queryStringFromParameters:params];
//    if ([bankAccount optionalFields] != NULL && [[bankAccount optionalFields] count] > 0) {
//        requestBody = [requestBody stringByAppendingString:[BPUtilities queryStringFromParameters:[bankAccount optionalFields]]];
//    }
//    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&tokenizeError];
//    
//    if (tokenizeError == nil) {
//        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&tokenizeError];
//        if (tokenizeError == nil) {
//            return responseJSON;
//        }
//        *error = tokenizeError;
//        return nil;
//    }
//    else {
//        *error = tokenizeError;
//    }
//    
//    return nil;
//}
@end
