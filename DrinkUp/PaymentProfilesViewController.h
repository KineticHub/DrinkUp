//
//  PaymentProfilesViewController.h
//  DrinkUp
//
//  Created by Kinetic on 3/5/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"

@interface PaymentProfilesViewController : UIViewController <CardIOPaymentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end
