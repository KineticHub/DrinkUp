//
//  SelectBarSectionViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/4/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "SelectBarSectionViewController.h"
#import "UIImageView+AFNetworking.h"
#import "BSTDrinkTypeViewController.h"

@interface SelectBarSectionViewController ()
@property (nonatomic, strong) NSMutableArray *barSections;
@end

@implementation SelectBarSectionViewController

-(id)initWithBarSections:(NSArray *)barSections {
    self = [super initWithUpperViewHieght:150.0];
    if (self) {
        self.barSections = [NSMutableArray arrayWithArray:barSections];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Bar" style:UIBarButtonItemStyleDone target:self action:@selector(showLeavingOptions)];
//    self.navigationItem.leftBarButtonItem = backButton;
//    
//    self.drinkTypes = [[NSMutableArray alloc] init];
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        
//        [[SharedDataHandler sharedInstance] loadDrinkTypesForBarSection:self.section_id onCompletion:^(NSMutableArray *objects) {
//            self.drinkTypes = [NSMutableArray arrayWithArray:objects];
//            [self.tableView reloadData];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//        }];
//    });
//    
//    UIView *barNameTitleBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)];
//    [barNameTitleBar setBackgroundColor:[UIColor blackColor]];
//    //    [self.upperView addSubview:barNameTitleBar];
//    
//    UILabel *barNameTitle = [[UILabel alloc] initWithFrame:barNameTitleBar.frame];
//    [barNameTitle setText:@"Top of the Stairs"];
//    [barNameTitle setTextAlignment:NSTextAlignmentCenter];
//    [barNameTitle setTextColor:[UIColor whiteColor]];
//    [barNameTitle setBackgroundColor:[UIColor clearColor]];
//    [barNameTitleBar addSubview:barNameTitle];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 120.0)];
    [logoImageView setCenter:CGPointMake(self.upperView.center.x, self.upperView.center.y + 0.0)];
    [logoImageView setImageWithURL:[NSURL URLWithString:[[SharedDataHandler sharedInstance].currentBar objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    [self.upperView addSubview:logoImageView];
    
    [self.upperView setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.barSections count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCell *cell = (BasicCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *barSection = [self.barSections objectAtIndex:[indexPath row]];
    cell.textLabel.text = [barSection objectForKey:@"name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *barSection = [self.barSections objectAtIndex:[indexPath row]];
    [SharedDataHandler sharedInstance].current_section = [[barSection objectForKey:@"id"] intValue];
    [SharedDataHandler sharedInstance].currentBar = [NSDictionary dictionaryWithDictionary:barSection];
    
    BSTDrinkTypeViewController *selectionView = [[BSTDrinkTypeViewController alloc] initWithBarSection:[[barSection objectForKey:@"id"] intValue]];
    [self.navigationController pushViewController:selectionView animated:YES];
}

@end
