//
//  DrinkSelectCell.m
//  DrinkUp
//
//  Created by Kinetic on 3/10/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "DrinkSelectCell.h"

@interface DrinkSelectCell ()
@property (nonatomic, strong) UILabel *drinkCountLabel;
@property (nonatomic, strong) UILabel *drinkCostLabel;
@end

@implementation DrinkSelectCell

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.cellImageView setHidden:YES];
        [self.cellImageBox setHidden:YES];
        
        self.drinkCountLabel = [[UILabel alloc] init];
        [self.drinkCountLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
        [self.drinkCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.drinkCountLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.drinkCountLabel setBackgroundColor:[UIColor whiteColor]];
        [self.drinkCountLabel setTextColor:[UIColor blackColor]];
//        [drinkCountLabel setTextColor:[UIColor colorWithRed:(227/255.0) green:(204/255.0) blue:(35/255.0) alpha:1.0]];
//        [self.drinkCountLabel setFont:DEFAULT_CELL_TITLE_FONT];
        [self.drinkCountLabel setNumberOfLines:1];
        [self addSubview:self.drinkCountLabel];
        
        self.drinkCostLabel = [[UILabel alloc] init];
        [self.drinkCostLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [self.drinkCostLabel setTextAlignment:NSTextAlignmentCenter];
        [self.drinkCostLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.drinkCostLabel setBackgroundColor:[UIColor whiteColor]];
        [self.drinkCostLabel setTextColor:[UIColor blackColor]];
        //        [drinkCostLabel setTextColor:[UIColor colorWithRed:(227/255.0) green:(204/255.0) blue:(35/255.0) alpha:1.0]];
//        [self.drinkCostLabel setFont:DEFAULT_CELL_TITLE_FONT];
        [self.drinkCostLabel setNumberOfLines:1];
        [self addSubview:self.drinkCostLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat spacer = 10.0;
    
    CGRect boxLabelRect = self.cellImageBox.frame;
    boxLabelRect.size.width -= 30.0;
    [self.drinkCountLabel setFrame:boxLabelRect];
    
    CGRect costLabelRect = self.drinkCostLabel.frame;
    costLabelRect.size.height = self.frame.size.height;
    costLabelRect.size.width = 80.0;
    costLabelRect.origin.x = self.frame.size.width - costLabelRect.size.width;
    costLabelRect.origin.y = 0.0;
    [self.drinkCostLabel setFrame:costLabelRect];
    
    CGRect textLabelRect = self.textLabel.frame;
    textLabelRect.origin.x = CGRectGetMaxX(self.drinkCountLabel.frame) + spacer;
    textLabelRect.size.height = self.frame.size.height;
    textLabelRect.size.width = self.frame.size.width - boxLabelRect.size.width - costLabelRect.size.width - spacer;
    textLabelRect.origin.y = self.frame.size.height/2 - textLabelRect.size.height/2;
    [self.textLabel setFrame:textLabelRect];
}

-(void)setDrinkQuantity:(int)count {
    [self.drinkCountLabel setText:[NSString stringWithFormat:@"%i", count]];
}

-(void)setCostLabelAmount:(NSString *)labelAmount {
    [self.drinkCostLabel setText:labelAmount];
}
@end
