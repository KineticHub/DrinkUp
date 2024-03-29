//
//  BasicSplitTableViewController.h
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedDataHandler.h"
#import "MBProgressHUD.h"
#import "BasicCell.h"
#import "FUIAlertView.h"

#define BOTTOM_BAR_TAG 55155

@interface BasicSplitTableViewController : UIViewController <FUIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (nonatomic, strong) UIView *upperView;
@property (nonatomic, strong) UITableView *tableView;

-(id)initWithUpperViewHieght:(CGFloat)upperViewHeight;
-(void)checkPlaceOrderBarOption;
+(void)forceHidePlaceOrderBar;
@end
