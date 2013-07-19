//
//  KUIHelper.m
//  DrinkUp
//
//  Created by Kinetic on 7/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KUIHelper.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@implementation KUIHelper

+(UIColor *) getAppBackgroundColor
{
    return [UIColor cloudsColor];
}

+(FUIButton *)createFlatButtonWithRect:(CGRect)rect andTitle:(NSString *)title
{
    FUIButton *flatButton = [[FUIButton alloc] initWithFrame:rect];
    [flatButton setTitle:title forState:UIControlStateNormal];
    flatButton.buttonColor = [UIColor midnightBlueColor];
    flatButton.shadowColor = [UIColor blackColor];
    flatButton.shadowHeight = 3.0f;
    flatButton.cornerRadius = 6.0f;
    flatButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [flatButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [flatButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    return flatButton;
}

+(FUIButton *)createBannerButtonWithRect:(CGRect)rect andTitle:(NSString *)title
{
    FUIButton *bannerButton = [[FUIButton alloc] initWithFrame:rect];
    bannerButton.buttonColor = [UIColor midnightBlueColor];
    bannerButton.titleLabel.font = [UIFont boldFlatFontOfSize:22];
    [bannerButton setTitle:title forState:UIControlStateNormal];
    [bannerButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [bannerButton setTitleColor:[UIColor concreteColor] forState:UIControlStateHighlighted];
    return bannerButton;
}

+(FUIAlertView *)createAlertViewWithTitle:(NSString *)title
                                  message:(NSString *)message
                                 delegate:(id<FUIAlertViewDelegate>)delegate
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                        otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    alert.titleLabel.textColor = [UIColor cloudsColor];
    alert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alert.messageLabel.textColor = [UIColor cloudsColor];
    alert.messageLabel.font = [UIFont flatFontOfSize:14];
    alert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alert.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alert.defaultButtonColor = [UIColor cloudsColor];
    alert.defaultButtonShadowColor = [UIColor asbestosColor];
    alert.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alert.defaultButtonTitleColor = [UIColor asbestosColor];
    return alert;
}

+(UITextField *)createCommonTextFieldWithRect:(CGRect)rect andPlaceholder:(NSString *)placeholder
{
    UITextField *commonTextField = [[UITextField alloc] initWithFrame:rect];
    [commonTextField setPlaceholder:placeholder];
    [commonTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    commonTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: [[UIColor midnightBlueColor] colorWithAlphaComponent:0.7]}];
    [commonTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    commonTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    commonTextField.leftView = leftView;
    commonTextField.backgroundColor = [UIColor silverColor];
    commonTextField.layer.cornerRadius = 3.0f;
    return commonTextField;
}

+(UITextField *)createPasswordFieldWithRect:(CGRect)rect andPlaceholder:(NSString *)placeholder
{
    UITextField *passwordTextField = [KUIHelper createCommonTextFieldWithRect:rect andPlaceholder:placeholder];
    [passwordTextField setSecureTextEntry:YES];
    return passwordTextField;
}

@end
