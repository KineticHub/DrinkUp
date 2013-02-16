//
//  SettingsScreenViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "MainSettingsViewController.h"

@interface MainSettingsViewController ()
@property (nonatomic, strong) NSMutableArray *settings;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MainSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.settings = [NSMutableArray arrayWithArray:@[@"Login with Facebook", @"Payment", @"About DrinkUp", @"Edit My Weight", @"Photo"]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.view addSubview:self.tableView];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settings count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
	}
    
    cell.textLabel.text = [self.settings objectAtIndex:[indexPath row]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell Chosen %@", [self.settings objectAtIndex:[indexPath row]]);
}

@end
