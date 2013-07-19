//
//  KUIHelper.h
//  DrinkUp
//
//  Created by Kinetic on 7/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUIAlertView.h"
#import "FUIButton.h"

@interface KUIHelper : NSObject

+(UIColor *) getAppBackgroundColor;

+(FUIButton *)createFlatButtonWithRect:(CGRect)rect andTitle:(NSString *)title;
+(FUIButton *)createBannerButtonWithRect:(CGRect)rect andTitle:(NSString *)title;

+(FUIAlertView *)createAlertViewWithTitle:(NSString *)title
                                  message:(NSString *)message
                                 delegate:(id<FUIAlertViewDelegate>)delegate
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                        otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+(UITextField *)createCommonTextFieldWithRect:(CGRect)rect andPlaceholder:(NSString *)placeholder;
+(UITextField *)createPasswordFieldWithRect:(CGRect)rect andPlaceholder:(NSString *)placeholder;
@end
