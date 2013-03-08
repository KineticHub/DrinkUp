//
//  BarsViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "RecentBarsViewController.h"

#import "BSTNearbyBarsViewController.h"

#import "UserLoginViewController.h"

@interface RecentBarsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation RecentBarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
	}
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %i", [indexPath row]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell Chosen %i", [indexPath row]);
    
    UserLoginViewController *ulvc = [[UserLoginViewController alloc] init];
    [self.navigationController pushViewController:ulvc animated:YES];
}

#pragma mark - Segment Control Method

-(void)segControlsValueChanged:(id)sender {
    
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    NSLog(@"Value: %i", segControl.selectedSegmentIndex);
}

@end
