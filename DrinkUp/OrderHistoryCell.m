//
//  OrderHistoryCell.m
//  DrinkUp
//
//  Created by Kinetic on 6/4/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "OrderHistoryCell.h"
#import "UIColor+FlatUI.h"

@implementation OrderHistoryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.cellImageView setHidden:YES];
        [self.cellImageBox setHidden:YES];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.cellImageView setHidden:YES];
    [self.cellImageBox setHidden:YES];
    
    [self.textLabel setTextColor:[UIColor midnightBlueColor]];
}

@end
