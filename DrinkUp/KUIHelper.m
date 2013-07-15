//
//  KUIHelper.m
//  DrinkUp
//
//  Created by Kinetic on 7/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "KUIHelper.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@implementation KUIHelper
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

@end
