//
//  SelectBarViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "DrinkHistoryViewController.h"

@interface DrinkHistoryViewController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation DrinkHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat topViewHeight = 50.0;
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    UIView *topSection = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, topViewHeight)];
    [topSection setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:topSection];
    
    UISegmentedControl *segControls = [[UISegmentedControl alloc] initWithItems:@[@"Tonight", @"This Week", @"Forever"]];
    [segControls setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
    [segControls addTarget:self action:@selector(segControlsValueChanged:) forControlEvents: UIControlEventValueChanged];
    [topSection addSubview:segControls];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0 + topViewHeight, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - topViewHeight) style:UITableViewStyleGrouped];
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
    return 3;
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
}

#pragma mark - Segment Control Method

-(void)segControlsValueChanged:(id)sender {
    
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    NSLog(@"Value: %i", segControl.selectedSegmentIndex);
}

@end
