//
//  OrderHistorySelectionViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/4/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "OrderHistorySelectionViewController.h"
#import "MBProgressHUD.h"
#import "SharedDataHandler.h"
#import "OrderHistoryCell.h"
#import "OrderHistoryInfoViewController.h"

@interface OrderHistorySelectionViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *orderHistory;
@end

@implementation OrderHistorySelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.orderHistory = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] getUserOrderHistoryWithCompletion:^(NSMutableArray *objects) {
            
            self.orderHistory = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setRowHeight:100.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    [self.view addSubview:self.tableView];
}

#pragma mark - TableView DataSource Methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 25.0;
    }
    
    return 0.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *nearbyView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 25.0)];
    [nearbyView setBackgroundColor:[UIColor darkGrayColor]];
    [nearbyView setAlpha:0.8];
    
    UILabel *nearbyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 15.0)];
    [nearbyLabel setCenter:CGPointMake(nearbyLabel.center.x, nearbyView.center.y)];
    [nearbyLabel setFont:[UIFont systemFontOfSize:14.0]];
    [nearbyLabel setBackgroundColor:[UIColor clearColor]];
    [nearbyLabel setTextAlignment:NSTextAlignmentCenter];
    [nearbyLabel setTextColor:[UIColor lightGrayColor]];
    [nearbyLabel setText:@"Order History"];
    [nearbyView addSubview:nearbyLabel];
    
    return nearbyView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.orderHistory count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OrderHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[OrderHistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
	}
    
    NSDictionary *order = [self.orderHistory objectAtIndex:[indexPath section]];
    NSLog(@"order for cell: %@", order);
    
    cell.textLabel.text = [NSString stringWithFormat:@"ORDER ID #%@", [order objectForKey:@"id"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[order objectForKey:@"created"] substringToIndex:10], [order objectForKey:@"venue_name"]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    OrderHistoryInfoViewController *orderInfoVC = [[OrderHistoryInfoViewController alloc] initWithOrder:[self.orderHistory objectAtIndex:[indexPath section]]];
    [self.navigationController pushViewController:orderInfoVC animated:YES];
}

@end
