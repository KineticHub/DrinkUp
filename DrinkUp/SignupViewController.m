//
//  SignupViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/5/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SignupViewController.h"
#import "SharedDataHandler.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "QBFlatButton.h"

#import "UIColor+FlatUI.h"
#import "FUIButton.h"
#import "FUIAlertView.h"
#import "UIFont+FlatUI.h"

@interface SignupViewController ()
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *passwordRetypeField;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_thread"]]];
    [self.view setBackgroundColor:[UIColor cloudsColor]];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    CGFloat y = 10.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 35.0;
    
    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkUpLabel setTextColor:[UIColor blackColor]];
    [drinkUpLabel setText:@"Sign Up"];
    [self.view addSubview:drinkUpLabel];
    
    y += drinkUpLabel.frame.size.height + spacer;
    
//    UIView *coloredBgView1 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [coloredBgView1 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView1.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView1.layer setBorderWidth:3.0];
//    [coloredBgView1.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView1];
    
    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.emailField setPlaceholder:@"Email Address"];
    [self.emailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.emailField.backgroundColor = [UIColor silverColor];
    self.emailField.layer.cornerRadius = 3.0f;
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.emailField.leftView = leftView1;
    [self.emailField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.emailField];
    
    y += self.emailField.frame.size.height + spacer;
    
//    UIView *coloredBgView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [coloredBgView2 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView2.layer setBorderWidth:3.0];
//    [coloredBgView2.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView2];
    
    self.userNameField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.userNameField setPlaceholder:@"Username"];
    [self.userNameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.userNameField.backgroundColor = [UIColor silverColor];
    self.userNameField.layer.cornerRadius = 3.0f;
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.userNameField.leftView = leftView2;
    [self.userNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.userNameField];
    
    y += self.userNameField.frame.size.height + spacer;
    
//    self.firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [self.firstNameField setPlaceholder:@"First Name"];
//    [self.view addSubview:self.firstNameField];
//    y += self.firstNameField.frame.size.height + spacer;
    
//    self.lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [self.lastNameField setPlaceholder:@"Last Name"];
//    [self.view addSubview:self.lastNameField];
//    y += self.lastNameField.frame.size.height + spacer;
    
    CGFloat halfField = round(fieldWidth/2);
    
//    UIView *coloredBgView3 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, halfField - 1.0, fieldHeight)];
//    [coloredBgView3 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView3.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView3.layer setBorderWidth:3.0];
//    [coloredBgView3.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView3];
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, halfField - 10.0, fieldHeight)];
    [self.passwordField setPlaceholder:@"Password"];
    [self.passwordField setSecureTextEntry:YES];
    [self.passwordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.passwordField.backgroundColor = [UIColor silverColor];
    self.passwordField.layer.cornerRadius = 3.0f;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.passwordField.leftView = leftView3;
    [self.passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.passwordField];
    
//    y += self.passwordField.frame.size.height + spacer;
    
//    UIView *coloredBgView4 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(coloredBgView3.frame) + 1.0, y, halfField - 1.0, fieldHeight)];
//    [coloredBgView4 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView4.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView4.layer setBorderWidth:3.0];
//    [coloredBgView4.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView4];
    
    self.passwordRetypeField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.passwordField.frame) + 5.0, y, halfField - 14.0, fieldHeight)];
    [self.passwordRetypeField setPlaceholder:@"Confirm Password"];
    [self.passwordRetypeField setSecureTextEntry:YES];
    [self.passwordRetypeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.passwordRetypeField.backgroundColor = [UIColor silverColor];
    self.passwordRetypeField.layer.cornerRadius = 3.0f;
    self.passwordRetypeField.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.passwordRetypeField.leftView = leftView4;
    [self.passwordRetypeField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.passwordRetypeField];
    
    y += self.passwordRetypeField.frame.size.height + spacer * 2 - spacer/2;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setFrame:CGRectMake(edgeInset, y, fieldWidth, 45)];
    [doneButton setTitle:@"SignUp" forState:UIControlStateNormal];
    [doneButton addTarget:self  action:@selector(signupOnServer) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:doneButton];
    
    FUIButton *createAccountButton = [[FUIButton alloc] initWithFrame:CGRectMake(0.0, y, self.view.frame.size.width, fieldHeight + 20.0)];
    createAccountButton.buttonColor = [UIColor midnightBlueColor];
    createAccountButton.titleLabel.font = [UIFont boldFlatFontOfSize:22];
    [createAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [createAccountButton addTarget:self action:@selector(signupOnServer) forControlEvents:UIControlEventTouchUpInside];
    [createAccountButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [createAccountButton setTitleColor:[UIColor concreteColor] forState:UIControlStateHighlighted];
    [self.view addSubview:createAccountButton];
    
    y += createAccountButton.frame.size.height;
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, 30.0)];
    [newLabel setText:@"OR"];
    [newLabel setTextAlignment:NSTextAlignmentCenter];
    [newLabel setBackgroundColor:[UIColor clearColor]];
    [newLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:newLabel];
    
    y += newLabel.frame.size.height + 5.0;
    
    FUIButton *facebookButton = [[FUIButton alloc] initWithFrame:CGRectMake(0.0, y, self.view.frame.size.width, fieldHeight + 20.0)];
    facebookButton.buttonColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(200/255.0) alpha:1.0];
    facebookButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [facebookButton setTitle:@"Facebook Sign Up" forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [facebookButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor concreteColor] forState:UIControlStateHighlighted];
    [self.view addSubview:facebookButton];
    
    y += facebookButton.frame.size.height + spacer;
    
//    QBFlatButton *cancelButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    cancelButton.faceColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
//    cancelButton.sideColor = [UIColor colorWithRed:(170/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
//    cancelButton.radius = 6.0;
//    cancelButton.margin = 4.0;
//    cancelButton.depth = 3.0;
//    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [cancelButton setFrame:CGRectMake(edgeInset, y, fieldWidth, 45.0)];
//    [cancelButton addTarget:self action:@selector(leaveSignUpView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:cancelButton];
    
    FUIButton *cancelButton = [[FUIButton alloc] initWithFrame:CGRectMake(edgeInset, y, 80.0, 40.0)];
    [cancelButton setCenter:CGPointMake(self.view.center.x, cancelButton.center.y)];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor pomegranateColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(leaveSignUpView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];

}

-(void)leaveSignUpView
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)signupOnServer
{
    [self hideKeyboard];
    
    if ([self.userNameField.text length] > 0 && [self.emailField.text length] > 0 && [self.passwordField.text length] > 0 && [self.passwordRetypeField.text length] > 0)
    {
        if ([self.passwordField.text isEqualToString:self.passwordRetypeField.text])
        {
            NSArray *paramObjects = @[self.emailField.text, self.userNameField.text, self.passwordField.text];
            NSArray *paramKeys = @[@"email", @"username", @"password"];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:paramObjects forKeys:paramKeys];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Signing Up";
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [[SharedDataHandler sharedInstance] userCreateOnServer:params withSuccess:^(bool successful)
                 {
                     if (successful)
                     {
                         [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
                         }];
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     });
                     
                 }];
            });
        } else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Passwords Mismatch"
                                                              message:@"The password fields do not match. Please type the same password for both password fields."
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
            [message show];
        }
        
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Missing Fields"
                                                          message:@"Please make sure you have entered information for each field."
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
    }
}

-(void)loginWithFacebook:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookAuthorized:)
                                                 name:@"FacebookServerLoginAuthorized"
                                               object:nil];
    
    [[SharedDataHandler sharedInstance] authorizeFacebook];
}

-(void)facebookAuthorized:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{}];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    [self.emailField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.passwordRetypeField resignFirstResponder];
}

@end
