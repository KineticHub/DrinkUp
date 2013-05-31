//
//  DrinkSelectCell.m
//  DrinkUp
//
//  Created by Kinetic on 3/10/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//
// [UIColor colorWithRed:(R/255.0) green:(G/255.0) blue:(B/255.0) alpha:1.0]];

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
        NSLog(@"setup drink select cell");
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        
        [self.cellImageView setHidden:YES];
        [self.cellImageBox setHidden:YES];
        
        self.drinkCountLabel = [[UILabel alloc] init];
        [self.drinkCountLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
        [self.drinkCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.drinkCountLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.drinkCountLabel setBackgroundColor:[UIColor whiteColor]];
        [self.drinkCountLabel setTextColor:[UIColor blackColor]];
        [self.drinkCountLabel setNumberOfLines:1];
        
        [self.drinkCountLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [self.drinkCountLabel.layer setBorderWidth:2.0];
        [self addSubview:self.drinkCountLabel];
        
        self.drinkCostLabel = [[UILabel alloc] init];
        [self.drinkCostLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [self.drinkCostLabel setTextAlignment:NSTextAlignmentCenter];
        [self.drinkCostLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.drinkCostLabel setBackgroundColor:[UIColor whiteColor]];
        [self.drinkCostLabel setTextColor:[UIColor blackColor]];
        [self.drinkCostLabel setNumberOfLines:1];
        
        [self.drinkCostLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [self.drinkCostLabel.layer setBorderWidth:2.0];
        [self addSubview:self.drinkCostLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.cellImageView setHidden:YES];
    [self.cellImageBox setHidden:YES];
    
    CGFloat spacer = 5.0;
    
    CGRect drinkCountLabelRect = CGRectMake(0.0, 0.0, self.frame.size.width/8, self.contentView.frame.size.height);
    drinkCountLabelRect.size.width += 10.0;
    [self.drinkCountLabel setFrame:drinkCountLabelRect];
    
    CGRect costLabelRect = self.drinkCostLabel.frame;
    costLabelRect.size.height = self.contentView.frame.size.height;
    costLabelRect.size.width = 70.0;
    costLabelRect.origin.x = CGRectGetMaxX(self.contentView.frame) - costLabelRect.size.width;
    costLabelRect.origin.y = 0.0;
    [self.drinkCostLabel setFrame:costLabelRect];
    
    CGRect textLabelRect = self.textLabel.frame;
    textLabelRect.origin.x = CGRectGetMaxX(self.drinkCountLabel.frame) + spacer;
    textLabelRect.size.height = self.contentView.frame.size.height;
    textLabelRect.size.width = self.frame.size.width - drinkCountLabelRect.size.width - costLabelRect.size.width - spacer;
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
