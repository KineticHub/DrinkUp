//
//  UnlockSliderView.m
//  DrinkUp
//
//  Created by Kinetic on 7/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UnlockSliderView.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"

@interface UnlockSliderView ()
@property (nonatomic, strong) id <UnlockSliderDelegate> sliderDelegate;
@property (nonatomic, retain) UISlider *slideToUnlock;
@property (nonatomic, retain) UIButton *lockButton;
@property (nonatomic, retain) UILabel *sliderLabel;
@property (nonatomic, retain) UIView *sliderBackground;
@end

@implementation UnlockSliderView

BOOL UNLOCKED = NO;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)sliderDelegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.sliderDelegate = sliderDelegate;
        
        UIImage *stetchLeftTrack= [[UIImage imageWithColor:[UIColor clearColor] cornerRadius:20.0]
                                   stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
        UIImage *stetchRightTrack= [[UIImage imageWithColor:[UIColor clearColor] cornerRadius:20.0]
                                    stretchableImageWithLeftCapWidth:30.0 topCapHeight:0.0];
        UIImage *thumbImage = [UIImage imageWithColor:[UIColor cloudsColor] cornerRadius:20.0];
        
        self.slideToUnlock = [[UISlider alloc] initWithFrame:CGRectMake(10.0, 6.0, frame.size.width - 20.0, frame.size.height - 12.0)];
        [self.slideToUnlock setThumbImage:thumbImage forState:UIControlStateNormal];
        [self.slideToUnlock setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        [self.slideToUnlock setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        [self.slideToUnlock addTarget:self action:@selector(unlockSlider) forControlEvents:UIControlEventTouchUpInside];
        [self.slideToUnlock addTarget:self action:@selector(fadeLabel) forControlEvents:UIControlEventValueChanged];
        [self.slideToUnlock.layer setCornerRadius:20.0];
        [self.slideToUnlock setBackgroundColor:[UIColor midnightBlueColor]];
        [self.slideToUnlock.layer setBorderColor:[[UIColor midnightBlueColor] CGColor]];
        [self.slideToUnlock.layer setBorderWidth:3.0];
        [self addSubview:self.slideToUnlock];
        
        self.sliderLabel = [[UILabel alloc] initWithFrame:frame];
        [self.sliderLabel setBackgroundColor:[UIColor clearColor]];
        [self.sliderLabel setTextAlignment:NSTextAlignmentCenter];
        [self.sliderLabel setTextColor:[UIColor whiteColor]];
        [self.sliderLabel setText:@"Slide to Order"];
        [self addSubview:self.sliderLabel];
    }
    return self;
}

-(void)lockSlider
{
    self.sliderLabel.alpha = 1.0;
	self.slideToUnlock.value = 0.0;
    UNLOCKED = NO;
}

-(void)fadeLabel
{
	self.sliderLabel.alpha = 1.0 - self.slideToUnlock.value;
}

-(void)unlockSlider
{
	NSLog(@"Sliding: %f", self.slideToUnlock.value);
    
	if (!UNLOCKED)
    {
		if (self.slideToUnlock.value == 1.0)
        {
            NSLog(@"Slider unlocked");
			UNLOCKED = YES;
            [self.sliderDelegate sliderDidFinishUnlocking];
		}
        else
        {
            NSLog(@"Slide Cancelled");
			// user did not slide far enough, so return back to 0 position
			[UIView beginAnimations: @"SlideCanceled" context: nil];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDuration: 0.35];
			// use CurveEaseOut to create "spring" effect
			[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
			self.slideToUnlock.value = 0.0;
			[UIView commitAnimations];
            
            self.sliderLabel.alpha = 1.0;
		}
		
	}
	
}

@end
