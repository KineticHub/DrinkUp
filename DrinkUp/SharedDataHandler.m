//
//  SharedDataHandler.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UAPush.h>
#import <AWSS3/AWSS3.h>
#import "SharedDataHandler.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "User.h"
#import "JSONKit.h"
#import "CreditCardProfileViewController.h"
#import "AppDelegate.h"
#import <UAirship.h>
#import "KUIHelper.h"

@interface SharedDataHandler ()
@property (nonatomic, strong) NSString *baseURL;
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
    
#ifdef DEV
    NSLog(@"SETTING UP DEV");
    self.baseURL = @"https://54.225.126.238";
    self.marketplace = @"/v1/marketplaces/TEST-MP2TVu9e2qymz5T2C1RdEdPs";
#else
    NSLog(@"SETTING UP PROD");
    self.baseURL = @"https://DrinkUp-App.com";
    self.marketplace = @"/v1/marketplaces/MP6oQ3gotJ83HcBLJXNS6oLm";
#endif
}

#pragma mark - Save and Load Methods
- (void)saveUserInfo {
    
    NSLog(@"Saving user info: %@", [SharedDataHandler sharedInstance].userInformation);
    [[NSUserDefaults standardUserDefaults] setObject:[SharedDataHandler sharedInstance].userInformation forKey:@"userInformation"];
//    [[NSUserDefaults standardUserDefaults] setObject:[SharedDataHandler sharedInstance].userCard forKey:@"userCard"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadUserInfo {
    
    self.userInformation = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"userInformation"]];
    self.userCard = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userCard"] mutableCopy];
    
    NSLog(@"Loading user info: %@", self.userInformation);
}

#pragma mark - Bar Methods
-(bool)isBarHappyHour
{
    NSString *startTime = [self.currentBar objectForKey:@"happyhour_start"];
    NSString *endTime = [self.currentBar objectForKey:@"happyhour_end"];
    
//    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
//    [timeFormat setDateFormat:@"HH:mm:ss"];
//    NSDate *date = [timeFormat dateFromString:startTime];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    NSInteger currHr = [components hour];
    NSInteger currtMin = [components minute];
    
    int stHr = [[[startTime componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
    int stMin = [[[startTime componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    int enHr = [[[endTime componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
    int enMin = [[[endTime componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    
    int formStTime = (stHr*60)+stMin;
    int formEnTime = (enHr*60)+enMin;
    int nowTime = (currHr*60)+currtMin;
    
    NSLog(@"now time: %i", nowTime);
    NSLog(@"start time: %i", formStTime);
    NSLog(@"end time: %i", formEnTime);
    
    if(nowTime >= formStTime && nowTime <= formEnTime)
    {
        NSLog(@"currently happy hour");
        return YES;
    }
    else
    {
        NSLog(@"not happy hour");
        return NO;
    }
}

-(void)loadUserLocation {
    
    //    CGFloat latitude = 23.994456;
    //    CGFloat longitude = 23.994456;
    
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NSLog(@"current location in loadUserLocation: %@", location);
    
    float longitude=coordinate.longitude;
    float latitude=coordinate.latitude;
    
    NSString *locationPath = [NSString stringWithFormat:@"%@/api/user/location/?lat=%f&long=%f", self.baseURL, latitude, longitude];

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
    
    NSString *barsPath = [NSString stringWithFormat:@"%@/api/venues/nearby/?lat=%f&long=%f&radius=%f", self.baseURL, latitude, longitude, radius];
//    NSString *barsPath = [NSString stringWithFormat:@"DrinkUp-App.com/api/venues/all/"];
    NSLog(@"Getting bars with URL: %@", barsPath);
    NSLog(@"bars path: %@", barsPath);
    [self JSONWithPath:barsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        
        NSMutableArray *bars = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        NSLog(@"bars returned nearby: %@", JSON);
        for (NSMutableDictionary *bar in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[bar objectForKey:@"fields"]];
            [tempDict setObject:[bar objectForKey:@"pk"] forKey:@"id"];
            [bars addObject:tempDict];
        }
        completionBlock(bars);
        
        if (error) {
            NSLog(@"load bars nearby error: %@", error);
        }
    }];
}

-(void)loadBars:(ObjectsCompletionBlock)completionBlock {
    
    NSString *barsPath = [NSString stringWithFormat:@"%@/api/venues/all/", self.baseURL];
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
    
    NSString *barSectionsPath = [NSString stringWithFormat:@"%@/api/venues/bars/%i/", self.baseURL, bar_id];
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
    
    NSString *drinkTypesPath = [NSString stringWithFormat:@"%@/api/venues/bars/drinks/types/%i/", self.baseURL, section_id];
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
    
    NSString *drinksPath = [NSString stringWithFormat:@"%@/api/venues/bars/drinks/%i/%i/", self.baseURL, section_id, type_id];
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

-(void)loadDrinksForOrder:(int)order_id onCompletion:(ObjectsCompletionBlock)completionBlock
{
    NSString *drinksPath = [NSString stringWithFormat:@"%@/api/orders/drinks/?order_id=%i", self.baseURL, order_id];
    [self JSONWithPath:drinksPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
    {
        NSMutableArray *drinks = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        for (NSDictionary *drink in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[drink objectForKey:@"fields"]];
            [tempDict setObject:[drink objectForKey:@"pk"] forKey:@"id"];
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

-(void)checkOperationCertificate:(AFHTTPRequestOperation *)operation
{
    
#ifdef DEV
    NSLog(@"No Challenge");
#else
    [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace)
    {
        SecTrustRef trust = [protectionSpace serverTrust];
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(trust, 0);
        NSData* ServerCertificateData = (__bridge NSData*) SecCertificateCopyData(certificate);
        
        // Check if the certificate returned from the server is identical to the saved certificate in
        // the main bundle
        BOOL areCertificatesEqual = ([ServerCertificateData
                                      isEqualToData:[self getCertificate]]);

        // If the certificates are not equal we should not talk to the server;
        if (!areCertificatesEqual) {
            NSLog(@"Bad Certificate, canceling request");
            [connection cancel];
        } else {
            NSLog(@"Good Certificate, continue request");
        }
        
        return areCertificatesEqual;
    }];
#endif
}

-(NSData *)getCertificate
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DrinkUp-App.com" ofType:@"der"];
    NSData *derdata = [NSData dataWithContentsOfFile:path];
    return derdata;
}

//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    if ([challenge previousFailureCount] > 0) {
//        //this will cause an authentication failure
//        [[challenge sender] cancelAuthenticationChallenge:challenge];
//        NSLog(@"Bad Username Or Password");
//        return;
//    }
//    
//    //this is checking the server certificate
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        SecTrustResultType result;
//        //This takes the serverTrust object and checkes it against your keychain
//        SecTrustEvaluate(challenge.protectionSpace.serverTrust, &result);
//        
//        //if we want to ignore invalid server for certificates, we just accept the server
//        if (kSPAllowInvalidServerCertificates) {
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust] forAuthenticationChallenge: challenge];
//            return;
//        } else if(result == kSecTrustResultProceed || result == kSecTrustResultConfirm ||  result == kSecTrustResultUnspecified) {
//            //When testing this against a trusted server I got kSecTrustResultUnspecified every time. But the other two match the description of a trusted server
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust] forAuthenticationChallenge: challenge];
//            return;
//        }
//    } else if ([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodClientCertificate) {
//        //this handles authenticating the client certificate
//        
//        /*
//         What we need to do here is get the certificate and an an identity so we can do this:
//         NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:myCerts persistence:NSURLCredentialPersistencePermanent];
//         [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//         
//         It's easy to load the certificate using the code in -installCertificate
//         It's more difficult to get the identity.
//         We can get it from a .p12 file, but you need a passphrase:
//         */
//        
//        NSString *p12Path = [[NSBundle mainBundle] pathForResource:@"DrinkUp-App.com" ofType:@"der"];
//        NSData *p12Data = [[NSData alloc] initWithContentsOfFile:p12Path];
//        
//        CFStringRef password = CFSTR("PASSWORD");
//        const void *keys[] = { kSecImportExportPassphrase };
//        const void *values[] = { password };
//        CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
//        CFArrayRef p12Items;
//        
//        OSStatus result = SecPKCS12Import((__bridge CFDataRef)p12Data, optionsDictionary, &p12Items);
//        
//        if(result == noErr) {
//            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(p12Items, 0);
//            SecIdentityRef identityApp =(SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
//            
//            SecCertificateRef certRef;
//            SecIdentityCopyCertificate(identityApp, &certRef);
//            
//            SecCertificateRef certArray[1] = { certRef };
//            CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
//            CFRelease(certRef);
//            
//            NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identityApp certificates:(__bridge NSArray *)myCerts persistence:NSURLCredentialPersistencePermanent];
//            CFRelease(myCerts);
//            
//            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//        }
//    }
////    else if ([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodDefault || [[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodNTLM) {
////        // For normal authentication based on username and password. This could be NTLM or Default.
////        
////        DAVCredentials *cred = _parentSession.credentials;
////        NSURLCredential *credential = [NSURLCredential credentialWithUser:cred.username password:cred.password persistence:NSURLCredentialPersistenceForSession];
////        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
////    }
//    else {
//        //If everything fails, we cancel the challenge.
//        [[challenge sender] cancelAuthenticationChallenge:challenge];
//    }
//}

#pragma mark - User API Functions

-(void)getEmptyCSRFToken:(JsonRequestCompletionBlock)completionBlock {
//#ifdef DEV
//    self.csrfToken = @"dev";
//    completionBlock(nil, nil, nil, nil);
//#else
//    NSString *tokenPath = [NSString stringWithFormat:@"%@/api/token/", self.baseURL];
    
    NSString *requestPath = [NSString stringWithFormat:@"%@/api/token/", self.baseURL];
    NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request2 = [client requestWithMethod:@"GET" path:@"" parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"Headers: %@", [operation.response allHeaderFields]);
        NSDictionary *headers = [operation.response  allHeaderFields];
        NSString *fullTokenString = [[[headers objectForKey:@"Set-Cookie"] componentsSeparatedByString:@";"] objectAtIndex:0];
        NSString *tokenString = [fullTokenString substringFromIndex:[fullTokenString rangeOfString:@"="].location + 1];
        NSLog(@"Token string: %@", tokenString);
        self.csrfToken = tokenString;
        completionBlock(nil, responseObject, nil, nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Token call failed: %@", error);
    }];
    [self.queue addOperation:operation];
//    [self JSONWithPath:tokenPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
//        NSDictionary *headers = [response allHeaderFields];
//        NSString *fullTokenString = [[[headers objectForKey:@"Set-Cookie"] componentsSeparatedByString:@";"] objectAtIndex:0];
//        NSString *tokenString = [fullTokenString substringFromIndex:[fullTokenString rangeOfString:@"="].location + 1];
//        if (error!=NULL) {
//            NSLog(@"CSRF token error: %@", error);
//        }
//        NSLog(@"Token string: %@", tokenString);
//        self.csrfToken = tokenString;
//        completionBlock(request, response, JSON, error);
//    }];
//#endif
}

-(void)userLoginToServerWithCookieAndCompletion:(SuccessCompletionBlock)successBlock {
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLoginToServerWithCookieAndCompletion:successBlock];
        }];
        
    } else {
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/user_info/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"GET" path:@"" parameters:@{@"csrfmiddlewaretoken": self.csrfToken}];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
        AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", responseObject);
            
            [self.userInformation setObject:[[[responseObject objectAtIndex:1] objectForKey:@"fields" ] objectForKey:@"username"] forKey:@"username"];
            [self.userInformation setObject:[[[responseObject objectAtIndex:1] objectForKey:@"fields" ] objectForKey:@"email"] forKey:@"email"];
            
            NSString *ua_username = [self.userInformation objectForKey:@"username"];
            [self.userInformation setObject:ua_username forKey:@"ua_username"];
            
            if([[[[responseObject objectAtIndex:0] objectForKey:@"fields" ] objectForKey:@"profile_image_saved"] boolValue] && ![self pictureExistsLocally])
            {
                NSLog(@"saving picture locally");
                [self saveUserPictureLocally];
            }
            [self userIsAuthenticated:^(bool successful)
             {
                 NSLog(@"ua_username: %@", [self userInformation]);
                 [[UAPush shared] setAlias:[[self userInformation] objectForKey:@"ua_username"]];
                 [[UAPush shared] updateRegistration];
                 [self userCurrentCardInfo];
                 successBlock(successful);
             }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"user login to server with cookie error: %@ \n\n %@", operation.responseString, error.description);
            [self userIsAuthenticated:successBlock];
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userLoginToServerWithCredentials:(NSMutableDictionary *)credentials andCompletion:(SuccessCompletionBlock)successBlock {
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userLoginToServerWithCredentials:credentials andCompletion:successBlock];
        }];
        
    } else {
        
        [credentials setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/login/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:credentials];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
        AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", responseObject);
            
            [self.userInformation setObject:[[[responseObject objectAtIndex:1] objectForKey:@"fields" ] objectForKey:@"username"] forKey:@"username"];
            
            [self.userInformation setObject:[[[responseObject objectAtIndex:1] objectForKey:@"fields" ] objectForKey:@"email"] forKey:@"email"];
            
            NSString *ua_username = [self.userInformation objectForKey:@"username"];
//            if ([[[responseObject objectAtIndex:0] objectForKey:@"fields"] objectForKey:@"user"]) {
//                ua_username = [NSString stringWithFormat:@"appuser%i", [[[responseObject objectAtIndex:0] objectForKey:@"pk"] intValue]];
//            }
            [self.userInformation setObject:ua_username forKey:@"ua_username"];
            
            if([[[[responseObject objectAtIndex:0] objectForKey:@"fields" ] objectForKey:@"profile_image_saved"] boolValue] && ![self pictureExistsLocally])
            {
                NSLog(@"saving picture locally");
                [self saveUserPictureLocally];
            }
            [self userIsAuthenticated:^(bool successful)
            {
//                NSLog(@"setting push enabled");
//                [[UAPush shared] setPushEnabled:YES];
                NSLog(@"userinfo after authentication success: %@", [self userInformation]);
                [[UAPush shared] setAlias:[[self userInformation] objectForKey:@"ua_username"]];
                [[UAPush shared] updateRegistration];
                [self userCurrentCardInfo];
                successBlock(successful);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"user login to server error: %@", operation.responseString);
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
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/logout/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:@{@"csrfmiddlewaretoken": self.csrfToken}];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
    
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response string: %@ ", operation.responseString);
            [self userIsAuthenticated:nil];
            self.userCard = [[NSMutableDictionary alloc] init];
            self.userInformation = [[NSMutableDictionary alloc] init];
            successBlock(YES);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", operation.responseString);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userCreateOnServer:(NSMutableDictionary *)userDictionary withSuccess:(SuccessCompletionBlock)successBlock {
    
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userCreateOnServer:userDictionary withSuccess:successBlock];
        }];
    }
    else
    {
        NSLog(@"create user on server started");
        [userDictionary setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/create/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:userDictionary];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"response object user create: %@ ", [responseObject objectFromJSONData]);
            
            id responseDictionary = [[responseObject objectFromJSONData] objectAtIndex:0];
            id responseDictionary2 = [[responseObject objectFromJSONData] objectAtIndex:1];
            
            [self.userInformation setObject:[[responseDictionary2 objectForKey:@"fields" ] objectForKey:@"username"] forKey:@"username"];
            [self.userInformation setObject:[[responseDictionary2 objectForKey:@"fields" ] objectForKey:@"username"] forKey:@"ua_username"];
            [self.userInformation setObject:[[responseDictionary2 objectForKey:@"fields" ] objectForKey:@"email"] forKey:@"email"];
            
            [self userIsAuthenticated:^(bool successful)
             {
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCreatedAccount"];
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
            NSLog(@"error json: %@", [operation.responseData objectFromJSONData]);
            NSLog(@"nserror: %@", error);
            
            NSString *messageTitle;
            NSString *messageText;
            
            if ([[[operation.responseData objectFromJSONData] objectForKey:@"status"] isEqualToString:@"duplicate user"])
            {
                messageTitle = @"Username Taken";
                messageText = @"Oh no! Someone is already using that username. Please try a different username.";
            }
            else if ([[[operation.responseData objectFromJSONData] objectForKey:@"status"] isEqualToString:@"duplicate email"])
            {
                messageTitle = @"Email Registered";
                messageText = @"This email is already registered in our system. If you believe this is a mistake, please let us know and we will investigate it immediately.";
            }
            else if ([[[operation.responseData objectFromJSONData] objectForKey:@"status"] isEqualToString:@"invalid email"])
            {
                messageTitle = @"Email Invalid";
                messageText = @"It seems that the email provided is invalid. If you think this is an error, please email us and we will investigate it further.";
            }
            else
            {
                messageTitle = @"Sign Up Error";
                messageText = @"There was an error creating your account. Please make sure that you have entered a valid email address";
            }
            
            [[KUIHelper createAlertViewWithTitle:messageTitle
                                         message:messageText
                                        delegate:self
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
            
            successBlock(NO);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userForgotPassword:(NSMutableDictionary *)userDictionary andCompletion:(SuccessCompletionBlock)successBlock
{
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userForgotPassword:userDictionary andCompletion:successBlock];
        }];
    }
    else
    {
        [userDictionary setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/password_reset/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:userDictionary];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
        AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"userForgotPassword hasAcceptableStatusCode: %d", [operation.response statusCode]);
//            [[KUIHelper createAlertViewWithTitle:@"Email Sent"
//                                         message:@"An email has been sent to the provided address. Please follow the directions in the email to reset your password."
//                                        delegate:self
//                               cancelButtonTitle:@"Okay"
//                               otherButtonTitles:nil] show];
            successBlock(YES);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"userForgotPassword server error: %@", operation.responseString);
            NSLog(@"userForgotPassword error json: %@", [operation.responseData objectFromJSONData]);
            
            NSString *messageTitle;
            NSString *messageText;
            
            messageTitle = @"Account Not Found";
            messageText = @"We were not able to find the account associated with this email. Please make sure this is the same email used to sign up for the account and try again.";
            
            [[KUIHelper createAlertViewWithTitle:messageTitle
                                         message:messageText
                                        delegate:self
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil] show];
            
            successBlock(NO);
        }];
        
        [self.queue addOperation:operation];
    }
}

-(void)userIsAuthenticated:(SuccessCompletionBlock)successBlock
{
    NSString *authPath = [NSString stringWithFormat:@"%@/api/user/authenticated/", self.baseURL];
    [self JSONWithPath:authPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        if (!error)
        {
            self.isUserAuthenticated = YES;
            NSLog(@"no error!");
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UserAuthorized"
             object:self];
            
        }
        else
        {
            self.isUserAuthenticated = NO;
            NSLog(@"user authentication check error: %@", error);
            
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

-(void)userUpdateCardInfo:(NSMutableDictionary *)cardResponse withSuccess:(SuccessCompletionBlock)successBlock
{
    NSLog(@"card information: %@", cardResponse);
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self userUpdateCardInfo:cardResponse withSuccess:successBlock];
        }];
        
    } else {
        [cardResponse setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/update_card/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:cardResponse];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"cc update operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            NSLog(@"cc response: %@ ", [responseObject objectFromJSONData]);
            self.userCard = [NSMutableDictionary dictionaryWithDictionary:[responseObject objectFromJSONData]];
            [self userIsAuthenticated:nil];
            successBlock(YES);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"cc update error: %@", operation.responseString);
            successBlock(NO);
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
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/valid_card/", self.baseURL];
        [self JSONWithPath:requestPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
        {
            NSLog(@"user card returned: %@", JSON);
            NSLog(@"user card response: %@", response);
            NSLog(@"user card error: %@", error);
            
            if ([[JSON objectForKey:@"card_type"] isEqualToString:@"none"]) {
                NSLog(@"No Card Found");
                self.userCard = nil;
                [self userCreditCardPrompt];
            } else {
                self.userCard = [NSMutableDictionary dictionaryWithDictionary:JSON];
            }
        }];
    }
}

-(void)userCreditCardPrompt
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isCreatingAccount"])
    {
        if ([SharedDataHandler sharedInstance].isUserAuthenticated) {
            
            [[KUIHelper createAlertViewWithTitle:@"Register Credit Card?"
                                        message:@"DrinkUp cannot find a valid credit card. A credit card is required for purchasing drinks. Would you like to add one now?"
                                       delegate:self
                              cancelButtonTitle:@"Not Now"
                               otherButtonTitles:@"Add Card", nil] show];
        }
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
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/invalidate_card/", self.baseURL];
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

-(void)updateUserProfileImageSaved:(SuccessCompletionBlock)successBlock
{
    if (!self.csrfToken)
    {
        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
            [self updateUserProfileImageSaved:successBlock];
        }];
    } else {
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/user/picture_saved/", self.baseURL];
        [self JSONWithPath:requestPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
         {
             NSLog(@"respponse: %@", response);
             NSLog(@"error: %@", error);
             if (!error)
             {
                 [self saveUserPictureLocally];
                 successBlock(YES);
             } else
             {
                 successBlock(NO);
             }
         }];
    }
}

-(void)getUserOrderHistoryWithCompletion:(ObjectsCompletionBlock)completionBlock
{    
    NSString *orderHistoryPath = [NSString stringWithFormat:@"%@/api/user/order_history/", self.baseURL];
    [self JSONWithPath:orderHistoryPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error)
    {
        NSMutableArray *orderHistory = [[NSMutableArray alloc] init];
        NSMutableDictionary *tempDict;
        for (NSDictionary *order in JSON) {
            tempDict = [[NSMutableDictionary alloc] initWithDictionary:[order objectForKey:@"fields"]];
            [tempDict setObject:[order objectForKey:@"pk"] forKey:@"id"];
            [orderHistory addObject:tempDict];
        }
        NSLog(@"order history: %@", orderHistory);
        completionBlock(orderHistory);
    }];
}

//-(void)userUpdateProfilePicture:(NSURL *)imageURL withSuccess:(SuccessCompletionBlock)successBlock
//{
//    if (!self.csrfToken)
//    {
//        [self getEmptyCSRFToken:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
//            [self userUpdateProfilePicture:imageURL withSuccess:successBlock];
//        }];
//    } else {
//        NSMutableDictionary *sendDict = [[NSMutableDictionary alloc] init];
//        [sendDict setObject:self.csrfToken forKey:@"csrfmiddlewaretoken"];
//        [sendDict setObject:imageURL forKey:@"pictureURL"];
//        
//        NSString *requestPath = @"/api/user/picture_saved/";
//        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        
//        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
//        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:sendDict];
//        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//        [request2 setValue:@"/" forHTTPHeaderField:@"Referer"];
//        
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//         {
//             NSLog(@"profile pic operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
//             NSLog(@"user profile pic response object: %@", [responseObject objectFromJSONData]);
//             [self.userInformation setObject:[[[[responseObject objectFromJSONData] objectAtIndex:0] objectForKey:@"fields" ] objectForKey:@"profile_image"] forKey:@"profile_image"];
//             [self saveUserPictureLocally];
//             successBlock(YES);
//         }
//        failure:^(AFHTTPRequestOperation *operation, NSError *error)
//         {
//             NSLog(@"user update profile pic error: %@", operation.responseString);
//             UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Image Upload Failed"
//                                                               message:@"There was an error with the image upload. It may be the internet connection or something on our side. Try again in a little bit. If you keep having issues, let us know and we will investigate the problem."
//                                                              delegate:self
//                                                     cancelButtonTitle:@"Okay"
//                                                     otherButtonTitles:nil];
//             [message show];
//             successBlock(NO);
//         }];
//        
//        [self.queue addOperation:operation];
//    }
//}

-(bool)pictureExistsLocally
{
    return ([self getUserProfileImage] != NULL);
}

-(void)saveUserPictureLocally
{
    NSString *fileName = [[SharedDataHandler sharedInstance].userInformation objectForKey:@"ua_username"];
    NSLog(@"filename to retrieve from AWS S3: %@", fileName);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    
    AmazonS3Client *s3Client = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAIXLT3ZDWWR7Q4YKA" withSecretKey:@"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"];
    
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stream open];
    
#ifdef DEV
    S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:fileName withBucket:@"DrinkUp-Users-Dev"];
#else
    S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:fileName withBucket:@"DrinkUp-Users"];
#endif
    request.outputStream = stream;
    
    [s3Client getObject:request];
}

-(UIImage *)getUserProfileImage
{
    NSString *fileName = [[SharedDataHandler sharedInstance].userInformation objectForKey:@"ua_username"];
    NSLog(@"filename get user profile image: %@", fileName);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    
    UIImage *userImage = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    if (userImage == nil) {
        userImage = [UIImage imageNamed:@"app-icon_114"];
    }
    
    return userImage;
}

-(void)removeLocalProfilePicture
{
    NSString *fileName = [[SharedDataHandler sharedInstance].userInformation objectForKey:@"ua_username"];
    NSLog(@"filename get user profile image: %@", fileName);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    NSLog(@"Path to file: %@", filePath);
    NSLog(@"File exists: %d", fileExists);
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:filePath]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
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
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/api/orders/create/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        id orderJSON = [[order objectForKey:@"drinks"] JSONString];
        [order setObject:orderJSON forKey:@"drinks"];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:order];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
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
    if (!self.facebook) {
        [self initializeFacebook];
    }
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
        
        NSString *requestPath = [NSString stringWithFormat:@"%@/facebook/mobile_login/", self.baseURL];
        NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSMutableURLRequest *request2 = [client requestWithMethod:@"POST" path:@"" parameters:userFacebookInfo];
        [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request2 setValue:[NSString stringWithFormat:@"%@/", self.baseURL] forHTTPHeaderField:@"Referer"];
        
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
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCreatedAccount"];
                
                NSString *ua_username = [[[[[[responseObject objectFromJSONData] objectAtIndex:0] objectForKey:@"fields"] objectForKey:@"user"] objectForKey:@"fields"] objectForKey:@"username"];
                [self.userInformation setObject:ua_username forKey:@"ua_username"];
                [[UAPush shared] setAlias:[[self userInformation] objectForKey:@"ua_username"]];
                [[UAPush shared] updateRegistration];
                [self userCurrentCardInfo];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"FacebookServerLoginAuthorized"
                 object:self];
                
                successBlock(YES);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"FacebookServerLoginFailure"
             object:self];
            
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
        [self.userInformation setObject:[result objectForKey:@"email"] forKey:@"email"];
        
        [self userLoginFacebookOnServer:userFacebookInfo withSuccess:^(bool successful) {
        }];
    }
    
    NSLog(@"Request Made: %@", [request graphPath]);
	NSLog(@"Result of API call: \n%@", result);
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Add Card"])
    {
        CreditCardProfileViewController *cardVC = [[CreditCardProfileViewController alloc] init];
        AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [delegate.rootNavigationController pushViewController:cardVC animated:YES];
    }
}

@end
