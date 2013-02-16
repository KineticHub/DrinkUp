//
//  SharedDataHandler.h
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

typedef void(^JsonRequestCompletionBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON, NSError *error);
typedef void(^ObjectsCompletionBlock)(NSMutableArray* objects);

#import <Foundation/Foundation.h>

@interface SharedDataHandler : NSObject
+ (SharedDataHandler *)sharedInstance;
-(void)loadBars:(ObjectsCompletionBlock)completionBlock;
@end
