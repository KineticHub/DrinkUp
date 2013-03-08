//
//  BasicSplitTableViewController.h
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BOTTOM_BAR_TAG 55155

@interface BasicSplitTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *upperView;
@property (nonatomic, strong) UITableView *tableView;

-(id)initWithUpperViewHieght:(CGFloat)upperViewHeight;
-(void)checkPlaceOrderBarOption;
+(void)forceHidePlaceOrderBar;
@end
