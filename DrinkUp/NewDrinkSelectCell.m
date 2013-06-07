//
//  NewDrinkSelectCell.m
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "NewDrinkSelectCell.h"
#import "TextStepperField.h"

@interface NewDrinkSelectCell ()
@end

@implementation NewDrinkSelectCell

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        [self.textLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setNumberOfLines:1];
        [self.textLabel setAdjustsFontSizeToFitWidth:YES];
        
        self.quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.quantityLabel setBackgroundColor:[UIColor blackColor]];
        [self.quantityLabel setTextColor:[UIColor whiteColor]];
        [self.quantityLabel setAlpha:0.65];
        [self.quantityLabel setTextAlignment:NSTextAlignmentCenter];
        [self.quantityLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
        [self.contentView addSubview:self.quantityLabel];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.priceLabel setBackgroundColor:[UIColor blackColor]];
        [self.priceLabel setTextColor:[UIColor whiteColor]];
        [self.priceLabel setAlpha:0.65];
        [self.priceLabel setTextAlignment:NSTextAlignmentCenter];
        [self.priceLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]];
        [self.contentView addSubview:self.priceLabel];
        
        UIView *stepperContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        [stepperContainer setBackgroundColor:[UIColor redColor]];
        
        self.stepper = [[TextStepperField alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 65.0)];
        self.stepper.Current = 0;
        self.stepper.Step = 1;
        self.stepper.Minimum = 0;
        self.stepper.Maximum = 20;
        self.stepper.NumDecimals = 0;
        self.stepper.IsEditableTextField = NO;
        [self.stepper setBackgroundColor:[UIColor whiteColor]];
        [self.stepper.textField setFont:[UIFont boldSystemFontOfSize:42.0]];
        [self.stepper.textField setTextAlignment:NSTextAlignmentCenter];
        [self.stepper.textField setBackgroundColor:[UIColor clearColor]];
        [self.stepper.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        CGRect textFrame = self.stepper.textField.frame;
        textFrame.size.height = self.stepper.frame.size.height;
        textFrame.origin.y = 0.0;
        [self.stepper.textField setFrame:textFrame];
        [self.stepper addTarget:self action:@selector(endReveal) forControlEvents:UIControlEventTouchUpInside];
        
        [stepperContainer addSubview:self.stepper];
        
        self.backgroundView = stepperContainer;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.direction      = ZKRevealingTableViewCellDirectionRight;
        self.shouldBounce   = YES;
    }
    return self;
}

-(void)endReveal
{
    NSLog(@"hit end reveal");
    [self setRevealing:NO];
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
    textLabelFrame.size.height = 30.0;
    self.textLabel.frame = textLabelFrame;
//    [self.textLabel sizeToFit];
    
    y += CGRectGetHeight(self.textLabel.frame) + 5.0;
    
    [self.quantityLabel setFrame:CGRectMake(textLabelFrame.origin.x, y, 0.0, 0.0)];
    [self.quantityLabel sizeToFit];
    
    [self.priceLabel sizeToFit];
    [self.priceLabel setFrame:CGRectMake(CGRectGetMaxX(textLabelFrame) - self.priceLabel.frame.size.width, y, self.priceLabel.frame.size.width, self.priceLabel.frame.size.height)];
}

@end
