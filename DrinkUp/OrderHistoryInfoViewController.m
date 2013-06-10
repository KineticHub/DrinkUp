//
//  OrderHistoryInfoViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/5/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "OrderHistoryInfoViewController.h"
#import "SharedDataHandler.h"
#import "BasicSplitTableViewController.h"
#import "NewDrinkSelectCell.h"

@interface OrderHistoryInfoViewController ()
@property (nonatomic, strong) NSMutableArray *drinksOrdered;
@property (nonatomic, strong) UITableView *tableViewDrinks;

@property (nonatomic, strong) UITableViewCell *totalCell;
@property (nonatomic, strong) UITableViewCell *taxAndFeeCell;
@property (nonatomic, strong) UITableViewCell *tipCell;

@property float tipPercent;
@property float totalPrice;
@property float taxAndFees;
@property float finalPrice;
@end

@implementation OrderHistoryInfoViewController

-(id)initWithOrder:(NSDictionary *)pastOrder
{
    self = [super init];
    if (self)
    {
        self.order = pastOrder;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    CGFloat verticlSpacer = 10.0;
    CGFloat horizontalSpacer = 10.0;
    CGFloat splitViewHeight = self.view.frame.size.height/2 - self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomViewHeight = 0.0;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:bottomView];
    
    [self setupBottomViewWithView:bottomView];
    
    UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 120.0 - bottomViewHeight, self.view.frame.size.width, 120.0)];
    [priceView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:priceView];
    
    [self setupPriceViewWithView:priceView];
    
    self.tableViewDrinks = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - priceView.frame.size.height - bottomView.frame.size.height) style:UITableViewStylePlain];
    [self.tableViewDrinks setDelegate:self];
    [self.tableViewDrinks setDataSource:self];
    //    [self.tableView setBackgroundView:nil];
    [self.tableViewDrinks flashScrollIndicators];
    //    [self.tableViewDrinks setTag:0];
    [self.tableViewDrinks setRowHeight:65.0];
    [self.tableViewDrinks setBackgroundColor:[UIColor clearColor]];
    [self.tableViewDrinks setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableViewDrinks];
    
    self.drinksOrdered = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinksForOrder:[[self.order objectForKey:@"id"] intValue] onCompletion:^(NSMutableArray *objects) {
            
            self.drinksOrdered = [NSMutableArray arrayWithArray:objects];
            [self.tableViewDrinks reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Subviews Setup

-(void)setupPriceViewWithView:(UIView *)priceView {
    
    CGFloat pvYPosition = 0.0;
    CGFloat pvEdgeInset = 0.0;
    CGFloat pvWidth = priceView.frame.size.width - pvEdgeInset * 2;
    CGFloat pvHeight = priceView.frame.size.height/3;
    
    self.tipCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier3"];
    [self.tipCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.tipCell setBackgroundColor:[UIColor clearColor]];
    self.tipCell.textLabel.text = @"Tip";
    self.tipCell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", [self.order objectForKey:@"tip"]];
    [self.tipCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.tipCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    [priceView addSubview:self.tipCell];
    pvYPosition += pvHeight;
    
    self.taxAndFeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    [self.taxAndFeeCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.taxAndFeeCell setBackgroundColor:[UIColor clearColor]];
    self.taxAndFeeCell.textLabel.text = @"Tax and fees";
    [self.taxAndFeeCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.taxAndFeeCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    self.taxAndFeeCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", [[self.order objectForKey:@"tax"] doubleValue] + [[self.order objectForKey:@"fees"] doubleValue]];
    
    [priceView addSubview:self.taxAndFeeCell];
    pvYPosition += pvHeight;
    
    self.totalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier2"];
    [self.totalCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.totalCell setBackgroundColor:[UIColor clearColor]];
    self.totalCell.textLabel.text = @"Total:";
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
    [self.totalCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.totalCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", [[self.order objectForKey:@"grand_total"] doubleValue]];
    
    [priceView addSubview:self.totalCell];
    pvYPosition += pvHeight;
}

-(void)setupBottomViewWithView:(UIView *)bottomView
{
    
    UIButton *placeOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [placeOrder setFrame:CGRectMake(0.0, 0.0, 300.0, bottomView.frame.size.height - 10.0)];
    [placeOrder setCenter: CGPointMake(bottomView.center.x, bottomView.frame.size.height/2)];
    [placeOrder setTitle:@"Place Order" forState:UIControlStateNormal];
    placeOrder.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    placeOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
    [placeOrder addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:placeOrder];
}

#pragma mark - TableView DataSource Methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 30.0)];
    [headerLabel setBackgroundColor:[UIColor blackColor]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setText:[NSString stringWithFormat:@"ORDER ID #%i", [[self.order objectForKey:@"id"] intValue]]];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    return headerLabel;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Current Order";
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.drinksOrdered count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"NormalCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell.contentView setBackgroundColor: [UIColor whiteColor] ];
        
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSDictionary *drink = [self.drinksOrdered objectAtIndex:[indexPath row]];
    
    NSString *priceString = [NSString stringWithFormat:@"%i x $%@",[[drink objectForKey:@"quantity"] intValue], [drink objectForKey:@"unit_price"]];
    
    cell.textLabel.text = [drink objectForKey:@"drink_name"];
    cell.detailTextLabel.text = priceString;
    
    
    return cell;
}

@end
