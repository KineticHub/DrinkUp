//
//  BasicCell.m
//  DrinkUp
//
//  Created by Kinetic on 3/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BasicCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

@interface BasicCell ()
@property (nonatomic, strong) UIView *seperatorLine;
@property int count;
@end

@implementation BasicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.count = 0;
        
//        UIImage *cellBackgroundImage = [[UIImage imageNamed:@"pw_maze_white_@2X.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        
//        UIImageView *cellBackgroundViewImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
        UIImageView *cellBackgroundViewImageView = [[UIImageView alloc] init];
        [cellBackgroundViewImageView setFrame:CGRectMake(0, 0, self.frame.size.width - 20.0, self.frame.size.height)];
        [cellBackgroundViewImageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pw_maze_white_@2X.png"]]];
        [self setBackgroundView:cellBackgroundViewImageView];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self.textLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setTextColor:[UIColor blackColor]];
//        [self.textLabel setTextColor:[UIColor colorWithRed:(227/255.0) green:(204/255.0) blue:(35/255.0) alpha:1.0]];
        [self.textLabel setFont:DEFAULT_CELL_TITLE_FONT];
        [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.textLabel setNumberOfLines:0];
        
        [self.detailTextLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        [self.detailTextLabel setTextColor:[UIColor blackColor]];
        [self.detailTextLabel setFont:DEFAULT_CELL_DESCRIPTION_FONT];
        [self.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.detailTextLabel setNumberOfLines:2];
        [self.detailTextLabel setAlpha:0.75];
        
        self.cellImageBox = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.height, self.frame.size.height)];
        [self.cellImageBox setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.cellImageBox];
        
        self.cellImageView = [[UIImageView alloc] init];
        self.cellImageView.frame = CGRectMake(0.0, 0.0, self.cellImageBox.frame.size.height, self.cellImageBox.frame.size.height);
        [self.cellImageBox addSubview: self.cellImageView];
        
        UIView *highlightedBackgroundView = [[UIView alloc] init];
        [highlightedBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [self setSelectedBackgroundView:highlightedBackgroundView];
        
//        self.seperatorLine = [[UIView alloc] init];
//        [self.seperatorLine setBackgroundColor:[UIColor colorWithRed:(196/255.0) green:(196/255.0) blue:(196/255.0) alpha:1.0]];
//        [self.seperatorLine setBackgroundColor:[UIColor colorWithRed:(227/255.0) green:(204/255.0) blue:(35/255.0) alpha:1.0]];
//        [self.seperatorLine setBackgroundColor:[UIColor whiteColor]];
//        [self addSubview:self.seperatorLine];
        
//        UIImageView *callBackgroundViewImageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointing_arrow_2_dark"]];
//        [self setSelectedBackgroundView:callBackgroundViewImageViewSelected];
    }
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat spacer = 10.0;
    [self.cellImageBox setFrame:CGRectMake(0.0, 0.0, self.frame.size.height, self.frame.size.height)];
    self.cellImageView.center = CGPointMake(self.cellImageBox.center.x, self.cellImageBox.frame.size.height/2);
//    [self.seperatorLine setFrame:CGRectMake(0.0, self.frame.size.height, self.frame.size.width, 1.0)];
    
    if (!self.cellImageView.image) {
        [self.cellImageView setHidden:YES];
        
        CGRect textLabelRect = self.textLabel.frame;
        textLabelRect.origin.x = spacer;
        [self.textLabel setFrame:textLabelRect];
        
    } else {
        [self.cellImageView setHidden:NO];
        
        CGRect textLabelRect = self.textLabel.frame;
        textLabelRect.origin.x = CGRectGetMaxX(self.cellImageBox.frame) + spacer;
        [self.textLabel setFrame:textLabelRect];
    }
}

-(void)setCellImage:(NSURLRequest *)imageURLRequest {
    
    [self.cellImageView setBackgroundColor:[UIColor clearColor]];
//    [self.cellImageView.layer setCornerRadius:8.0];
    self.cellImageView.layer.masksToBounds = YES;
    self.cellImageView.autoresizesSubviews = NO;
    self.cellImageView.autoresizingMask = NO;
    
    __block UIImageView *imageViewPointer = self.cellImageView;
//    __block CGRect originalImageFrame = self.imageView.frame;
//    __block CGRect originalContentViewFrame = self.contentView.frame;
//    __block CGPoint originalContentViewCenter = self.contentView.center;
    __block BasicCell *pointerCell = self;
    
    [self.cellImageView setImageWithURLRequest:imageURLRequest placeholderImage:[UIImage imageNamed:@"blank_square"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        imageViewPointer.image = image;
        
//        const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
//        imageViewPointer.image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(imageViewPointer.image.CGImage, colorMasking)];
        
        [imageViewPointer setHidden:NO];
//        imageViewPointer.frame = CGRectMake(originalContentViewFrame.origin.x, originalImageFrame.origin.y, 45, 45);
//        imageViewPointer.center = CGPointMake(imageViewPointer.center.x, originalContentViewCenter.y);
        
        [imageViewPointer layoutSubviews];
        
        [pointerCell layoutSubviews];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
}

@end
