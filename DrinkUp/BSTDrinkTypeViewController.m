//
//  BSTDrinkTypeViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BSTDrinkTypeViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "SharedDataHandler.h"
#import "BasicCell.h"
#import "BSTDrinkSelectionViewController.h"

@interface BSTDrinkTypeViewController ()
@property (nonatomic, strong) NSMutableArray *drinkTypes;
@property int section_id;
@end

@implementation BSTDrinkTypeViewController

-(id)initWithBarSection:(int)section_id {
    self = [super init];
    if (self) {
        self.section_id = section_id;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Bar" style:UIBarButtonItemStyleDone target:self action:@selector(showLeavingOptions)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.drinkTypes = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinkTypesForBarSection:self.section_id onCompletion:^(NSMutableArray *objects) {
            self.drinkTypes = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 150.0)];
    [logoImageView setCenter:self.upperView.center];
    [logoImageView setImageWithURL:[NSURL URLWithString:[[SharedDataHandler sharedInstance].currentBar objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    [self.upperView addSubview:logoImageView];
}

-(void) showLeavingOptions {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Clear Selected Drinks?"
                                                      message:@"Leaving this bar will clear any drinks currently selected at this bar."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Clear Drinks", nil];
    [message show];
}

#pragma mark - UIAlertView Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Clear Drinks"])
    {
        NSLog(@"Clearing Drinks");
        [[SharedDataHandler sharedInstance].currentDrinkOrder removeAllObjects];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else if([title isEqualToString:@"Cancel"])
    {
        NSLog(@"Cancelling");
    }
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.drinkTypes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCell *cell = (BasicCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *type = [self.drinkTypes objectAtIndex:[indexPath row]];
    cell.textLabel.text = [type objectForKey:@"name"];
    [cell setCellImage:[NSURLRequest requestWithURL:[NSURL URLWithString:[type objectForKey:@"icon"]]]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *selectedType = [self.drinkTypes objectAtIndex:[indexPath row]];
    BSTDrinkSelectionViewController *dsvc = [[BSTDrinkSelectionViewController alloc] initWithDrinkType:[[selectedType objectForKey:@"id"] intValue]];
    [self.navigationController pushViewController:dsvc animated:YES];
}

@end
