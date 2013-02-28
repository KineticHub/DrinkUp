//
//  DrinkSelectionViewController.h
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinkSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
-(id)initWithDrinkType:(NSString *)drinkType;
@end
