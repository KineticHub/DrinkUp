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
    
    self.drinksOrdered = [SharedDataHandler sharedInstance].currentDrinkOrder;
    NSLog(@"drinks ordered currently: %@", self.drinksOrdered);
    
    CGFloat verticlSpacer = 10.0;
    CGFloat horizontalSpacer = 10.0;
    CGFloat splitViewHeight = self.view.frame.size.height/2 - self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomViewHeight = 60.0;
    
    self.tableViewDrinks = [[UITableView alloc] initWithFrame:CGRectMake(horizontalSpacer, verticlSpacer, self.view.frame.size.width - horizontalSpacer * 2, splitViewHeight - verticlSpacer * 2) style:UITableViewStylePlain];
    [self.tableViewDrinks setDelegate:self];
    [self.tableViewDrinks setDataSource:self];
    //    [self.tableView setBackgroundView:nil];
    [self.tableViewDrinks flashScrollIndicators];
    [self.tableViewDrinks setTag:0];
    [self.view addSubview:self.tableViewDrinks];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:bottomView];
    
    [self setupBottomViewWithView:bottomView];
    
    UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 160.0 - bottomViewHeight, self.view.frame.size.width, 160.0)];
    [priceView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:priceView];
    
    [self setupPriceViewWithView:priceView];
    
    [self updatePricesAndTotals];
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
    
    self.taxAndFeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    [self.taxAndFeeCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.taxAndFeeCell setBackgroundColor:[UIColor lightGrayColor]];
    self.taxAndFeeCell.textLabel.text = @"Tax and fees";
    
    [priceView addSubview:self.taxAndFeeCell];
    pvYPosition += pvHeight;
    
    self.totalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier2"];
    [self.totalCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.totalCell setBackgroundColor:[UIColor lightGrayColor]];
    self.totalCell.textLabel.text = @"Total:";
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
    
    [priceView addSubview:self.totalCell];
    pvYPosition += pvHeight;
    
    self.tipCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier3"];
    [self.tipCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.tipCell setBackgroundColor:[UIColor lightGrayColor]];
    self.tipCell.textLabel.text = @"Tip";
    self.tipCell.detailTextLabel.text = @"10%";
    
    self.tipSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150.0, 20.0)];
    [self.tipSlider setCenter:CGPointMake(self.tipCell.frame.size.width/2, self.tipCell.frame.size.height/2)];
    [self.tipSlider setMaximumValue:100];
    [self.tipSlider setMinimumValue:5];
    [self.tipSlider setValue:10];
    [self.tipSlider addTarget:self action:@selector(tipPercentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tipCell addSubview:self.tipSlider];
    
    [priceView addSubview:self.tipCell];
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
        self.totalPrice += [[drink objectForKey:@"quantity"] floatValue] * [[drink objectForKey:@"price"] floatValue];
    }
    
    //NEED TO FIGURE OUT WHERE THIS ACTUALLY COMES FROM
    self.taxAndFees = 0.75;
    self.taxAndFeeCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.taxAndFees];
    
    self.finalPrice = self.totalPrice + self.taxAndFees + ((self.totalPrice + self.taxAndFees) * self.tipPercent);
    
    int tipValue = roundf(self.tipSlider.value);
    self.tipCell.detailTextLabel.text = [NSString stringWithFormat:@"%i%%", tipValue];
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self. drinksOrdered count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
	}
    
    NSDictionary *drink = [self.drinksOrdered objectAtIndex:[indexPath row]];
    
    NSString *detailString;
    if ([[drink objectForKey:@"quantity"] integerValue] > 0) {
        detailString = [NSString stringWithFormat:@"%i  x  $%@", [[drink objectForKey:@"quantity"] integerValue], [drink objectForKey:@"price"]];
    } else {
        detailString = [NSString stringWithFormat:@"$%@", [drink objectForKey:@"price"]];
    }
    
    cell.textLabel.text = [drink objectForKey:@"name"];
    cell.detailTextLabel.text = detailString;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[drink objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    
    NSLog(@"Drink for row %i: %@", [indexPath row], drink);
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.SelectedDrinkRow = [indexPath row];
    
    NSArray *amounts = @[@"Remove",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Quantity" rows:amounts initialSelection:0 target:self successAction:@selector(quantityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:[tableView cellForRowAtIndexPath:indexPath]];
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

-(void)placeOrder {
    ThanksViewController *thanksVC = [[ThanksViewController alloc] init];
    [self.navigationController pushViewController:thanksVC animated:YES];
}

@end
