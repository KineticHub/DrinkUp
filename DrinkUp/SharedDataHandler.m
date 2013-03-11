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
#import "User.h"

@interface SharedDataHandler ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) User *currentUser;
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
        
        [self setupSharedVariables];
    }
    
    return _instance;
}

+(SharedDataHandler *)sharedInstance {
    
    if (_instance)
        return _instance;
    else
        return [[self alloc] init];
}

-(void)initializeLocationTracking {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

-(void)setupSharedVariables {
    
    self.currentDrinkOrder = [[NSMutableArray alloc] init];
}

-(void)loadBars:(ObjectsCompletionBlock)completionBlock {
    
    NSString *barsPath = @"https://DrinkUp-App.com/api/venues/all/";
    [self JSONWithPath:barsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        
        NSMutableArray *bars = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        for (NSMutableDictionary *bar in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[bar objectForKey:@"fields"]];
            [tempDict setObject:[bar objectForKey:@"pk"] forKey:@"id"];
            [bars addObject:tempDict];
        }
        NSLog(@"bars: %@", bars);
        completionBlock(bars);
    }];
}

-(void)loadBarSectionsForBar:(int)bar_id onCompletion:(ObjectsCompletionBlock)completionBlock {
    
    NSString *barSectionsPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/venues/bars/%i/", bar_id];
    NSLog(@"Path: %@", barSectionsPath);
    [self JSONWithPath:barSectionsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        
        NSMutableArray *barSections = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        for (NSDictionary *barSection in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[barSection objectForKey:@"fields"]];
            [tempDict setObject:[barSection objectForKey:@"pk"] forKey:@"id"];
            [barSections addObject:tempDict];
        }
        NSLog(@"bar sections: %@", barSections);
        completionBlock(barSections);
    }];
}

-(void)loadDrinkTypesForBarSection:(int)section_id onCompletion:(ObjectsCompletionBlock)completionBlock {
    
    NSString *drinkTypesPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/venues/bars/drinks/types/%i/", section_id];
    [self JSONWithPath:drinkTypesPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        
        NSMutableArray *drinkTypes = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        for (NSDictionary *drinkType in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[drinkType objectForKey:@"fields"]];
            [tempDict setObject:[drinkType objectForKey:@"pk"] forKey:@"id"];
            [drinkTypes addObject:tempDict];
        }
        NSLog(@"types: %@", tempDict);
        completionBlock(drinkTypes);
    }];
    
}

-(void)loadDrinksForSection:(int)section_id withType:(int)type_id onCompletion:(ObjectsCompletionBlock)completionBlock {
    
    NSString *drinksPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/venues/bars/drinks/%i/%i/", section_id, type_id];
    [self JSONWithPath:drinksPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        
        NSMutableArray *drinks = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        for (NSDictionary *drink in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[drink objectForKey:@"fields"]];
            [tempDict setObject:[drink objectForKey:@"pk"] forKey:@"id"];
            [tempDict setObject:@0 forKey:@"quantity"];
            [drinks addObject:tempDict];
        }
        NSLog(@"drinks: %@", tempDict);
        completionBlock(drinks);
    }];
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

#pragma mark - Server Login
-(void)loginToServerWithCredentials:(NSDictionary *)credentials {
    
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
}

-(void)authorizeFacebook {
    if (![self.facebook isSessionValid])
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"publish_stream",
                                nil];
        [self.facebook authorize:permissions];
    }
}

-(void)fbGetUserInfo {
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)fbDidLogin {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self fbGetUserInfo];
}
    
////START TEST
//    NSString *requestPath = @"https://DrinkUp-App.com/api/facebook_login/mobile/";
//    NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSError * error = nil;
//    
//    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] init];
//    [sendDic setObject:[self.facebook accessToken] forKey:@"oauth_token"];
//    [sendDic setObject:[NSNumber numberWithFloat:[[self.facebook expirationDate] timeIntervalSince1970]] forKey:@"expiration"];
//    [sendDic setObject:[NSNumber numberWithFloat:[[NSDate date]timeIntervalSince1970]] forKey:@"created"];
//    
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
//    
//    NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:sendDic];
//    [ request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
//
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
//        
//        NSLog(@"response string: %@ ", operation.responseString);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"error: %@", operation.responseString);
//        
//    }];
//    
////    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request2 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
////        NSLog(@"COMPLETED FB CALL: %@", JSON);
//////        completionBlock(request, response, JSON, nil);
////    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//////        completionBlock(request, response, JSON, error);
////        NSLog(@"ERROR FB: %@", error);
////    }];
//    [self.queue addOperation:operation];

- (void) fbDidLogout {
    
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
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

@end
