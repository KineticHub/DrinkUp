//
//  NewDrinkSelectCell.h
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewDrinkSelectCell : UITableViewCell
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, strong) UILabel *quantityLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@end
