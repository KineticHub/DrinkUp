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

typedef void(^JsonRequestCompletionBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error);
typedef void(^ObjectsCompletionBlock)(NSMutableArray* objects);

@interface SharedDataHandler : NSObject <CLLocationManagerDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>

@property int current_section;
@property (nonatomic, strong) NSMutableArray *currentDrinkOrder;
@property (nonatomic, strong) NSDictionary *currentBar;

+ (SharedDataHandler *)sharedInstance;
-(void)initializeLocationTracking;

-(void)loadBars:(ObjectsCompletionBlock)completionBlock;
-(void)loadBarSectionsForBar:(int)bar_id onCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinkTypesForBarSection:(int)section_id onCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinksForSection:(int)section_id withType:(int)type_id onCompletion:(ObjectsCompletionBlock)completionBlock;

#pragma mark - Server Login
-(void)loginToServerWithCredentials:(NSDictionary *)credentials;

#pragma mark - Facebook Methods
-(Facebook *)facebookInstance;
-(void)initializeFacebook;
-(void)authorizeFacebook;
@end
