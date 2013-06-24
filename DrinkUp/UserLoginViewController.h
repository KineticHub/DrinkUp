//
//  UserLoginViewController.h
//  DrinkUp
//
//  Created by Kinetic on 2/26/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "FacebookSDK.h"

@interface UserLoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error;
@end
