//
//  DrinkSelectCell.h
//  DrinkUp
//
//  Created by Kinetic on 3/10/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCell.h"

@interface DrinkSelectCell : BasicCell
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
-(void)setDrinkQuantity:(int)count;
-(void)setCostLabelAmount:(NSString *)labelAmount;
@end
