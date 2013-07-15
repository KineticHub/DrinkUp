//
//  KUIHelper.h
//  DrinkUp
//
//  Created by Kinetic on 7/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUIAlertView.h"

@interface KUIHelper : NSObject
+(FUIAlertView *)createAlertViewWithTitle:(NSString *)title
                                  message:(NSString *)message
                                 delegate:(id<FUIAlertViewDelegate>)delegate
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                        otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end
