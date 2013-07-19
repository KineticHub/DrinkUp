//
//  CreditCardProfileViewController.h
//  DrinkUp
//
//  Created by Kinetic on 5/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"
#import "FUIAlertView.h"

@interface CreditCardProfileViewController : UIViewController <FUIAlertViewDelegate, CardIOPaymentViewControllerDelegate>

@end
