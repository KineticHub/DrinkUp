//
//  NewDrinkSelectCell.m
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "NewDrinkSelectCell.h"

@interface NewDrinkSelectCell ()
@end

@implementation NewDrinkSelectCell

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.textLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setNumberOfLines:1];
        [self.textLabel setAdjustsFontSizeToFitWidth:YES];
        
        self.quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.quantityLabel setBackgroundColor:[UIColor blackColor]];
        [self.quantityLabel setTextColor:[UIColor whiteColor]];
        [self.quantityLabel setAlpha:0.65];
        [self.quantityLabel setTextAlignment:NSTextAlignmentCenter];
        [self.quantityLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]];
        [self addSubview:self.quantityLabel];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.priceLabel setBackgroundColor:[UIColor blackColor]];
        [self.priceLabel setTextColor:[UIColor whiteColor]];
        [self.priceLabel setAlpha:0.65];
        [self.priceLabel setTextAlignment:NSTextAlignmentCenter];
        [self.priceLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]];
        [self addSubview:self.priceLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat y = 5.0;
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.y = y;
    self.textLabel.frame = textLabelFrame;
    
    [self.textLabel sizeToFit];
    
    y += CGRectGetHeight(self.textLabel.frame) + 5.0;
    
    [self.quantityLabel setFrame:CGRectMake(textLabelFrame.origin.x, y, 0.0, 0.0)];
    [self.quantityLabel sizeToFit];
    
    [self.priceLabel sizeToFit];
    [self.priceLabel setFrame:CGRectMake(CGRectGetMaxX(textLabelFrame) - self.priceLabel.frame.size.width, y, self.priceLabel.frame.size.width, self.priceLabel.frame.size.height)];
    
}

@end
