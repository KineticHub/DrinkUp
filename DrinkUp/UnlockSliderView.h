//
//  UnlockSliderView.h
//  DrinkUp
//
//  Created by Kinetic on 7/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UnlockSliderDelegate;

@interface UnlockSliderView : UIView
- (id)initWithFrame:(CGRect)frame andDelegate:(id)sliderDelegate;
-(void)lockSlider;
@end

@protocol UnlockSliderDelegate <NSObject>
@required
- (void)sliderDidFinishUnlocking;
@end
