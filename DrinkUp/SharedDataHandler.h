//
//  SharedDataHandler.h
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void(^JsonRequestCompletionBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error);
typedef void(^ObjectsCompletionBlock)(NSMutableArray* objects);

@interface SharedDataHandler : NSObject <CLLocationManagerDelegate>
+ (SharedDataHandler *)sharedInstance;

-(void)loadBars:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinkTypesForBar:(NSString *)barEmail onCompletion:(ObjectsCompletionBlock)completionBlock;
-(void)loadDrinksForBar:(NSString *)barEmail onCompletion:(ObjectsCompletionBlock)completionBlock;

-(NSMutableArray *)getCurrentOrder;
-(void)addDrinksToCurrentOrder:(NSMutableArray *)newDrinks;
-(void)removeDrinksFromCurrentOrder:(NSMutableArray *)removeDrinks;
-(void)clearCurrentDrinkOrder;
@end
