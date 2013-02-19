//
//  FindBarSearchViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "FindBarSearchViewController.h"

@interface FindBarSearchViewController ()

@end

@implementation FindBarSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITextField *barNameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 20, 300, 20)];
    [barNameField setPlaceholder:@"Name of the Bar (optional)"];
    [barNameField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:barNameField];
    
    UITextField *cityOrZipField = [[UITextField alloc] initWithFrame:CGRectMake(10, 60, 300, 20)];
    [cityOrZipField setPlaceholder:@"City or Zip Code"];
    [cityOrZipField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:cityOrZipField];
}

@end
