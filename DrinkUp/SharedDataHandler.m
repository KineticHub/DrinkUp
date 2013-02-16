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

@property (nonatomic, strong) NSMutableArray *bars;
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

-(void)loadBars:(ObjectsCompletionBlock)completionBlock {
    
    NSString *barsPath = @"http://drink-up.appspot.com/bar?api_key=Pass1234&zipcode=24060";
    [self JSONWithPath:barsPath onCompletion:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error) {
        self.bars = [[NSMutableArray alloc] init];
        for (NSDictionary *bar in [JSON objectForKey:@"bars"]) {
            [self.bars addObject:bar];
        }
        completionBlock(self.bars);
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

@end
