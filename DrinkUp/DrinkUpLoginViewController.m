//
//  DrinkUpLoginViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/2/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DrinkUpLoginViewController.h"
#import "ForgotPasswordViewController.h"
#import "MBProgressHUD.h"
#import "SharedDataHandler.h"
#import "UIColor+FlatUI.h"
#import "FUIAlertView.h"
#import "FUIButton.h"
#import "UIFont+FlatUI.h"
#import "KUIHelper.h"

@interface DrinkUpLoginViewController ()
@property (nonatomic, strong) UITextField *loginUsernameOrEmailField;
@property (nonatomic, strong) UITextField *loginPasswordField;
@end

@implementation DrinkUpLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[KUIHelper getAppBackgroundColor]];
    self.navigationItem.title = @"DrinkUp Login";
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    CGFloat y = 15.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 15.0;
    CGFloat fieldWidth = 290.0;
    CGFloat fieldHeight = 40.0;

    self.loginUsernameOrEmailField = [KUIHelper createCommonTextFieldWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight) andPlaceholder:@"Email"];
    [self.view addSubview:self.loginUsernameOrEmailField];
    y += self.loginUsernameOrEmailField.frame.size.height + spacer - 3.0;

    self.loginPasswordField = [KUIHelper createPasswordFieldWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight) andPlaceholder:@"Password"];
    [self.view addSubview:self.loginPasswordField];
    y += self.loginPasswordField.frame.size.height + spacer + 2.0;

    FUIButton *loginButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 15.0)
                                                          andTitle:@"Log In"];
    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    y += loginButton.frame.size.height + spacer - 3.0;
    
    UIView *firstTimeContainer = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - fieldHeight * 3, fieldWidth, fieldHeight * 3)];
    [firstTimeContainer setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:firstTimeContainer];
    
    UILabel *firstTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight)];
    [firstTimeLabel setText:@"Trouble logging in?"];
    [firstTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [firstTimeLabel setBackgroundColor:[UIColor clearColor]];
    [firstTimeLabel setTextColor:[UIColor blackColor]];
    [firstTimeContainer addSubview:firstTimeLabel];
    
    FUIButton *forgotButton = [KUIHelper createBannerButtonWithRect:CGRectMake(0, CGRectGetMaxY(firstTimeLabel.frame) + 5.0, fieldWidth, fieldHeight)
                                                           andTitle:@"Forgot Password"];
    [forgotButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [firstTimeContainer addSubview:forgotButton];
}

-(void)forgotPassword:(id)sender
{
    ForgotPasswordViewController *forgotPasswordVC = [[ForgotPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgotPasswordVC animated:YES];
}

-(void)leaveSignUpView
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)loginToServer:(id)sender
{
    [self hideKeyboard];
    
    if ([self.loginUsernameOrEmailField.text length] > 0 && [self.loginPasswordField.text length] > 0)
    {
        NSMutableDictionary *creds = [[NSMutableDictionary alloc] init];
        [creds setObject:self.loginUsernameOrEmailField.text forKey:@"username"];
        [creds setObject:self.loginPasswordField.text forKey:@"password"];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Logging In";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [[SharedDataHandler sharedInstance] userLoginToServerWithCredentials:creds andCompletion:^(bool successful)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 });
                 
                 if (successful)
                 {
                     [self.navigationController popViewControllerAnimated:YES];
                 } else {
                     [[KUIHelper createAlertViewWithTitle:@"Login Failed"
                                                 message:@"Please check your username and password and try again."
                                                delegate:self
                                       cancelButtonTitle:@"Okay"
                                        otherButtonTitles:nil] show];
                     
                 }
             }];
        });
    } else {
        [[KUIHelper createAlertViewWithTitle:@"Missing Fields"
                                     message:@"Please make sure you have entered a username and password."
                                    delegate:self
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
    }
}

#pragma mark - UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) hideKeyboard
{
    [self.loginUsernameOrEmailField resignFirstResponder];
    [self.loginPasswordField resignFirstResponder];
}

@end
