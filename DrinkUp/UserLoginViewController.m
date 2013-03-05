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

@interface UserLoginViewController ()

@end

@implementation UserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SharedDataHandler sharedInstance] initializeFacebook];
    Facebook *facebook = [[SharedDataHandler sharedInstance] facebookInstance];
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [postButton setFrame:CGRectMake(0, 0, 100, 45)];
    [postButton setTitle:@"Post to Facebook" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postToFacebookWall:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postButton];
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [logoutButton setFrame:CGRectMake(0, 60, 100, 45)];
    [logoutButton setTitle:@"Logout Facebook" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
}

-(void)loginToServer {
    
}

-(void)logoutFromServer {
    
}

-(void)postToFacebookWall:(id)sender {
    
    //NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I'm not convinced I'm not an actual wolf when I'm wearing my hat.", @"message", nil];
//    [[[SharedDataHandler sharedInstance] facebookInstance] dialog:@"feed" andParams:params andDelegate:[SharedDataHandler sharedInstance]];
    //[[[SharedDataHandler sharedInstance] facebookInstance] requestWithMethodName:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:[SharedDataHandler sharedInstance]];
}

- (void)logoutButtonClicked:(id)sender {
    // Method that gets called when the logout button is pressed
//    [[[SharedDataHandler sharedInstance] facebookInstance] logout];
}

@end
