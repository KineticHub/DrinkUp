//
//  SharedDataHandler.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "SharedDataHandler.h"
#import "AFJSONRequestOperation.h"

@interface SharedDataHandler ()
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *currentDrinkOrder;
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
    
    NSDictionary *drink1 = @{@"name": @"Sam Lite", @"price": @"$5.50", @"quantity":@0};
    NSDictionary *drink2 = @{@"name": @"Budweiser", @"price": @"$7.00", @"quantity":@0};
    NSDictionary *drink3 = @{@"name": @"Corona", @"price": @"$6.00", @"quantity":@0};
    
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
    [self.currentDrinkOrder addObjectsFromArray:newDrinks];
}

-(void)removeDrinksFromCurrentOrder:(NSMutableArray *)removeDrinks {
    [self.currentDrinkOrder removeObjectsInArray:removeDrinks];
}

-(void)clearCurrentDrinkOrder {
    [self.currentDrinkOrder removeAllObjects];
}
@end
