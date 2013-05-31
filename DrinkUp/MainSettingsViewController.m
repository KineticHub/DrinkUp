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
#import "CreditCardProfileViewController.h"
#import "SharedDataHandler.h"

@interface MainSettingsViewController ()
@property (nonatomic, strong) NSMutableArray *settings;
@property (nonatomic, strong) NSMutableArray *settingsDetails;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *requiresUser;
@end

@implementation MainSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"stressed_linen"]]];
    [self.view setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:1.0]];
    
    self.settings = [NSMutableArray arrayWithArray:@[@"DrinkUp Profile", @"Payment", @"Photo", @"About DrinkUp"]];
    self.settingsDetails = [NSMutableArray arrayWithArray:@[@"", @"Manage your credit card options", @"Help the bartender recognize you!", @""]];
    self.requiresUser = [NSMutableArray arrayWithArray:@[@NO, @YES, @YES, @NO]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setRowHeight:70.0];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthorized)
                                                 name:@"UserAuthorized"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDeauthorized)
                                                 name:@"UserDeauthorized"
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - User

-(void)userAuthorized
{
    [self.tableView reloadData];
}

-(void)userDeauthorized
{
    [self.tableView reloadData];
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
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
	}
    
    cell.textLabel.text = [self.settings objectAtIndex:[indexPath row]];
    cell.detailTextLabel.text = [self.settingsDetails objectAtIndex:[indexPath row]];
    
    if (![SharedDataHandler sharedInstance].isUserAuthenticated && [[self.requiresUser objectAtIndex:indexPath.row] boolValue])
    {
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
        cell.detailTextLabel.enabled = NO;
    } else
    {
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled = YES;
        cell.detailTextLabel.enabled = YES;
    }
    
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
            CreditCardProfileViewController *ccpvc = [[CreditCardProfileViewController alloc] init];
            [self.navigationController pushViewController:ccpvc animated:YES];
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
