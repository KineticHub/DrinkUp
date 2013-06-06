//
//  OrderHistoryInfoViewController.h
//  DrinkUp
//
//  Created by Kinetic on 6/5/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderHistoryInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSDictionary *order;
-(id)initWithOrder:(NSDictionary *)pastOrder;
@end
