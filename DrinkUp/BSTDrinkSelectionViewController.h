//
//  BSTDrinkSelectionViewController.h
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicSplitTableViewController.h"

@interface BSTDrinkSelectionViewController : BasicSplitTableViewController <UIActionSheetDelegate>
-(id)initWithDrinkType:(int)drinkType typeName:(NSString *)drinkTypeName;
@end
