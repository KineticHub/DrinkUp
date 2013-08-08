//
//  ForgotPasswordViewController.m
//  DrinkUp
//
//  Created by Kinetic on 7/29/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "SharedDataHandler.h"
#import "UIColor+FlatUI.h"
#import "FUIAlertView.h"
#import "FUIButton.h"
#import "UIFont+FlatUI.h"
#import "KUIHelper.h"

@interface ForgotPasswordViewController ()
@property (nonatomic, strong) UITextField *userEmailField;
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[KUIHelper getAppBackgroundColor]];
    self.navigationItem.title = @"DrinkUp Login";
    self.navigationController.navigationBar.topItem.title = @"Login";
    
    UIBarButtonItem *resetPasswordBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(resetPassword:)];
    
    self.navigationItem.rightBarButtonItem = resetPasswordBarButton;
    
    CGFloat y = 5.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 15.0;
    CGFloat fieldWidth = 290.0;
    CGFloat fieldHeight = 40.0;
    
    UILabel *resetPasswordLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight * 3)];
    [resetPasswordLabel setText:@"Just type in the email that is connected to your DrinkUp account and we will send an email to help you reset your password."];
    [resetPasswordLabel setTextAlignment:NSTextAlignmentCenter];
    [resetPasswordLabel setBackgroundColor:[UIColor clearColor]];
    [resetPasswordLabel setTextColor:[UIColor blackColor]];
    [resetPasswordLabel setNumberOfLines:4];
    [self.view addSubview:resetPasswordLabel];
    y += resetPasswordLabel.frame.size.height + spacer;
    
    self.userEmailField = [KUIHelper createCommonTextFieldWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight) andPlaceholder:@"Email"];
    [self.view addSubview:self.userEmailField];
    y += self.userEmailField.frame.size.height + spacer;
    
    [self.userEmailField becomeFirstResponder];
}

-(void)resetPassword:(id)sender
{
    [self.userEmailField resignFirstResponder];
    
    [[SharedDataHandler sharedInstance] userForgotPassword:[NSMutableDictionary dictionaryWithDictionary:@{@"email": self.userEmailField.text}] andCompletion:^(bool successful)
     {
         if (successful)
         {
             NSLog(@"Password reset email sent");
             [[KUIHelper createAlertViewWithTitle:@"Email Sent"
                                          message:@"An email has been sent to help you reset your password."
                                         delegate:nil
                                cancelButtonTitle:@"Okay"
                                otherButtonTitles:nil] show];
             
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             NSLog(@"Password reset failed");
         }
     }];
}

@end
