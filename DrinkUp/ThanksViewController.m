//
//  ThanksViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/18/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "ThanksViewController.h"
#import "BSTDrinkTypeViewController.h"
#import "SharedDataHandler.h"
#import "CollapsableDrinkViewController.h"
#import "UIColor+FlatUI.h"
#import "KUIHelper.h"

@interface ThanksViewController ()
@property (nonatomic, strong) UILabel *claimLabel;
@end

@implementation ThanksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.title = @"Order Number";
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCurrentlyOnThanksViewController"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Drinks Claimed!" style:UIBarButtonItemStyleDone target:self action:@selector(confirmOrderReceived)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    CGFloat yPosition = 20.0;
    CGFloat edgeInset = 10.0;
    CGFloat labelWidth = 300.0;
    CGFloat labelHeight = 30.0;
    CGFloat spacer = 10.0;
    
    UILabel *thanksLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, yPosition, labelWidth, labelHeight)];
    [thanksLabel setText:@"Thanks for using DrinkUp!"];
    [thanksLabel setTextAlignment:NSTextAlignmentCenter];
    [thanksLabel setTextColor:[UIColor blackColor]];
    [thanksLabel setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:thanksLabel];
    yPosition += labelHeight + spacer;
    
    UILabel *claimInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, yPosition, labelWidth, labelHeight)];
    [claimInfoLabel setText:@"Show this code to the bartender to claim your drink:"];
    [claimInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [claimInfoLabel setTextColor:[UIColor blackColor]];
    [claimInfoLabel setBackgroundColor:[UIColor clearColor]];
    [claimInfoLabel setAdjustsFontSizeToFitWidth:YES];
//    [self.view addSubview:claimInfoLabel];
    
    self.claimLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, yPosition * 2, labelWidth, labelHeight * 4)];
    [self.claimLabel setText:[SharedDataHandler sharedInstance].currentOrderID];
    [self.claimLabel setTextAlignment:NSTextAlignmentCenter];
    [self.claimLabel setTextColor:[UIColor midnightBlueColor]];
    [self.claimLabel setFont:[UIFont systemFontOfSize:150.0]];
    [self.claimLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.claimLabel];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"redirectedFromNotification"]) {
        NSString *message = @"We'll notify you when your order is ready.  Show the number at the pick up area to claim your order.";
        [[KUIHelper createAlertViewWithTitle:@"Order Placed"
                                     message:message
                                    delegate:nil
                           cancelButtonTitle:@"Cool Beans"
                           otherButtonTitles:nil] show];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"redirectedFromNotification"];
    }
}

-(void)orderReadyUpdate {
    [self.claimLabel setTextColor:[UIColor greenColor]];
}

-(void)drinkOrderCompleteExit {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCurrentlyOnThanksViewController"];
    
    bool found = NO;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CollapsableDrinkViewController class]]) {
            found = YES;
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
    
    if (!found) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)confirmOrderReceived
{
    [[KUIHelper createAlertViewWithTitle:@"Order Claimed?"
                                message:@"Did you claim your order?"
                               delegate:self
                       cancelButtonTitle:@"Not yet"
                       otherButtonTitles:@"Yup!", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Not yet"])
    {
        NSLog(@"Not yet drink claimed");
    }
    else if([title isEqualToString:@"Yup!"])
    {
        NSLog(@"Drink order claimed");
        [self drinkOrderCompleteExit];
    }
}

@end
