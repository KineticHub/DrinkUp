//
//  ConfirmOrderViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/18/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SharedDataHandler.h"
#import "ThanksViewController.h"
#import "ActionSheetPicker.h"
#import "BasicSplitTableViewController.h"
#import "DrinkSelectCell.h"

@interface ConfirmOrderViewController ()
@property (nonatomic, strong) NSMutableArray *drinksOrdered;
@property (nonatomic, strong) UITableView *tableViewDrinks;

@property (nonatomic, strong) UITableViewCell *totalCell;
@property (nonatomic, strong) UITableViewCell *taxAndFeeCell;
@property (nonatomic, strong) UITableViewCell *tipCell;
@property (nonatomic, strong) UISlider *tipSlider;

@property float tipPercent;
@property float totalPrice;
@property float taxAndFees;
@property float finalPrice;

@property int SelectedDrinkRow;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.drinksOrdered = [SharedDataHandler sharedInstance].currentDrinkOrder;
    NSLog(@"drinks ordered currently: %@", self.drinksOrdered);
    
//    CGFloat verticlSpacer = 10.0;
//    CGFloat horizontalSpacer = 10.0;
//    CGFloat splitViewHeight = self.view.frame.size.height/2 - self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomViewHeight = 60.0;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:bottomView];
    
    [self setupBottomViewWithView:bottomView];
    
    UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 120.0 - bottomViewHeight, self.view.frame.size.width, 120.0)];
    [priceView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:priceView];
    
    [self setupPriceViewWithView:priceView];
    [self updatePricesAndTotals];
    
    self.tableViewDrinks = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - priceView.frame.size.height - bottomView.frame.size.height) style:UITableViewStylePlain];
    [self.tableViewDrinks setDelegate:self];
    [self.tableViewDrinks setDataSource:self];
    //    [self.tableView setBackgroundView:nil];
    [self.tableViewDrinks flashScrollIndicators];
    //    [self.tableViewDrinks setTag:0];
    [self.tableViewDrinks setRowHeight:50];
    [self.tableViewDrinks setBackgroundColor:[UIColor clearColor]];
    [self.tableViewDrinks setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableViewDrinks];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [BasicSplitTableViewController forceHidePlaceOrderBar];
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
    self.tipCell.detailTextLabel.text = @"10%";
    [self.tipCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.tipCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    self.tipSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150.0, 20.0)];
    [self.tipSlider setCenter:CGPointMake(self.tipCell.frame.size.width/2, self.tipCell.frame.size.height/2)];
    [self.tipSlider setMaximumValue:100];
    [self.tipSlider setMinimumValue:5];
    [self.tipSlider setValue:10];
    [self.tipSlider addTarget:self action:@selector(tipPercentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tipCell addSubview:self.tipSlider];
    
    [priceView addSubview:self.tipCell];
    pvYPosition += pvHeight;
    
    self.taxAndFeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    [self.taxAndFeeCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.taxAndFeeCell setBackgroundColor:[UIColor clearColor]];
    self.taxAndFeeCell.textLabel.text = @"Tax and fees";
    [self.taxAndFeeCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.taxAndFeeCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    [priceView addSubview:self.taxAndFeeCell];
    pvYPosition += pvHeight;
    
    self.totalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier2"];
    [self.totalCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.totalCell setBackgroundColor:[UIColor clearColor]];
    self.totalCell.textLabel.text = @"Total:";
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
    [self.totalCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.totalCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    [priceView addSubview:self.totalCell];
    pvYPosition += pvHeight;
}

-(void)setupBottomViewWithView:(UIView *)bottomView {
    
//    CGFloat spacer = 10.0;
//    CGFloat bbWidth = (self.view.frame.size.width/3) - (spacer);
//    CGFloat bbHeight = 30.0;
//    CGFloat bbYPosition = bottomView.frame.size.height;
//    CGFloat bbXPosition = 10.0;
    
//    UIButton *cancelOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
//    [cancelOrder setFrame:CGRectMake(bbXPosition, bbYPosition, bbWidth, bbHeight)];
//    //    cancelOrder.center = CGPointMake(cancelOrder.center.x, bottomView.frame.size.height/2);
//    [cancelOrder setTitle:@"Cancel" forState:UIControlStateNormal];
//    cancelOrder.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    cancelOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [cancelOrder addTarget:self action:@selector(cancelCurrentOrder) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:cancelOrder];
//    bbXPosition += bbWidth + spacer;
    
    UIButton *placeOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [placeOrder setFrame:CGRectMake(0.0, 0.0, 300.0, bottomView.frame.size.height - 10.0)];
    [placeOrder setCenter: CGPointMake(bottomView.center.x, bottomView.frame.size.height/2)];
    [placeOrder setTitle:@"Place Order" forState:UIControlStateNormal];
    placeOrder.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    placeOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
    [placeOrder addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:placeOrder];
}

-(void)tipPercentChanged:(id)sender {
    [self updatePricesAndTotals];
}

-(void)updatePricesAndTotals {
    
    self.tipPercent = roundf(self.tipSlider.value) / 100;
    
    self.totalPrice = 0.00;
    for (NSDictionary *drink in self.drinksOrdered) {
        NSString *priceKey;
        if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
            priceKey = @"happyhour_price";
        } else {
            priceKey = @"price";
        }
        self.totalPrice += [[drink objectForKey:@"quantity"] floatValue] * [[drink objectForKey:priceKey] floatValue];
    }
    
    //NEED TO FIGURE OUT WHERE THIS ACTUALLY COMES FROM
    self.taxAndFees = 2.75;
    self.taxAndFeeCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.taxAndFees];
    
    self.finalPrice = self.totalPrice + self.taxAndFees + ((self.totalPrice + self.taxAndFees) * self.tipPercent);
    
    int tipValue = roundf(self.tipSlider.value);
    self.tipCell.detailTextLabel.text = [NSString stringWithFormat:@"%i%%", tipValue];
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
}

#pragma mark - TableView DataSource Methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 30.0)];
    [headerLabel setBackgroundColor:[UIColor blackColor]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setText:@"Current Order"];
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
    
    return [self. drinksOrdered count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DrinkSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[DrinkSelectCell alloc] initWithReuseIdentifier:@"CellIdentifier"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        
        cell.drinkCostLabel.textColor = [UIColor whiteColor];
        [cell.drinkCostLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        
        cell.drinkCountLabel.textColor = [UIColor whiteColor];
        [cell.drinkCountLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        
        UIView *highlightedBackgroundView = [[UIView alloc] init];
        [highlightedBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [highlightedBackgroundView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [highlightedBackgroundView.layer setBorderWidth:2.0];
        [cell setBackgroundView:highlightedBackgroundView];
        
        for (UIView *view in [cell subviews])
        {
            NSLog(@"view bg: %@", view.backgroundColor);
            [view setBackgroundColor:[UIColor clearColor]];
            NSLog(@"view bg 2: %@", view.backgroundColor);
        }
	}
    
    NSDictionary *drink = [self.drinksOrdered objectAtIndex:[indexPath row]];
    
    NSString *priceKey;
    if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
        priceKey = @"happyhour_price";
    } else {
        priceKey = @"price";
    }
    NSString *priceString = [NSString stringWithFormat:@"$%@", [drink objectForKey:priceKey]];
    
    cell.textLabel.text = [drink objectForKey:@"name"];
//    [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
    
    [cell setCostLabelAmount:priceString];
    [cell setDrinkQuantity:[[drink objectForKey:@"quantity"] intValue]];
    
//    NSString *detailString;
//    if ([[drink objectForKey:@"quantity"] integerValue] > 0) {
//        detailString = [NSString stringWithFormat:@"%i  x  $%@", [[drink objectForKey:@"quantity"] integerValue], [drink objectForKey:@"price"]];
//    } else {
//        detailString = [NSString stringWithFormat:@"$%@", [drink objectForKey:@"price"]];
//    }
//    
//    cell.textLabel.text = [drink objectForKey:@"name"];
//    cell.detailTextLabel.text = detailString;
//    [cell.imageView setImageWithURL:[NSURL URLWithString:[drink objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    
    NSLog(@"Drink for row %i: %@", [indexPath row], drink);
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableViewDrinks deselectRowAtIndexPath:[self.tableViewDrinks indexPathForSelectedRow] animated:YES];
    
    self.SelectedDrinkRow = [indexPath row];
    NSDictionary *drink = [self.drinksOrdered objectAtIndex:self.SelectedDrinkRow];
    int currentQuantity = [[drink objectForKey:@"quantity"] intValue];
    
    UILabel *drinkTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
    [drinkTypeLabel setText:[drink objectForKey:@"name"]];
    [drinkTypeLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [drinkTypeLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkTypeLabel setBackgroundColor:[UIColor whiteColor]];
    [drinkTypeLabel setTextColor:[UIColor blackColor]];
    [drinkTypeLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [drinkTypeLabel.layer setBorderWidth:2.0];
    
    UIView *drinkInfoView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(drinkTypeLabel.frame), 320.0, 210 - 35.0)];
    [drinkInfoView setBackgroundColor:[UIColor whiteColor]];
    [drinkInfoView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [drinkInfoView.layer setBorderWidth:2.0];
    
    UITextView *drinkDescription = [[UITextView alloc] initWithFrame:CGRectMake(5.0, 10.0, drinkInfoView.frame.size.width - 10.0, drinkInfoView.frame.size.height - 20.0)];
    [drinkDescription setText:[drink objectForKey:@"description"]];
    [drinkDescription setFont:[UIFont systemFontOfSize:16.0]];
    [drinkInfoView addSubview:drinkDescription];
    
    
    UILabel *drinkNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 45.0)];
    [drinkNameLabel setText:[drink objectForKey:@"name"]];
    [drinkNameLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkNameLabel setBackgroundColor:[UIColor clearColor]];
    [drinkNameLabel setTextColor:[UIColor blackColor]];
    //    [drinkInfoView addSubview:drinkNameLabel];
    
    NSString *priceKey;
    if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
        priceKey = @"happyhour_price";
    } else {
        priceKey = @"price";
    }
    NSString *priceString = [NSString stringWithFormat:@"$%@", [drink objectForKey:priceKey]];
    UILabel *drinkPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(drinkNameLabel.frame), 320.0, 45.0)];
    [drinkPriceLabel setText:priceString];
    [drinkPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkPriceLabel setBackgroundColor:[UIColor clearColor]];
    [drinkPriceLabel setTextColor:[UIColor blackColor]];
    //    [drinkInfoView addSubview:drinkPriceLabel];
    
    NSArray *amounts = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Quantity" rows:amounts initialSelection:currentQuantity target:self successAction:@selector(quantityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:[tableView cellForRowAtIndexPath:indexPath] customTopSubviews:@[drinkTypeLabel, drinkInfoView]];
}

-(void)actionPickerCancelled {
    NSLog(@"Cancelled");
}

- (void)quantityWasSelected:(NSNumber *)selectedIndex element:(id)element {
    
    NSMutableDictionary *dicDrink = [NSMutableDictionary dictionaryWithDictionary:[self.drinksOrdered objectAtIndex:self.SelectedDrinkRow]];
    [dicDrink setObject:[NSNumber numberWithInteger:[selectedIndex integerValue]] forKey:@"quantity"];
    [self.drinksOrdered replaceObjectAtIndex:self.SelectedDrinkRow withObject:dicDrink];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.SelectedDrinkRow inSection:0];
    if ([[dicDrink objectForKey:@"quantity"] intValue] == 0) {
        [self.drinksOrdered removeObjectAtIndex:self.SelectedDrinkRow];
        [self.tableViewDrinks deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableViewDrinks reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
//    [[SharedDataHandler sharedInstance] addDrinksToCurrentOrder:self.drinksOrdered];
    [self updatePricesAndTotals];
}

#pragma mark - Ordering Options

-(void)cancelCurrentOrder {
//    [[SharedDataHandler sharedInstance].currentDrinkOrder removeAllObjects];
    [self.drinksOrdered removeAllObjects];
    [self.tableViewDrinks reloadData];
}

-(void)placeOrder
{
    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
    [order setObject:[NSNumber numberWithInt:[SharedDataHandler sharedInstance].current_section] forKey:@"bar_id"];
    [order setObject:[NSNumber numberWithFloat:self.totalPrice] forKey:@"total"];
    [order setObject:[NSNumber numberWithFloat:2.40] forKey:@"tax"];
    [order setObject:[NSNumber numberWithFloat:self.totalPrice + 2.40] forKey:@"sub_total"];
    [order setObject:[NSNumber numberWithFloat:((self.totalPrice + 2.40 + 0.35) * self.tipPercent)] forKey:@"tip"];
    [order setObject:[NSNumber numberWithFloat:0.35] forKey:@"fees"];
    [order setObject:[NSNumber numberWithFloat:self.finalPrice] forKey:@"grand_total"];
    [order setObject:[SharedDataHandler sharedInstance].currentDrinkOrder forKey:@"drinks"];
//    [[SharedDataHandler sharedInstance] placeOrder:order];
    
    NSLog(@"print drinks: %@", [SharedDataHandler sharedInstance].currentDrinkOrder);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] placeOrder:order withSuccess:^(bool successful)
        {
            [[SharedDataHandler sharedInstance].currentDrinkOrder removeAllObjects];
            ThanksViewController *thanksVC = [[ThanksViewController alloc] init];
            [self.navigationController pushViewController:thanksVC animated:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

@end
