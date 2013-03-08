//
//  SignupViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/5/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "SignupViewController.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface SignupViewController ()
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *passwordRetypeField;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat y = 20.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 30.0;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    headerLabel.text = @"SignUp for DrinkUp";
    [self.view addSubview:headerLabel];
    y += headerLabel.frame.size.height + spacer;
    
    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.emailField setPlaceholder:@"Email Address"];
    [self.view addSubview:self.emailField];
    y += self.emailField.frame.size.height + spacer;
    
    self.firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.firstNameField setPlaceholder:@"First Name"];
    [self.view addSubview:self.firstNameField];
    y += self.firstNameField.frame.size.height + spacer;
    
    self.lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.lastNameField setPlaceholder:@"Last Name"];
    [self.view addSubview:self.lastNameField];
    y += self.lastNameField.frame.size.height + spacer;
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.passwordField setPlaceholder:@"Password"];
    [self.view addSubview:self.passwordField];
    y += self.passwordField.frame.size.height + spacer;
    
    self.passwordRetypeField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [self.passwordRetypeField setPlaceholder:@"Retype Password"];
    [self.view addSubview:self.passwordRetypeField];
    y += self.passwordRetypeField.frame.size.height + spacer;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setFrame:CGRectMake(edgeInset, y, fieldWidth, 45)];
    [doneButton setTitle:@"SignUp" forState:UIControlStateNormal];
    [doneButton addTarget:self  action:@selector(signupOnServer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
}

-(void)signupOnServer {
    
    NSArray *paramObjects = @[self.emailField.text, self.firstNameField.text, self.lastNameField.text, self.passwordField.text];
    NSArray *paramKeys = @[@"email", @"first_name", @"last_name", @"password"];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:paramObjects forKeys:paramKeys];
    
    NSString *requestPath = @"http://ec2-174-129-129-68.compute-1.amazonaws.com/Project/facebook_login/mobile/";
    NSURL *url = [NSURL URLWithString:[requestPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableURLRequest *request2 = [client requestWithMethod:@"GET" path:@"" parameters:params];
    [ request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        NSLog(@"response string: %@ ", operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
}

@end
