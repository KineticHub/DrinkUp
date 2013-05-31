//
//  DrinkSelectionsViewController.h
//  DrinkUp
//
//  Created by Kinetic on 3/21/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinkSelectionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
-(id)initWithBarSection:(int)section_id;
@end
