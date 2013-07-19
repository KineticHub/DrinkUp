//
//  FeedCell1.m
//  ADVFlatUI
//
//  Created by Tope on 03/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "FeedCell1.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+FlatUI.h"

@implementation FeedCell1

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIColor* mainColor = [UIColor colorWithRed:222.0/255 green:59.0/255 blue:47.0/255 alpha:1.0f];
        UIColor* neutralColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        
        NSString* fontName = @"GillSans-Italic";
        NSString* boldFontName = @"GillSans-Bold";
        
//        NSString *fontName = @"Lato-Black";
//        NSString *boldFontName = @"Lato-Bold";
        
        self.feedContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, 290)];
        self.feedContainer.backgroundColor = [UIColor belizeHoleColor];
        self.feedContainer.layer.cornerRadius = 3.0f;
        self.feedContainer.clipsToBounds = YES;
        [self addSubview:self.feedContainer];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 223, 263, 24)]; //7, 223, 154, 24
        self.nameLabel.textColor =  [UIColor whiteColor];
        self.nameLabel.font =  [UIFont fontWithName:boldFontName size:22.0f];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameLabel setAdjustsFontSizeToFitWidth:YES];
        [self.feedContainer addSubview:self.nameLabel];
        
        self.updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 252, 263, 21)]; // actual:(7, 246, 263, 47) mine:(7, 252, 154, 21)
        self.updateLabel.textColor =  neutralColor;
        self.updateLabel.font =  [UIFont fontWithName:fontName size:18.0f];
        [self.updateLabel setBackgroundColor:[UIColor clearColor]];
        [self.updateLabel setAdjustsFontSizeToFitWidth:YES];
        [self.feedContainer addSubview:self.updateLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(208, 252, 62, 21)]; // actual:(208, 223, 62, 21) mine: (208, 252, 62, 21)
        self.dateLabel.textColor = neutralColor;
        self.dateLabel.font =  [UIFont fontWithName:boldFontName size:20.0f];
        [self.dateLabel setBackgroundColor:[UIColor clearColor]];
        [self.dateLabel setAdjustsFontSizeToFitWidth:YES];
//        [self.feedContainer addSubview:self.dateLabel];
        
        self.commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 308, 42, 21)];
        self.commentCountLabel.textColor = neutralColor;
        self.commentCountLabel.font =  [UIFont fontWithName:fontName size:12.0f];
//        [self.feedContainer addSubview:self.commentCountLabel];
        
        self.likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 308, 42, 21)];
        self.likeCountLabel.textColor = neutralColor;
        self.likeCountLabel.font =  [UIFont fontWithName:fontName size:12.0f];
//        [self.feedContainer addSubview:self.likeCountLabel];
        
        self.picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 215)];
        self.picImageView.contentMode = UIViewContentModeScaleAspectFit;//UIViewContentModeScaleAspectFill;
        self.picImageView.clipsToBounds = YES;
        [self.picImageView setBackgroundColor:[UIColor whiteColor]];
        [self.feedContainer addSubview:self.picImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
