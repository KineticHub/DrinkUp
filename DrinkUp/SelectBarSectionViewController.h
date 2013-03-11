//
//  SelectBarSectionViewController.h
//  DrinkUp
//
//  Created by Kinetic on 3/4/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicSplitTableViewController.h"

/*
 Replace with picker in order view
 */
@interface SelectBarSectionViewController : BasicSplitTableViewController
-(id)initWithBarSections:(NSArray *)barSections;
@end
