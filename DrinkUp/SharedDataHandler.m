//
//  SharedDataHandler.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UAPush.h>
#import "SharedDataHandler.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "User.h"
#import "JSONKit.h"

@interface SharedDataHandler ()
@property (nonatomic, strong) NSString *csrfToken;
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
        _isUserAuthenticated = NO;
        
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

-(void)setupSharedVariables
{
    self.userCard = nil;
    self.userInformation = [[NSMutableDictionary alloc] init];
    self.currentDrinkOrder = [[NSMutableArray alloc] init];
    self.marketplace = @"/v1/marketplaces/TEST-MP2TVu9e2qymz5T2C1RdEdPs";
}

-(void)loadUserLocation {
    
    //    CGFloat latitude = 23.994456;
    //    CGFloat longitude = 23.994456;
    
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NSLog(@"current location in loadUserLocation: %@", location);
    
    float longitude=coordinate.longitude;
    float latitude=coordinate.latitude;
    
    NSString *locationPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/user/location/?lat=%f&long=%f", latitude, longitude];

    [self JSONWithPath:locationPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        NSLog(@"location: %@", JSON);
        self.user_location = [JSON objectAtIndex:0];
    }];
}

-(void)loadBarsWithLocation:(ObjectsCompletionBlock)completionBlock {
    
//    CGFloat latitude = 23.994456;
//    CGFloat longitude = 23.994456;
    
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NSLog(@"current location: %@", location);
    
    float longitude=coordinate.longitude;
    float latitude=coordinate.latitude;
    float radius = 3.0;
    
//    NSString *barsPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/venues/nearby/?lat=%f&long=%f&radius=%f", latitude, longitude, radius];
    NSString *barsPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/venues/all/"];
    NSLog(@"bars path: %@", barsPath);
    [self JSONWithPath:barsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        
        NSMutableArray *bars = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        NSLog(@"JSON: %@", JSON);
        for (NSMutableDictionary *bar in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[bar objectForKey:@"fields"]];
            [tempDict setObject:[bar objectForKey:@"pk"] forKey:@"id"];
            [bars addObject:tempDict];
        }
        NSLog(@"bars: %@", bars);
        completionBlock(bars);
    }];
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
    [self JSONWithPath:barSectionsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
    {
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

#pragma mark - Primary JSON call and Certificate validation
- (void)JSONWithPath:(NSString *)requestPath onCompletion:(JsonRequestCompletionBlock)completionBlock {
    
    NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        completionBlock(request, response, JSON, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        completionBlock(request, response, JSON, error);
    }];
    
    [self checkOperationCertificate:operation];
    [self.queue addOperation:operation];
}

-(void)checkOperationCertificate:(AFHTTPRequestOperation *)operation {
    [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace)
    {
        SecTrustRef trust = [protectionSpace serverTrust];
        
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(trust, 0);
        
        NSData* ServerCertificateData = (__bridge NSData*) SecCertificateCopyData(certificate);
        
        // Check if the certificate returned from the server is identical to the saved certificate in
        // the main bundle
        BOOL areCertificatesEqual = ([ServerCertificateData
                                      isEqualToData:[self getCertificate]]);
        
        if (!areCertificatesEqual)
        {
            NSLog(@"Bad Certificate, canceling request");
            [connection cancel];
        } else {
            NSLog(@"Good Certificate, continue request");
        }
        
        // If the certificates are not equal we should not talk to the server;
        return areCertificatesEqual;
    }];
}

-(NSData *)getCertificate
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DrinkUp-App.com" ofType:@"der"];
    NSData *derdata = [NSData dataWithContentsOfFile:path];
    return derdata;
}

#pragma mark - User API Functions

-(void)getEmptyCSRFToken:(JsonRequestCompletionBlock)completionBlock {
    NSString *tokenPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/token/"];
    [self JSONWithPath:tokenPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        NSDictionary *headers = [response allHeaderFields];
        NSString *fullTokenString = [[[headers objectForKey:@"Set-Cookie"] componentsSeparatedByString:@";"] objectAtIndex:0];
        NSString *tokenString = [fullTokenString substringFromIndex:[fullTokenString rangeOfString:@"="].location + 1];
        
        self.csrfToken = tokenString;
        completionBlock(request, response, JSON, error);
    }];
}

-(void)userLoginToServerWithCredentials:(NSMutableDictionary *)credentials andCompletion:(SuccessCompletionBlock)successBlock {
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLoginToServerWithCredentials:credentials andCompletion:successBlock];
        }];
        
    } else {
        
        [credentials setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/login/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:credentials];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", [responseObject objectAtIndex:0]);
//            self.userInformation = [[NSMutableDictionary alloc] initWithDictionary:[responseObject objectAtIndex:0]];
            NSLog(@"username: %@", [[[responseObject objectAtIndex:0] objectForKey:@"fields" ] objectForKey:@"username"]);
            [self.userInformation setObject:[[[responseObject objectAtIndex:0] objectForKey:@"fields" ] objectForKey:@"username"] forKey:@"username"];
            
            NSString *ua_username;
            if ([[[responseObject objectAtIndex:0] objectForKey:@"fields"] objectForKey:@"user"]) {
                ua_username = [NSString stringWithFormat:@"appuser%i", [[[[responseObject objectAtIndex:0] objectForKey:@"user"] objectForKey:@"pk"] intValue]];
            } else {
                ua_username = [NSString stringWithFormat:@"appuser%i", [[[responseObject objectAtIndex:0] objectForKey:@"pk"] intValue]];
                
            }
            [self.userInformation setObject:ua_username forKey:@"ua_username"];
            [self userIsAuthenticated:^(bool successful)
            {
//                NSLog(@"setting push enabled");
//                [[UAPush shared] setPushEnabled:YES];
                NSLog(@"ua_username: %@", [self userInformation]);
                [[UAPush shared] setAlias:[[self userInformation] objectForKey:@"ua_username"]];
                [[UAPush shared] updateRegistration];
                [self userCurrentCardInfo];
                successBlock(successful);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
            [self userIsAuthenticated:successBlock];
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userLogoutOfServer:(SuccessCompletionBlock)successBlock {

    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLogoutOfServer:successBlock];
        }];
        
    } else {
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/logout/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:@{@"csrfmiddlewaretoken": self.csrfToken}];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
    
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", operation.responseString);
            [self userIsAuthenticated:nil];
            successBlock(YES);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userCreateOnServer:(NSMutableDictionary *)userDictionary withSuccess:(SuccessCompletionBlock)successBlock {
    
    NSLog(@"create user on serer started");
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userCreateOnServer:userDictionary withSuccess:successBlock];
        }];
        
    } else {
        [userDictionary setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/create/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:userDictionary];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", operation.responseString);
            
            NSString *ua_username;
            if ([[[responseObject objectAtIndex:0] objectForKey:@"fields"] objectForKey:@"user"]) {
                ua_username = [NSString stringWithFormat:@"appuser%i", [[[[responseObject objectAtIndex:0] objectForKey:@"user"] objectForKey:@"pk"] intValue]];
            } else {
                ua_username = [NSString stringWithFormat:@"appuser%i", [[[responseObject objectAtIndex:0] objectForKey:@"pk"] intValue]];
                
            }
            [self.userInformation setObject:ua_username forKey:@"ua_username"];
            [self userIsAuthenticated:^(bool successful)
             {
                 //                NSLog(@"setting push enabled");
                 //                [[UAPush shared] setPushEnabled:YES];
                 NSLog(@"ua_username: %@", [self userInformation]);
                 [[UAPush shared] setAlias:[[self userInformation] objectForKey:@"ua_username"]];
                 [[UAPush shared] updateRegistration];
                 [self userCurrentCardInfo];
                 successBlock(successful);
             }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"error: %@", [operation.responseData objectFromJSONData]);
            if ([[[operation.responseData objectFromJSONData] objectForKey:@"status"] isEqualToString:@"duplicate user"])
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Username Taken"
                                                                  message:@"Oh no! Someone is already using that username. Please try a different username."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
                [message show];
            } else if ([[[operation.responseData objectFromJSONData] objectForKey:@"status"] isEqualToString:@"duplicate email"])
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Email Registered"
                                                                  message:@"This email is already registered in our system. If you believe this is a mistake, please let us know and we will investigate it immediately."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
                [message show];
            }
            successBlock(NO);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userIsAuthenticated:(SuccessCompletionBlock)successBlock
{
    NSString *authPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/user/authenticated/"];
    [self JSONWithPath:authPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        if (!error)
        {
            self.isUserAuthenticated = YES;
            NSLog(@"no error!");
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UserAuthorized"
             object:self];
            
        }
        else {
            self.isUserAuthenticated = NO;
            NSLog(@"error returned");
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UserDeauthorized"
             object:self];
        }
        
        if (successBlock) {
            successBlock(self.isUserAuthenticated);
        }
        NSLog(@"Check User Authenticated: %@", JSON);
    }];
}

-(void)userUpdateCardInfo:(NSMutableDictionary *)cardResponse
{
    NSLog(@"card information: %@", cardResponse);
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userUpdateCardInfo:cardResponse];
        }];
        
    } else {
        [cardResponse setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/update_card/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:cardResponse];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"cc update operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"cc response string: %@ ", operation.responseString);
            [self userIsAuthenticated:nil];
            //            [[SharedDataHandler sharedInstance].currentDrinkOrder removeAllObjects];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"cc update error: %@", operation.responseString);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userCurrentCardInfo
{
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userCurrentCardInfo];
        }];
    } else {
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/valid_card/";
        [self JSONWithPath:requestPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
        {
            NSLog(@"user card returned: %@", JSON);
            NSLog(@"respponse: %@", response);
            NSLog(@"error: %@", error);
            self.userCard = [NSMutableDictionary dictionaryWithDictionary:JSON];
        }];
    }
}

-(void)userInvalidateCurrentCard:(SuccessCompletionBlock)successBlock
{
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userInvalidateCurrentCard:successBlock];
        }];
    } else {
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/invalidate_card/";
        [self JSONWithPath:requestPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
         {
             NSLog(@"respponse: %@", response);
             NSLog(@"error: %@", error);
             if (!error)
             {
                 self.userCard = nil;
                 successBlock(YES);
             }
         }];
    }
}

-(void)userUpdateProfilePicture:(NSURL *)imageURL withSuccess:(SuccessCompletionBlock)successBlock
{
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userUpdateProfilePicture:imageURL withSuccess:successBlock];
        }];
    } else {
        NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
        [sendDict setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        [sendDict setObject:imageURL forKey:@"pictureURL"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/update_picture/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:sendDict];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"profile pic operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
             NSLog(@"user profile pic response object: %@", [responseObject objectFromJSONData]);
             successBlock(YES);
         }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"user update profile pic error: %@", operation.responseString);
             successBlock(NO);
         }];
        
        [self.queue addOperation:operation];
    }
}

#pragma mark - Order API Functions
-(void)placeOrder:(NSMutableDictionary *)order withSuccess:(SuccessCompletionBlock)successBlock
{
    NSLog(@"place order data handler with order: %@", order);
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self placeOrder:order withSuccess:successBlock];
        }];
        
    } else {
        [order setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/orders/create/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        id orderJSON = [[order objectForKey:@"drinks"] JSONString];
        [order setObject:orderJSON forKey:@"drinks"];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:order];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
//            NSLog(@"response string: %@ ", [operation.responseString objectFromJSONString]);
            NSLog(@"response object: %@", [responseObject objectFromJSONData]);
            self.currentOrderID = [NSString stringWithFormat:@"%i", [[[[responseObject objectFromJSONData] objectAtIndex:0] objectForKey:@"pk"] intValue]];
            NSLog(@"current id: %@", self.currentOrderID);
            [self userIsAuthenticated:nil];
            successBlock(YES);
//            [[SharedDataHandler sharedInstance].currentDrinkOrder removeAllObjects];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"error: %@", operation.responseString);
            successBlock(NO);
        }];
        
        [self.queue addOperation:operation];
    }
}

#pragma mark - Facebook Methods

-(Facebook *)facebookInstance {
    return self.facebook;
}

-(void)initializeFacebook {
    
    self.facebook = [[Facebook alloc] initWithAppId:@"428379253908650" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"])
    {
        NSLog(@"getting user from defaults");
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        
        [self.facebook extendAccessTokenIfNeeded];
    }
}

-(void)authorizeFacebook {
    
    if (!self.facebook) {
        [self initializeFacebook];
    }
    
    NSLog(@"Authorize Method Valid Check: %i", [self.facebook isSessionValid]);
    
    if (![self.facebook isSessionValid])
    {
        NSLog(@"asking permissions");
        // CANNOT INITIALLY ASK FOR PUBLISH STREAM PERMISSIONS WHEN SIGNING UP USER
        // NEED TO MOVE THIS TO WHEN IT WILL ACTUALLY BE USED
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"user_birthday",
                                @"publish_stream",
                                nil];
        [self.facebook authorize:permissions];
    } else {
        NSLog(@"not asking permissions");
        // this method also logs into server
        [self fbGetUserInfo];
    }
}

-(void)fbGetUserInfo {
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)fbDidLogin {
    
    NSLog(@"Facebook: %@", self.facebook);
    NSLog(@"Facebook Token: %@", [self.facebook accessToken]);
    NSLog(@"Facebook Session: %i", [self.facebook isSessionValid]);
    
    if (![self.facebook isSessionValid]) {
        [self authorizeFacebook];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self fbGetUserInfo];
}

-(void)userLoginFacebookOnServer:(NSMutableDictionary *)userFacebookInfo withSuccess:(SuccessCompletionBlock)successBlock {
    
    NSLog(@"Facebook to Server");
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLoginFacebookOnServer:userFacebookInfo withSuccess:successBlock];
        }];
        
    } else {
        
        NSLog(@"Inside Facebook to Server");
        
        [userFacebookInfo setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/facebook/mobile_login/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:userFacebookInfo];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", operation.responseString);
            id objectP = [operation.responseString objectFromJSONString];
            NSLog(@"Actual response object: %@", [[responseObject objectFromJSONData] objectAtIndex:0]);
            NSLog(@"parsed object: %@", objectP);
//            [self.userInformation setValuesForKeysWithDictionary:[[responseObject objectFromJSONData] objectAtIndex:0]];
            [self userIsAuthenticated:^(bool successful)
            {
                NSString *ua_username = [NSString stringWithFormat:@"appuser%i", [[[[[[responseObject objectFromJSONData] objectAtIndex:0] objectForKey:@"fields"] objectForKey:@"user"] objectForKey:@"pk"] intValue]];
                [self.userInformation setObject:ua_username forKey:@"ua_username"];
                [[UAPush shared] setAlias:[[self userInformation] objectForKey:@"ua_username"]];
                [[UAPush shared] updateRegistration];
                [self userCurrentCardInfo];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"FacebookServerLoginAuthorized"
                 object:self];
                
                successBlock(YES);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
            [self.userInformation removeAllObjects];
            [self userIsAuthenticated:nil];
            successBlock(NO);
        }];
        
        [self.queue addOperation:operation];
    }
}

- (void) fbDidLogout {
    
    NSLog(@"Facebook did logout");
    
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self.facebook setAccessToken:accessToken];
    [self.facebook setExpirationDate:expiresAt];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed with error: %@", [error localizedDescription]);
    
    if ([[request graphPath] isEqualToString:@"me"]) {
        NSLog(@"failed me check");
        NSLog(@"asking permissions");
        // CANNOT INITIALLY ASK FOR PUBLISH STREAM PERMISSIONS WHEN SIGNING UP USER
        // NEED TO MOVE THIS TO WHEN IT WILL ACTUALLY BE USED
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"user_birthday",
                                @"publish_stream",
                                nil];
        [self.facebook authorize:permissions];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
    
    if ([[request graphPath] isEqualToString:@"me"]) {
        NSLog(@"Me Path");
        
        NSMutableDictionary *userFacebookInfo = [[NSMutableDictionary alloc] init];
        
        [userFacebookInfo setObject:[result objectForKey:@"id"] forKey:@"fb_user_id"];
        [userFacebookInfo setObject:[result objectForKey:@"email"] forKey:@"fb_user_email"];
        
        [userFacebookInfo setObject:[self.facebook accessToken] forKey:@"oauth_token"];
        [userFacebookInfo setObject:[NSNumber numberWithFloat:[[self.facebook expirationDate] timeIntervalSince1970]] forKey:@"expiration"];
        [userFacebookInfo setObject:[NSNumber numberWithFloat:[[NSDate date]timeIntervalSince1970]] forKey:@"created"];
        
        self.userInformation = [[NSMutableDictionary alloc] init];
        [self.userInformation setObject:[result objectForKey:@"id"] forKey:@"fb_id"];
        [self.userInformation setObject:[result objectForKey:@"username"] forKey:@"fb_username"];
        [self.userInformation setObject:[result objectForKey:@"first_name"] forKey:@"fb_firstname"];
        
        [self userLoginFacebookOnServer:userFacebookInfo withSuccess:^(bool successful) {
        }];
    }
    
    NSLog(@"Request Made: %@", [request graphPath]);
	NSLog(@"Result of API call: \n%@", result);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    [self loadUserLocation];
//    [self loadBarsWithLocation:^(NSMutableArray *objects) {}];
}

@end
