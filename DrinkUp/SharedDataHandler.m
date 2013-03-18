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
@property (nonatomic, strong) NSString *csrfToken;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) Facebook *facebook;
@property bool isUserAuthenticated;
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

-(void)userLoginToServerWithCredentials:(NSMutableDictionary *)credentials {
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLoginToServerWithCredentials:credentials];
        }];
        
    } else {
        
        [credentials setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/api/user/login/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:credentials];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", operation.responseString);
            [self userIsUthenticated];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
            [self userIsUthenticated];
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userLogoutOfServer {

    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLogoutOfServer];
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
            [self userIsUthenticated];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userCreateOnServer:(NSMutableDictionary *)userDictionary {
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userCreateOnServer:userDictionary];
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
            [self userIsUthenticated];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userIsUthenticated {
    NSString *authPath = [NSString stringWithFormat:@"https://DrinkUp-App.com/api/user/authenticated/"];
    [self JSONWithPath:authPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        if (!error) {
            self.isUserAuthenticated = YES;
            NSLog(@"no error!");
        }
        else {
            self.isUserAuthenticated = NO;
            NSLog(@"error returned");
        }
        NSLog(@"Check User Authenticated: %@", JSON);
    }];
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
    
    if (!self.facebook) {
        [self initializeFacebook];
    }
    
    NSLog(@"Authorize Method Valid Check: %i", [self.facebook isSessionValid]);
    
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

-(void)userLoginFacebookOnServer:(NSMutableDictionary *)userFaebookInfo {
    
    NSLog(@"Facebook to Server");
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLoginFacebookOnServer:userFaebookInfo];
        }];
        
    } else {
        
        NSLog(@"Inside Facebook to Server");
        
        [userFaebookInfo setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = @"https://DrinkUp-App.com/facebook/mobile_login/";
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:userFaebookInfo];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:@"https://drinkup-app.com/" forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", operation.responseString);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
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
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
    
    if ([[request graphPath] isEqualToString:@"me"]) {
        NSLog(@"Me Path");
        
        NSMutableDictionary *userFacebookInfo = [[NSMutableDictionary alloc] init];
        
        [userFacebookInfo setObject:[result objectForKey:@"id"] forKey:@"fb_user_id"];
        [userFacebookInfo setObject:[result objectForKey:@"id"] forKey:@"fb_user_email"];
        
        [userFacebookInfo setObject:[self.facebook accessToken] forKey:@"oauth_token"];
        [userFacebookInfo setObject:[NSNumber numberWithFloat:[[self.facebook expirationDate] timeIntervalSince1970]] forKey:@"expiration"];
        [userFacebookInfo setObject:[NSNumber numberWithFloat:[[NSDate date]timeIntervalSince1970]] forKey:@"created"];
        
        [self userLoginFacebookOnServer:userFacebookInfo];
    }
    
    NSLog(@"Request Made: %@", [request graphPath]);
	NSLog(@"Result of API call: \n%@", result);
}

@end
