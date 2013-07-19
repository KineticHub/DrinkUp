//
//  DrinkUpLoginViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/2/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DrinkUpLoginViewController.h"
#import "MBProgressHUD.h"
#import "QBFlatButton.h"
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
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_thread"]]];
    [self.view setBackgroundColor:[KUIHelper getAppBackgroundColor]];
    self.navigationItem.title = @"DrinkUp Login";
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    CGFloat y = 15.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 15.0;
    CGFloat fieldWidth = 290.0;
    CGFloat fieldHeight = 40.0;
    
//    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
//    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
//    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
//    [drinkUpLabel setTextColor:[UIColor blackColor]];
//    [drinkUpLabel setText:@"DrinkUp Login"];
//    [self.view addSubview:drinkUpLabel];
    
//    y += drinkUpLabel.frame.size.height;
    
//    UIView *coloredBgView1 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [coloredBgView1 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView1.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView1.layer setBorderWidth:3.0];
//    [coloredBgView1.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView1];

    self.loginUsernameOrEmailField = [KUIHelper createCommonTextFieldWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight) andPlaceholder:@"Email"];
    [self.view addSubview:self.loginUsernameOrEmailField];

    y += self.loginUsernameOrEmailField.frame.size.height + spacer - 3.0;

//    UIView *coloredBgView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [coloredBgView2 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView2.layer setBorderWidth:3.0];
//    [coloredBgView2.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView2];

    self.loginPasswordField = [KUIHelper createPasswordFieldWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight) andPlaceholder:@"Password"];
    [self.view addSubview:self.loginPasswordField];
    
    y += self.loginPasswordField.frame.size.height + spacer + 2.0;
    
//    FUIButton *loginButton = [[FUIButton alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
//    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
//    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
//    loginButton.buttonColor = [UIColor midnightBlueColor];
//    loginButton.shadowColor = [UIColor blackColor];
//    loginButton.shadowHeight = 3.0f;
//    loginButton.cornerRadius = 6.0f;
//    loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
//    [loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
//    [loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
//    [self.view addSubview:loginButton];

    FUIButton *loginButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 15.0)
                                                          andTitle:@"Log In"];
    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    y += loginButton.frame.size.height + spacer - 3.0;
    
//    FUIButton *cancelButton = [[FUIButton alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, 43.0)];
//    cancelButton.buttonColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
//    cancelButton.shadowColor = [UIColor colorWithRed:(170/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
//    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    cancelButton.shadowHeight = 3.0f;
//    cancelButton.cornerRadius = 6.0f;
//    cancelButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
//    [cancelButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
//    [cancelButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
//    [cancelButton addTarget:self action:@selector(leaveSignUpView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:cancelButton];
    
    FUIButton *cancelButton = [[FUIButton alloc] initWithFrame:CGRectMake(0.0, y, 80.0, 40.0)];
    [cancelButton setCenter:CGPointMake(self.view.center.x, cancelButton.center.y)];
    cancelButton.buttonColor = [UIColor clearColor];
    cancelButton.shadowColor = [UIColor clearColor];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor pomegranateColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(leaveSignUpView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:cancelButton];
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
                     [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
                     }];
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
