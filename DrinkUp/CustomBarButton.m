//
//  CustomBarButton.m
//  DrinkUp
//
//  Created by Kinetic on 6/19/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "CustomBarButton.h"

@implementation CustomBarButton
- (void)setButtonWithImage:(UIImage *)customImage
{
    self.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    self.sideColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    self.radius = 6.0;
    self.margin = 2.0;
    self.depth = 0.0;
    [self setFrame:CGRectMake(0.0, 0.0, customImage.size.width + 10.0, customImage.size.height)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self setImage:customImage forState:UIControlStateNormal];
}
@end
