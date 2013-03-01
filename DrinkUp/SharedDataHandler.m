//
//  SharedDataHandler.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "SharedDataHandler.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"

@interface SharedDataHandler ()
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *currentDrinkOrder;

@property (nonatomic, strong) Facebook *facebook;
@end

@implementation SharedDataHandler

static id _instance;

-(id)init {
    
    if(!_instance)
    {
        self = [super init];
        _instance = self;
        _queue = [[NSOperationQueue alloc] init];
    }
    
    return _instance;
}

+(SharedDataHandler *)sharedInstance {
    
    if (_instance)
        return _instance;
    else
        return [[self alloc] init];
}

-(void)setupLocationTracking {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

-(void)loadBars:(ObjectsCompletionBlock)completionBlock {
    
    NSString *barsPath = @"http://drink-up.appspot.com/bar?api_key=Pass1234&zipcode=24060";
    [self JSONWithPath:barsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        NSMutableArray *bars = [[NSMutableArray alloc] init];
        for (NSDictionary *bar in [JSON objectForKey:@"bars"]) {
            [bars addObject:bar];
        }
        completionBlock(bars);
    }];
}

-(void)loadDrinkTypesForBar:(NSString *)barEmail onCompletion:(ObjectsCompletionBlock)completionBlock {
    
//    NSString *drinksPath = @"http://drink-up.appspot.com/bar?api_key=Pass1234&zipcode=24060";
//    [self JSONWithPath:drinksPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
//        self.drinkTypes = [[NSMutableArray alloc] init];
//        for (NSDictionary *bar in [JSON objectForKey:@"types"]) {
//            [self.drinkTypes addObject:bar];
//        }
//        completionBlock(self.drinkTypes);
//    }];

    NSDictionary *beer = @{@"name": @"beer"};
    NSDictionary *liquor = @{@"name": @"liquor"};
    NSDictionary *wine = @{@"name": @"wine"};
    
    NSMutableArray *drinkTypes = [NSMutableArray arrayWithArray: @[beer, liquor, wine]];
    completionBlock(drinkTypes);
    
}

-(void)loadDrinksForBar:(NSString *)barEmail onCompletion:(ObjectsCompletionBlock)completionBlock {
    
    //    NSString *drinksPath = @"http://drink-up.appspot.com/bar?api_key=Pass1234&zipcode=24060";
    //    [self JSONWithPath:drinksPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
    //        self.drinkTypes = [[NSMutableArray alloc] init];
    //        for (NSDictionary *bar in [JSON objectForKey:@"types"]) {
    //            [self.drinkTypes addObject:bar];
    //        }
    //        completionBlock(self.drinkTypes);
    //    }];
    
    NSDictionary *drink1 = @{@"name": @"Sam Lite", @"price": @"5.50", @"quantity":@0};
    NSDictionary *drink2 = @{@"name": @"Budweiser", @"price": @"7.00", @"quantity":@0};
    NSDictionary *drink3 = @{@"name": @"Corona", @"price": @"6.00", @"quantity":@0};
    
    NSMutableArray *barDrinks = [NSMutableArray arrayWithArray: @[drink1, drink2, drink3]];
    completionBlock(barDrinks);
    
}

- (void)JSONWithPath:(NSString *)requestPath onCompletion:(JsonRequestCompletionBlock)completionBlock {
    
    NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        completionBlock(request, response, JSON, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionBlock(request, response, JSON, error);
    }];
    
    [self.queue addOperation:operation];
}

#pragma mark - Drink Ordering

-(NSMutableArray *)getCurrentOrder {
    return self.currentDrinkOrder;
}

-(void)addDrinksToCurrentOrder:(NSMutableArray *)newDrinks {
    
    for (NSDictionary *drink in newDrinks) {
        for (NSDictionary *orderedDrink in self.currentDrinkOrder) {
            if ([[drink objectForKey:@"name"] isEqualToString:[orderedDrink objectForKey:@"name"]]) {
            }
        }
    }
    
    [self.currentDrinkOrder addObjectsFromArray:newDrinks];
}

-(void)removeDrinksFromCurrentOrder:(NSMutableArray *)removeDrinks {
    [self.currentDrinkOrder removeObjectsInArray:removeDrinks];
}

-(void)clearCurrentDrinkOrder {
    [self.currentDrinkOrder removeAllObjects];
}

#pragma mark - Facebook Methods

-(Facebook *)facebookInstance {
    return self.facebook;
}

-(void)initializeFacebook {
    self.facebook = [[Facebook alloc] initWithAppId:@"428379253908650" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.facebook isSessionValid])
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                //@"user_likes",
                                @"read_stream",
                                @"publish_stream",
                                nil];
        [self.facebook authorize:permissions];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed with error: %@", [error localizedDescription]);
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	NSLog(@"Result of API call: \n%@", result);
}

- (void)fbDidLogin {
    
    NSLog(@"HIT FB LOGIN");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
//START TEST
    NSString *requestPath = @"http://ec2-174-129-129-68.compute-1.amazonaws.com/Project/facebook_login/mobile/";
    NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSError * error = nil;
    
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] init];
    [sendDic setObject:[self.facebook accessToken] forKey:@"oauth_token"];
    [sendDic setObject:[NSNumber numberWithFloat:[[self.facebook expirationDate] timeIntervalSince1970]] forKey:@"expiration"];
    [sendDic setObject:[NSNumber numberWithFloat:[[NSDate date]timeIntervalSince1970]] forKey:@"created"];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:sendDic];
    [ request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        NSLog(@"response string: %@ ", operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request2 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"COMPLETED FB CALL: %@", JSON);
////        completionBlock(request, response, JSON, nil);
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
////        completionBlock(request, response, JSON, error);
//        NSLog(@"ERROR FB: %@", error);
//    }];
    [self.queue addOperation:operation];
}

- (void) fbDidLogout {
    
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}
@end
