//
//  UserLoginViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/26/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "UserLoginViewController.h"
#import "SharedDataHandler.h"
#import "FBConnect.h"
#import "SignupViewController.h"

@interface UserLoginViewController ()
@property (nonatomic, strong) UITextField *loginUsernameOrEmailField;
@property (nonatomic, strong) UITextField *loginPasswordField;
@end

@implementation UserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[SharedDataHandler sharedInstance] initializeFacebook];
//    Facebook *facebook = [[SharedDataHandler sharedInstance] facebookInstance];
    
    CGFloat y = 20.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 45.0;
    
    UIButton *facebookLoginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [facebookLoginButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [facebookLoginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [facebookLoginButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookLoginButton];
    y += facebookLoginButton.frame.size.height + spacer;
    
    if ([[SharedDataHandler sharedInstance].facebookInstance isSessionValid]) {
        [facebookLoginButton setTitle:@"Logout of Facebook" forState:UIControlStateNormal];
        [facebookLoginButton addTarget:self action:@selector(logoutFacebook:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.loginUsernameOrEmailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.loginUsernameOrEmailField setPlaceholder:@"Email"];
    [self.view addSubview:self.loginUsernameOrEmailField];
    y += self.loginUsernameOrEmailField.frame.size.height + spacer;
    
    self.loginPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.loginPasswordField setPlaceholder:@"Password"];
    [self.view addSubview:self.loginPasswordField];
    y += self.loginPasswordField.frame.size.height + spacer;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [loginButton setTitle:@"Login to DrinkUp" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    y += loginButton.frame.size.height + spacer;
    
    UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [signupButton setTitle:@"SignUp for DrinkUp" forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [signupButton addTarget:self action:@selector(showSignupView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signupButton];
    y += signupButton.frame.size.height + spacer;
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [logoutButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutFromServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
}

-(void)loginWithFacebook:(id)sender
{
    [[SharedDataHandler sharedInstance] authorizeFacebook];
    
    UIButton *fb_button = (UIButton *)sender;
    [fb_button setTitle:@"Logout of Facebook" forState:UIControlStateNormal];
    [fb_button addTarget:self action:@selector(logoutFacebook:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)logoutFacebook:(id)sender {
    
    [[SharedDataHandler sharedInstance].facebookInstance logout];
    
    UIButton *fb_button = (UIButton *)sender;
    [fb_button setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [fb_button addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)loginToServer:(id)sender {
    
    NSMutableDictionary *creds = [[NSMutableDictionary alloc] init];
    
    [creds setObject:self.loginUsernameOrEmailField.text forKey:@"username"];
    [creds setObject:self.loginPasswordField.text forKey:@"password"];
    
    [[SharedDataHandler sharedInstance] userLoginToServerWithCredentials:creds];
}

-(void)logoutFromServer:(id)sender {
    NSLog(@"Logout attempt");
    [[SharedDataHandler sharedInstance] userLogoutOfServer];
}

-(void)showSignupView {
    SignupViewController *suvc = [[SignupViewController alloc] init];
    [self.navigationController pushViewController:suvc animated:YES];
}

-(void)postToFacebookWall:(id)sender {
    
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I'm not convinced I'm not an actual wolf when I'm wearing my hat.", @"message", nil];
//    [[[SharedDataHandler sharedInstance] facebookInstance] dialog:@"feed" andParams:params andDelegate:[SharedDataHandler sharedInstance]];
//    [[[SharedDataHandler sharedInstance] facebookInstance] requestWithMethodName:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:[SharedDataHandler sharedInstance]];
}

- (void)logoutButtonClicked:(id)sender {
    // Method that gets called when the logout button is pressed
//    [[[SharedDataHandler sharedInstance] facebookInstance] logout];
}

@end
