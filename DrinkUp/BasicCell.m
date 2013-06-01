//
//  BasicCell.m
//  DrinkUp
//
//  Created by Kinetic on 3/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BasicCell.h"
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
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
//        UIImage *cellBackgroundImage = [[UIImage imageNamed:@"pw_maze_white_@2X.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        
//        UIImageView *cellBackgroundViewImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
        UIImageView *cellBackgroundViewImageView = [[UIImageView alloc] init];
        [cellBackgroundViewImageView setFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
//        [cellBackgroundViewImageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pw_maze_white_@2X.png"]]];
        [cellBackgroundViewImageView.layer setBorderColor:[[UIColor colorWithRed:(31/255.0) green:(31/255.0) blue:(31/255.0) alpha:1.0] CGColor]];
        [cellBackgroundViewImageView.layer setBorderWidth:1.0];
        [cellBackgroundViewImageView setBackgroundColor:[UIColor blackColor]];
        [cellBackgroundViewImageView setAlpha:0.1];
//        [cellBackgroundViewImageView setBackgroundColor:[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:1.0]];
        [self setBackgroundView:cellBackgroundViewImageView];
//        [self setBackgroundColor:[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:1.0]];
        
        [self.textLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setTextColor:[UIColor colorWithRed:(67/255.0) green:(40/255.0) blue:(18/255.0) alpha:1.0]];
//        [self.textLabel setTextColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0]]; // good with black
//        [self.textLabel setTextColor:[UIColor colorWithRed:(181/255.0) green:(163/255.0) blue:(28/255.0) alpha:1.0]];
//        [self.textLabel setTextColor:[UIColor colorWithRed:(227/255.0) green:(204/255.0) blue:(35/255.0) alpha:1.0]];
//        [self.textLabel setTextColor:[UIColor colorWithRed:(205/255.0) green:(205/255.0) blue:(205/255.0) alpha:1.0]];
//        [self.textLabel setTextColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0]]; // good with black
//        [self.textLabel setTextColor:[UIColor colorWithRed:(119/255.0) green:(209/255.0) blue:(214/255.0) alpha:1.0]];
//        [self.textLabel setTextColor:[UIColor colorWithRed:(139/255.0) green:(229/255.0) blue:(234/255.0) alpha:1.0]];
        [self.textLabel setFont:DEFAULT_CELL_TITLE_FONT];
        [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.textLabel setNumberOfLines:0];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        
        [self.detailTextLabel setHighlightedTextColor:[UIColor blackColor]];
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        [self.detailTextLabel setTextColor:[UIColor darkGrayColor]];
        [self.detailTextLabel setFont:DEFAULT_CELL_DESCRIPTION_FONT];
        [self.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.detailTextLabel setNumberOfLines:3];
        [self.detailTextLabel setAlpha:0.9];
        
        self.cellImageBox = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x + 10.0, 20.0, self.frame.size.height + 20.0, self.frame.size.height - 30.0)];
//        [self.cellImageBox setBackgroundColor:[UIColor whiteColor]];
//        [self.cellImageBox.layer setBorderColor:[[UIColor colorWithRed:(181/255.0) green:(163/255.0) blue:(28/255.0) alpha:1.0] CGColor]];
//        [self.cellImageBox.layer setBorderColor:[[UIColor colorWithRed:(205/255.0) green:(205/255.0) blue:(205/255.0) alpha:1.0] CGColor]];
//        [self.cellImageBox.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
//        [self.cellImageBox.layer setBorderWidth:3.0];
        [self.cellImageBox.layer setCornerRadius:20.0];
        [self.cellImageBox.layer setMasksToBounds:YES];
//        [self.cellImageBox setAlpha:0.8];
        [self addSubview:self.cellImageBox];
        
        self.cellImageView = [[UIImageView alloc] init];
        self.cellImageView.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
        [self.cellImageBox addSubview: self.cellImageView];
        
        UIView *highlightedBackgroundView = [[UIView alloc] init];
        [highlightedBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [highlightedBackgroundView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [highlightedBackgroundView.layer setBorderWidth:2.0];
        [self setSelectedBackgroundView:highlightedBackgroundView];
        
//        self.seperatorLine = [[UIView alloc] init];
//        [self.seperatorLine setBackgroundColor:[UIColor colorWithRed:(196/255.0) green:(196/255.0) blue:(196/255.0) alpha:1.0]];
//        [self.seperatorLine setBackgroundColor:[UIColor colorWithRed:(31/255.0) green:(31/255.0) blue:(31/255.0) alpha:1.0]];
//        [self.seperatorLine setBackgroundColor:[UIColor whiteColor]];
//        [self addSubview:self.seperatorLine];
        
//        UIImageView *callBackgroundViewImageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointing_arrow_2_dark"]];
//        [self setSelectedBackgroundView:callBackgroundViewImageViewSelected];
    }
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat spacer = 15.0;
//    [self.cellImageBox setFrame:CGRectMake(self.contentView.frame.origin.x + 10.0, 15.0, self.frame.size.height - 5.0, self.frame.size.height - 30.0)];
    [self.cellImageBox setFrame:CGRectMake(self.contentView.frame.origin.x + 10.0, 10.0, self.frame.size.height - 30.0, self.frame.size.height - 30.0)];
    [self.cellImageBox setCenter:CGPointMake(self.cellImageBox.center.x, self.contentView.frame.size.height/2)];
    [self.cellImageView setFrame:CGRectMake(0.0, 0.0, self.cellImageBox.frame.size.width - 10.0, self.cellImageBox.frame.size.height - 10.0)];
    self.cellImageView.center = CGPointMake(self.cellImageBox.frame.size.width/2, self.cellImageBox.frame.size.height/2);
//    [self.seperatorLine setFrame:CGRectMake(0.0, -1.0, self.frame.size.width, 1.0)];
    
//    [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font constrainedToSize:self.detailTextLabel.frame.size lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.detailTextLabel sizeToFit];
    [self.textLabel sizeToFit];
//    NSLog(@"frame %@: %f", self.detailTextLabel.text, self.detailTextLabel.frame.size.height);
    
    int totalHeight = self.textLabel.frame.size.height + self.detailTextLabel.frame.size.height + 5.0;
    float topMiddle = round(self.contentView.frame.size.height/2 - totalHeight/2);
    
    if (!self.cellImageView.image) {
        [self.cellImageView setHidden:YES];
        [self.cellImageBox setHidden:YES];
        
        CGRect textLabelRect = self.textLabel.frame;
        textLabelRect.origin.x = round(spacer);
//        textLabelRect.origin.y = round(self.cellImageBox.frame.origin.y + self.cellImageBox.frame.size.height/2 - textLabelRect.size.height);
        textLabelRect.origin.y = topMiddle;
        [self.textLabel setFrame:textLabelRect];
        
        CGRect detailLabelRect = self.detailTextLabel.frame;
        detailLabelRect.origin.x = round(textLabelRect.origin.x);
        detailLabelRect.origin.y = round(textLabelRect.size.height + textLabelRect.origin.y + 5.0);
        [self.detailTextLabel setFrame:detailLabelRect];
        
    } else
    {
        [self.cellImageView setHidden:NO];
        [self.cellImageBox setHidden:NO];
        
        CGRect textLabelRect = self.textLabel.frame;
        textLabelRect.origin.x = round(CGRectGetMaxX(self.cellImageBox.frame) + spacer);
//        textLabelRect.origin.y = round(self.cellImageBox.frame.origin.y);
        textLabelRect.origin.y = topMiddle;
        [self.textLabel setFrame:textLabelRect];
        
        CGRect detailLabelRect = self.detailTextLabel.frame;
        detailLabelRect.origin.x = round(textLabelRect.origin.x);
        detailLabelRect.origin.y = round(textLabelRect.size.height + textLabelRect.origin.y + 5.0);
        detailLabelRect.size.width = round(self.contentView.frame.size.width - detailLabelRect.origin.x - 5.0);
        [self.detailTextLabel setFrame:detailLabelRect];
    }
    
    if ([self.detailTextLabel.text length] == 0) {
        self.textLabel.center = CGPointMake(self.textLabel.center.x, self.frame.size.height/2);
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
    
//    [self.cellImageView setImageWithURL:[imageURLRequest URL]];
    
    [self.cellImageView setImageWithURLRequest:imageURLRequest placeholderImage:[UIImage imageNamed:@"blank_square"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        imageViewPointer.image = image;
        
        const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
        imageViewPointer.image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(imageViewPointer.image.CGImage, colorMasking)];
        
        [imageViewPointer setHidden:NO];
//        imageViewPointer.frame = CGRectMake(originalContentViewFrame.origin.x, originalImageFrame.origin.y, 45, 45);
//        imageViewPointer.center = CGPointMake(imageViewPointer.center.x, originalContentViewCenter.y);
        
        [imageViewPointer layoutSubviews];
        
        [pointerCell layoutSubviews];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
}

@end
