//
//  BSTDrinkTypeViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BSTDrinkTypeViewController.h"
#import "BSTDrinkSelectionViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UserLoginViewController.h"

@interface BSTDrinkTypeViewController ()
@property (nonatomic, strong) NSMutableArray *drinkTypes;
@property int section_id;
@end

@implementation BSTDrinkTypeViewController

-(id)initWithBarSection:(int)section_id {
    self = [super initWithUpperViewHieght:60.0];
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
    
    [[SharedDataHandler sharedInstance] isBarHappyHour];
    
//    CGFloat width = self.view.frame.size.width;
//    CGFloat height = 60.0;
//    UIView *leaveBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - height - 45.0, width, height)];
//    [leaveBarView setBackgroundColor:[UIColor whiteColor]];
//    [self.view addSubview:leaveBarView];
    
//    QBFlatButton *leaveBarButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    leaveBarButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
//    leaveBarButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
//    leaveBarButton.radius = 6.0;
//    leaveBarButton.margin = 4.0;
//    leaveBarButton.depth = 3.0;
//    leaveBarButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [leaveBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [leaveBarButton setTitle:@"Logout" forState:UIControlStateNormal];
//    [leaveBarButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
//    [leaveBarButton addTarget:self action:@selector(logoutFromServer:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:leaveBarButton];
    
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
    
    UIView *barNameTitleBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)];
    [barNameTitleBar setBackgroundColor:[UIColor blackColor]];
//    [self.upperView addSubview:barNameTitleBar];
    
//    UILabel *barNameTitle = [[UILabel alloc] initWithFrame:barNameTitleBar.frame];
//    [barNameTitle setText:@"Top of the Stairs"];
//    [barNameTitle setTextAlignment:NSTextAlignmentCenter];
//    [barNameTitle setTextColor:[UIColor whiteColor]];
//    [barNameTitle setBackgroundColor:[UIColor clearColor]];
//    [barNameTitleBar addSubview:barNameTitle];
    
    UILabel *barLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 0.0, self.upperView.frame.size.width - 8.0, self.upperView.frame.size.height)];
    [barLabel setTextAlignment:NSTextAlignmentCenter];
    [barLabel setText:[[SharedDataHandler sharedInstance].currentBar objectForKey:@"name"]];
    [barLabel setFont:[UIFont boldSystemFontOfSize:36.0]];
    [barLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [barLabel setNumberOfLines:1];
    [barLabel setAdjustsFontSizeToFitWidth:YES];
    [self.upperView addSubview:barLabel];
    
    [self.tableView setRowHeight:60.0];
    
//    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 120.0)];
//    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
//    [logoImageView setCenter:CGPointMake(self.upperView.center.x, self.upperView.center.y + 0.0)];
//    [logoImageView setImageWithURL:[NSURL URLWithString:[[SharedDataHandler sharedInstance].currentBar objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
//    [self.upperView addSubview:logoImageView];
//    [self.upperView setBackgroundColor:[UIColor whiteColor]];
}

-(void)showUserProfile
{
    UserLoginViewController *userLoginVC = [[UserLoginViewController alloc] init];
    [self.navigationController pushViewController:userLoginVC animated:YES];
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
    return [self.drinkTypes count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCell *cell = (BasicCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *type = [self.drinkTypes objectAtIndex:[indexPath section]];
    cell.textLabel.text = [type objectForKey:@"name"];
//    [cell setCellImage:[NSURLRequest requestWithURL:[NSURL URLWithString:[type objectForKey:@"icon"]]]];
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *selectedType = [self.drinkTypes objectAtIndex:[indexPath section]];
    BSTDrinkSelectionViewController *dsvc = [[BSTDrinkSelectionViewController alloc] initWithDrinkType:[[selectedType objectForKey:@"id"] intValue] typeName:[selectedType objectForKey:@"name"]];
    [self.navigationController pushViewController:dsvc animated:YES];
}

@end
