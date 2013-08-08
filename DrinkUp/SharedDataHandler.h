//
//  SharedDataHandler.h
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FBConnect.h"
#import "AFNetworking.h"
#import "FUIAlertView.h"

typedef void(^JsonRequestCompletionBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error);
typedef void(^ObjectsCompletionBlock)(NSMutableArray* objects);
typedef void(^SuccessCompletionBlock)(bool successful);

@interface SharedDataHandler : NSObject <FUIAlertViewDelegate, CLLocationManagerDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate, NSURLConnectionDelegate>

@property int current_section;
@property (nonatomic, strong) NSMutableArray *currentDrinkOrder;
@property (nonatomic, strong) NSDictionary *currentBar;
@property (nonatomic, strong) NSMutableDictionary *userInformation;
@property (nonatomic, strong) NSMutableDictionary *userCard;
@property (nonatomic, strong) NSString *marketplace;
@property (nonatomic, strong) NSString *user_location;
@property bool isUserAuthenticated;
@property bool isNotificationsEnabled;
@property NSString *currentOrderID;

+ (SharedDataHandler *)sharedInstance;
-(void)initializeLocationTracking;
-(bool)isBarHappyHour;
- (void)saveUserInfo;
- (void)loadUserInfo;
- (void)fbGetUserInfo;

#pragma mark - Selection API Functions
-(void)loadUserLocation;
-(void)loadBars:(ObjectsCompletionBlock)completionBlock;
-(void)loadBarsWithLocation:(ObjectsCompletionBlock)completionBlock;
-(void)loadBarSectionsForBar:(int)bar_id onCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinkTypesForBarSection:(int)section_id onCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinksForSection:(int)section_id withType:(int)type_id onCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinksForOrder:(int)order_id onCompletion:(ObjectsCompletionBlock)completionBlock;

#pragma mark - User API Functions
-(void)userLoginToServerWithCredentials:(NSMutableDictionary *)credentials andCompletion:(SuccessCompletionBlock)successBlock;
-(void)userLogoutOfServer:(SuccessCompletionBlock)successBlock;
-(void)userCreateOnServer:(NSMutableDictionary *)userDictionary withSuccess:(SuccessCompletionBlock)successBlock;
-(void)userUpdateCardInfo:(NSMutableDictionary *)cardResponse withSuccess:(SuccessCompletionBlock)successBlock;
-(void)userCurrentCardInfo;
-(void)userInvalidateCurrentCard:(SuccessCompletionBlock)successBlock;
-(void)updateUserProfileImageSaved:(SuccessCompletionBlock)successBlock;
-(UIImage *)getUserProfileImage;
-(void)getUserOrderHistoryWithCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)userIsAuthenticated:(SuccessCompletionBlock)successBlock;
-(void)userLoginToServerWithCookieAndCompletion:(SuccessCompletionBlock)successBlock;
-(void)userForgotPassword:(NSMutableDictionary *)userDictionary andCompletion:(SuccessCompletionBlock)successBlock;

#pragma mark - Order API Functions
-(void)placeOrder:(NSMutableDictionary *)order withSuccess:(SuccessCompletionBlock)successBlock;

#pragma mark - Facebook Methods
-(Facebook *)facebookInstance;
-(void)initializeFacebook;
-(void)authorizeFacebook;
@end
