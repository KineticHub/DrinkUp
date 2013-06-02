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

@interface DrinkUpLoginViewController ()
@property (nonatomic, strong) UITextField *loginUsernameOrEmailField;
@property (nonatomic, strong) UITextField *loginPasswordField;
@end

@implementation DrinkUpLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_thread"]]];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    CGFloat y = 5.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 40.0;
    
    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkUpLabel setTextColor:[UIColor whiteColor]];
    [drinkUpLabel setText:@"DrinkUp Login"];
    [self.view addSubview:drinkUpLabel];
    
    y += drinkUpLabel.frame.size.height + spacer;
    
    UIView *coloredBgView1 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [coloredBgView1 setBackgroundColor:[UIColor clearColor]];
    [coloredBgView1.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
    [coloredBgView1.layer setBorderWidth:3.0];
    [coloredBgView1.layer setCornerRadius:5.0];
    [self.view addSubview:coloredBgView1];

    self.loginUsernameOrEmailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.loginUsernameOrEmailField setPlaceholder:@"Email"];
    [self.loginUsernameOrEmailField setTextColor:[UIColor whiteColor]];
    [self.loginUsernameOrEmailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.loginUsernameOrEmailField setFont:[UIFont systemFontOfSize:16.0]];
    [self.loginUsernameOrEmailField setBackgroundColor:[UIColor clearColor]];
    [self.loginUsernameOrEmailField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.loginUsernameOrEmailField];

    y += self.loginUsernameOrEmailField.frame.size.height + spacer/2;

    UIView *coloredBgView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [coloredBgView2 setBackgroundColor:[UIColor clearColor]];
    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
    [coloredBgView2.layer setBorderWidth:3.0];
    [coloredBgView2.layer setCornerRadius:5.0];
    [self.view addSubview:coloredBgView2];

    self.loginPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.loginPasswordField setPlaceholder:@"Password"];
    [self.loginPasswordField setSecureTextEntry:YES];
    [self.loginPasswordField setTextColor:[UIColor whiteColor]];
    [self.loginPasswordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.loginPasswordField setFont:[UIFont systemFontOfSize:16.0]];
    [self.loginPasswordField setBackgroundColor:[UIColor clearColor]];
    [self.loginPasswordField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.loginPasswordField];
    
    y += self.loginPasswordField.frame.size.height + spacer;
    
    QBFlatButton *loginButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    loginButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    loginButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    loginButton.radius = 6.0;
    loginButton.margin = 4.0;
    loginButton.depth = 3.0;
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    y += loginButton.frame.size.height + spacer;
    
    QBFlatButton *cancelButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    cancelButton.faceColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
    cancelButton.sideColor = [UIColor colorWithRed:(170/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
    cancelButton.radius = 6.0;
    cancelButton.margin = 4.0;
    cancelButton.depth = 3.0;
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(edgeInset, y, fieldWidth, 45.0)];
    [cancelButton addTarget:self action:@selector(leaveSignUpView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
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
                     UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                       message:@"Please check your username and password and try again."
                                                                      delegate:self
                                                             cancelButtonTitle:@"Okay"
                                                             otherButtonTitles:nil];
                     [message show];
                 }
             }];
        });
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Missing Fields"
                                                          message:@"Please make sure you have entered a username and password."
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
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
