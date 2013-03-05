//
//  NearbyBarsViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "NearbyBarsViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "SharedDataHandler.h"

#import "DrinksTypeViewController.h"

@interface NearbyBarsViewController ()
@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation NearbyBarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    self.bars = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadBars:^(NSMutableArray *objects) {

            self.bars = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
    
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
    return [self.bars count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
	}
    
    NSDictionary *bar = [self.bars objectAtIndex:[indexPath row]];
    cell.textLabel.text = [bar objectForKey:@"name"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:[bar objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *selectedBar = [self.bars objectAtIndex:[indexPath row]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadBarSectionsForBar:[[selectedBar objectForKey:@"id"] intValue] onCompletion:^(NSMutableArray *objects) {
            
            if ([objects count] == 1) {
                NSDictionary *barSection = [objects objectAtIndex:0];
                [SharedDataHandler sharedInstance].current_section = [[barSection objectForKey:@"id"] intValue];
                DrinksTypeViewController *dtvc = [[DrinksTypeViewController alloc] initWithBarSection:[[barSection objectForKey:@"id"] intValue]];
                [self.navigationController pushViewController:dtvc animated:YES];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

@end
