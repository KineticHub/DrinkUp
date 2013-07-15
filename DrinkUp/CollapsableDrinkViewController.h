//
//  CollapsableDrinkViewController.h
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapseClick.h"
#import "ZKRevealingTableViewCell.h"
#import "FUIAlertView.h"

@interface CollapsableDrinkViewController : UIViewController <FUIAlertViewDelegate, ZKRevealingTableViewCellDelegate, CollapseClickDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
- (id)initWithBarSection:(int)section_id;
@end
