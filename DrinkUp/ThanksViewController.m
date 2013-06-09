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

@interface ThanksViewController ()
@property (nonatomic, strong) UILabel *claimLabel;
@end

@implementation ThanksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [thanksLabel setTextColor:[UIColor whiteColor]];
    [thanksLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:thanksLabel];
    yPosition += labelHeight + spacer;
    
    UILabel *claimInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, yPosition, labelWidth, labelHeight)];
    [claimInfoLabel setText:@"Your code to claim your order is"];
    [claimInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [claimInfoLabel setTextColor:[UIColor whiteColor]];
    [claimInfoLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:claimInfoLabel];
    
    self.claimLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, yPosition * 2, labelWidth, labelHeight * 4)];
    [self.claimLabel setText:[SharedDataHandler sharedInstance].currentOrderID];
    [self.claimLabel setTextAlignment:NSTextAlignmentCenter];
    [self.claimLabel setTextColor:[UIColor orangeColor]];
    [self.claimLabel setFont:[UIFont systemFontOfSize:120.0]];
    [self.claimLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.claimLabel];
}

-(void)orderReadyUpdate {
    [self.claimLabel setTextColor:[UIColor greenColor]];
}

-(void)drinkOrderCompleteExit {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CollapsableDrinkViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

-(void)confirmOrderReceived
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Order Claimed?"
                                                      message:@"Did you claim your order?"
                                                     delegate:self
                                            cancelButtonTitle:@"Not yet"
                                            otherButtonTitles:@"Yup!", nil];
    [message show];
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
