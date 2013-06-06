//
//  CollapsableDrinkViewController.h
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapseClick.h"

@interface CollapsableDrinkViewController : UIViewController <CollapseClickDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithBarSection:(int)section_id;
@end
