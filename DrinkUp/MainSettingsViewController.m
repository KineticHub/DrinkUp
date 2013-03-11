//
//  SettingsScreenViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "MainSettingsViewController.h"
#import "UserLoginViewController.h"
#import "PaymentProfilesViewController.h"
#import "UserPictureViewController.h"
#import "TestPaymentViewController.h"

@interface MainSettingsViewController ()
@property (nonatomic, strong) NSMutableArray *settings;
@property (nonatomic, strong) NSMutableArray *settingsDetails;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MainSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.settings = [NSMutableArray arrayWithArray:@[@"Login to DrinkUp", @"Payment", @"Photo", @"About DrinkUp"]];
    self.settingsDetails = [NSMutableArray arrayWithArray:@[@"Login using Facebook or Username", @"Add or remove credit cards", @"Help the bartender recognize you!", @""]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.tableView setRowHeight:70.0];
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
        cell.detailTextLabel.numberOfLines = 0;
	}
    
    cell.textLabel.text = [self.settings objectAtIndex:[indexPath row]];
    cell.detailTextLabel.text = [self.settingsDetails objectAtIndex:[indexPath row]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell Chosen %@", [self.settings objectAtIndex:[indexPath row]]);
    
    switch ([indexPath row]) {
        case 0:
        {
            UserLoginViewController *ulvc = [[UserLoginViewController alloc] init];
            [self.navigationController pushViewController:ulvc animated:YES];
            break;
        }
        case 1:
        {
            TestPaymentViewController *ppvc = [[TestPaymentViewController alloc] init];
//            PaymentProfilesViewController *ppvc = [[PaymentProfilesViewController alloc] init];
            [self.navigationController pushViewController:ppvc animated:YES];
            break;
        }
        case 2:
        {
            UserPictureViewController *upvc = [[UserPictureViewController alloc] init];
            [self.navigationController pushViewController:upvc animated:YES];
            break;
        }
            
        default:
            break;
    }
}

@end
