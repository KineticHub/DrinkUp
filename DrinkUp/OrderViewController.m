//
//  OrderViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/9/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrderViewController.h"
#import "MBProgressHUD.h"
#import "SharedDataHandler.h"
#import "TextStepperField.h"

@interface OrderViewController ()
{
	ZKRevealingTableViewCell *_currentlyRevealedCell;
}
@property (nonatomic, retain) ZKRevealingTableViewCell *currentlyRevealedCell;
@property (nonatomic, strong) CollapseClick *collapsableDrinkOrder;
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
@end

@implementation OrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    self.drinksOrdered = [SharedDataHandler sharedInstance].currentDrinkOrder;
    
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
    
    CGRect collapseFrame = self.view.frame;
    collapseFrame.size.height -= self.navigationController.navigationBar.frame.size.height - bottomViewHeight - priceView.frame.size.height;
    
    self.collapsableDrinkOrder = [[CollapseClick alloc] initWithFrame:collapseFrame];
    [self.collapsableDrinkOrder setCollapseClickDelegate:self];
    [self.view addSubview:self.collapsableDrinkOrder];
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

#pragma mark - Accessors

- (ZKRevealingTableViewCell *)currentlyRevealedCell
{
    return _currentlyRevealedCell;
}

- (void)setCurrentlyRevealedCell:(ZKRevealingTableViewCell *)currentlyRevealedCell
{
    if (_currentlyRevealedCell == currentlyRevealedCell)
        return;
    
    [_currentlyRevealedCell setRevealing:NO];
    
    [self willChangeValueForKey:@"currentlyRevealedCell"];
    _currentlyRevealedCell = currentlyRevealedCell;
    [self didChangeValueForKey:@"currentlyRevealedCell"];
}

#pragma mark - ZKRevealingTableViewCellDelegate

- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell {
    return YES;
}

- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell {
    NSLog(@"Revealed Cell with title: %@", cell.textLabel.text);
    self.currentlyRevealedCell = cell;
}

- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell
{
	if (cell != self.currentlyRevealedCell)
		self.currentlyRevealedCell = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.currentlyRevealedCell = nil;
}

#pragma mark - Collapse Click Delegate

// Required Methods
-(int)numberOfCellsForCollapseClick {
    return 1;
}

-(NSString *)titleForCollapseClickAtIndex:(int)index
{
    return @"Current Order";
}

-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index
{
    return self.tableViewDrinks;
}

// Optional Methods

-(UIColor *)colorForCollapseClickTitleViewAtIndex:(int)index {
    return [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0];
}


-(UIColor *)colorForTitleLabelAtIndex:(int)index {
    return [UIColor colorWithWhite:1.0 alpha:0.85];
}

-(UIColor *)colorForTitleArrowAtIndex:(int)index {
    return [UIColor colorWithWhite:0.0 alpha:0.0];
}

-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open
{
}

@end
