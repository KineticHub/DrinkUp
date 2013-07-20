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
#import "NewDrinkSelectCell.h"
#import "ThanksViewController.h"
#import "UserLoginViewController.h"
#import "QBFlatButton.h"
#import "CustomBarButton.h"
#import "SVSegmentedControl.h"
#import "UIColor+FlatUI.h"
#import "UnlockSliderView.h"
#import "FUIAlertView.h"
#import "KUIHelper.h"
#import "SignupViewController.h"
#import "CreditCardProfileViewController.h"
#import "UIBarButtonItem+FlatUI.h"

@interface OrderViewController ()
{
	ZKRevealingTableViewCell *_currentlyRevealedCell;
}
@property (nonatomic, retain) ZKRevealingTableViewCell *currentlyRevealedCell;
@property (nonatomic, strong) CollapseClick *collapsableDrinkOrder;
@property (nonatomic, strong) NSMutableArray *drinksOrdered;
@property (nonatomic, strong) UITableView *tableViewDrinks;
@property (nonatomic, strong) QBFlatButton *placeOrderButton;

@property (nonatomic, strong) UITableViewCell *totalCell;
@property (nonatomic, strong) UITableViewCell *taxAndFeeCell;
@property (nonatomic, strong) UITableViewCell *drinkTotalCell;
@property (nonatomic, strong) UITableViewCell *tipCell;
@property (nonatomic, strong) SVSegmentedControl *tipSlider;
@property (nonatomic, strong) UnlockSliderView *unlockSliderPlaceOrder;

@property float tipPercent;
@property float totalPrice;
@property float taxAndFees;
@property float finalPrice;
@end

@implementation OrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.drinksOrdered = [SharedDataHandler sharedInstance].currentDrinkOrder;
    
    CGFloat bottomViewHeight = 60.0;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor belizeHoleColor]];
    [self.view addSubview:bottomView];
    
    [self setupBottomViewWithView:bottomView];
    
    UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 120.0 - bottomViewHeight, self.view.frame.size.width, 120.0)];
    [priceView setBackgroundColor:[UIColor belizeHoleColor]];
    [self.view addSubview:priceView];
    
    [self setupPriceViewWithView:priceView];
    [self updatePricesAndTotals];
    
    self.tableViewDrinks = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300, 165)];
    [self.tableViewDrinks setBackgroundColor:[UIColor whiteColor]];
    [self.tableViewDrinks setDelegate:self];
    [self.tableViewDrinks setDataSource:self];
    [self.tableViewDrinks setRowHeight:65.0];
    
    CGRect collapseFrame = self.view.frame;
    collapseFrame.origin.x = 0.0;
    collapseFrame.origin.y = 0.0;
    collapseFrame.size.height = 460.0 - self.navigationController.navigationBar.frame.size.height - bottomViewHeight - priceView.frame.size.height;
    
    self.collapsableDrinkOrder = [[CollapseClick alloc] initWithFrame:collapseFrame];
    [self.collapsableDrinkOrder setBackgroundColor:[UIColor clearColor]];
    [self.collapsableDrinkOrder setScrollEnabled:NO];
    [self.collapsableDrinkOrder setCollapseClickDelegate:self];
    [self.collapsableDrinkOrder reloadCollapseClick];
    [self.collapsableDrinkOrder openCollapseClickCellAtIndex:0 animated:NO];
    [self.view addSubview:self.collapsableDrinkOrder];
    
//    UIImage *settingsImage = [UIImage imageNamed:@"gears"];
//    CustomBarButton *settingsButton = [[CustomBarButton alloc] init];
//    [settingsButton setButtonWithImage:settingsImage];
//    [settingsButton addTarget:self action:@selector(showUserProfile) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsProfileButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showUserProfile)];
//    [settingsProfileButton setCustomView:settingsButton];
    
//    UIBarButtonItem *settingsProfileButton = [[UIBarButtonItem alloc]
//                                              initWithImage:[UIImage imageNamed:@"settings_icon"]
//                                              style:UIBarButtonItemStylePlain
//                                              target:self action:@selector(showUserProfile)];
//    [settingsProfileButton setTintColor:[UIColor whiteColor]];
    
//    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Drinks" style:UIBarButtonItemStyleDone target:self action:@selector(cancelCurrentOrderCheck)];
//    [clearButton setTintColor:[UIColor redColor]];
    
//    QBFlatButton *clearButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    clearButton.faceColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
//    clearButton.sideColor = [UIColor colorWithRed:(170/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
//    clearButton.radius = 6.0;
//    clearButton.margin = 2.0;
//    clearButton.depth = 2.0;
//    clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [clearButton setTitle:@"Clear Order" forState:UIControlStateNormal];
//    [clearButton setFrame:CGRectMake(0.0, 0.0, 95.0, 32.0)];
//    [clearButton addTarget:self action:@selector(cancelCurrentOrderCheck) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *clearBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Order"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(cancelCurrentOrderCheck)];
    
    [clearBarButton configureFlatButtonWithColor:[UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0] highlightedColor:[UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0] cornerRadius:3.0];
    
    //    self.orderBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"View Order" style:UIBarButtonItemStylePlain target:self action:@selector(viewCurrentOrderView)];
//    UIBarButtonItem *clearBarButton = [[UIBarButtonItem alloc] init];
//    [clearBarButton setCustomView:clearButton];
    
    self.navigationItem.rightBarButtonItems = @[clearBarButton, /* fixedSpaceBarButtonItem, */ settingsProfileButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.unlockSliderPlaceOrder lockSlider];
    
    NSLog(@"View will appear order view hit");
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isCreatingAccount"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCreatingAccount"];
        if ([SharedDataHandler sharedInstance].isUserAuthenticated && [SharedDataHandler sharedInstance].userCard != nil)
        {
            FUIAlertView *doneAlert = [KUIHelper createAlertViewWithTitle:@"DrinkUp!"
                                                                  message:@"You're all set, slide to order and have a good time!"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Let's Drink"
                                                        otherButtonTitles:nil];
            [doneAlert show];
        }
    }
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
//    self.tipCell.textLabel.text = @"Tip";
//    self.tipCell.detailTextLabel.text = @"20%";
    [self.tipCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.tipCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
//    self.tipSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150.0, 20.0)];
//    [self.tipSlider setCenter:CGPointMake(self.tipCell.frame.size.width/2, self.tipCell.frame.size.height/2)];
//    [self.tipSlider setMaximumValue:100];
//    [self.tipSlider setMinimumValue:5];
//    [self.tipSlider setValue:10];
//    [self.tipSlider addTarget:self action:@selector(tipPercentChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.tipCell addSubview:self.tipSlider];
    
    self.tipSlider = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"15%", @"20%", @"25%", @"30%", nil]];
    [self.tipSlider setFrame:CGRectMake(0, 0, pvWidth, pvHeight - 5.0)];
    [self.tipSlider setBackgroundColor:[UIColor darkGrayColor]];
    self.tipSlider.cornerRadius = 1.0;
    [self.tipSlider setCenter:CGPointMake(self.tipCell.frame.size.width/2, self.tipCell.frame.size.height/2)];
//    [self.tipSlider addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];

    self.tipPercent = 0.25;
    [self.tipSlider setSelectedSegmentIndex:2 animated:NO];
    [self.tipSlider setChangeHandler:^(NSUInteger newIndex)
    {
        NSArray *tipPercents = @[@0.15, @0.20, @0.25, @0.30];
        self.tipPercent = [[tipPercents objectAtIndex:newIndex] floatValue];
        NSLog(@"tip slider titles: %@", self.tipSlider.sectionTitles);
//        self.tipCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.tipSlider.sectionTitles objectAtIndex:newIndex]];
        [self updatePricesAndTotals];
    }];
    
	self.tipSlider.crossFadeLabelsOnDrag = YES;
//    [self.tipCell addSubview:self.tipSlider];
    
//    [priceView addSubview:self.tipCell];
//    pvYPosition += pvHeight;
    
    self.drinkTotalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier4"];
    [self.drinkTotalCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.drinkTotalCell setBackgroundColor:[UIColor cloudsColor]];
    self.drinkTotalCell.textLabel.text = @"Sub Total:";
    self.drinkTotalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.totalPrice];
    [self.drinkTotalCell.textLabel setTextColor:[UIColor midnightBlueColor]];
    [self.drinkTotalCell.detailTextLabel setTextColor:[UIColor midnightBlueColor]];
    
    [priceView addSubview:self.drinkTotalCell];
    pvYPosition += pvHeight;
    
    self.taxAndFeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    [self.taxAndFeeCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.taxAndFeeCell setBackgroundColor:[UIColor cloudsColor]];
    self.taxAndFeeCell.textLabel.text = @"Gratuity:";
    [self.taxAndFeeCell.textLabel setTextColor:[UIColor midnightBlueColor]];
    [self.taxAndFeeCell.detailTextLabel setTextColor:[UIColor midnightBlueColor]];
    
    [priceView addSubview:self.taxAndFeeCell];
    pvYPosition += pvHeight;
    
    UIView *littleView = [[UIView alloc] initWithFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, 2.0)];
    [littleView setBackgroundColor:[UIColor whiteColor]];
    [priceView addSubview:littleView];
    
    pvYPosition += 2.0;
    
    self.totalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier2"];
    [self.totalCell setFrame:CGRectMake(pvEdgeInset, pvYPosition, pvWidth, pvHeight)];
    [self.totalCell setBackgroundColor:[UIColor clearColor]];
    self.totalCell.textLabel.text = @"Grand Total:";
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
    [self.totalCell.textLabel setTextColor:[UIColor whiteColor]];
    [self.totalCell.textLabel setFont:[UIFont systemFontOfSize:24.0]];
    [self.totalCell.detailTextLabel setTextColor:[UIColor whiteColor]];
    [self.totalCell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    
    [priceView addSubview:self.totalCell];
    pvYPosition += pvHeight;
}

-(void)setupBottomViewWithView:(UIView *)bottomView
{
    self.placeOrderButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    self.placeOrderButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    self.placeOrderButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    self.placeOrderButton.radius = 6.0;
    self.placeOrderButton.margin = 4.0;
    self.placeOrderButton.depth = 3.0;
    [self.placeOrderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.placeOrderButton setFrame:CGRectMake(0.0, 0.0, 300.0, bottomView.frame.size.height - 10.0)];
    [self.placeOrderButton setCenter: CGPointMake(bottomView.center.x, bottomView.frame.size.height/2)];
    [self.placeOrderButton setTitle:@"Place Order" forState:UIControlStateNormal];
    self.placeOrderButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.placeOrderButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.placeOrderButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.placeOrderButton addTarget:self action:@selector(placeOrderCheck) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:self.placeOrderButton];
    
    self.unlockSliderPlaceOrder = [[UnlockSliderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, bottomView.frame.size.height) andDelegate:self];
    [self.unlockSliderPlaceOrder setCenter:CGPointMake(bottomView.center.x, bottomView.frame.size.height/2)];
    [bottomView addSubview:self.unlockSliderPlaceOrder];
}

-(void)tipPercentChanged:(id)sender {
    [self updatePricesAndTotals];
}

-(void)updatePricesAndTotals {
    
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
    
    self.drinkTotalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.totalPrice];
    
    //NEED TO FIGURE OUT WHERE THIS ACTUALLY COMES FROM
//    self.taxAndFees = 0.05 * self.totalPrice + 0.05 + (self.totalPrice * self.tipPercent);
    self.taxAndFees = self.totalPrice * self.tipPercent;
    self.taxAndFeeCell.detailTextLabel.text = [NSString stringWithFormat:@"+ $%.02f", self.taxAndFees];
    
    self.finalPrice = self.totalPrice + self.taxAndFees; // + ((self.totalPrice + self.taxAndFees) * self.tipPercent);
    
//    int tipValue = roundf(self.tipSlider.value);
    self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.finalPrice];
}

#pragma  mark - Profile Transition
-(void) showUserProfile
{
    UserLoginViewController *userLoginVC = [[UserLoginViewController alloc] init];
    [self.navigationController pushViewController:userLoginVC animated:YES];
}

#pragma mark - Confirm Order Button Method
-(void)placeCurrentOrderView
{
    UIRemoteNotificationType status = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasCreatedAccount"] && ![SharedDataHandler sharedInstance].isUserAuthenticated)
    {
        NSLog(@"First time app account launch");
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCreatedAccount"];
        SignupViewController *signup = [[SignupViewController alloc] init];
        [self.navigationController pushViewController:signup animated:YES];
    }
    else if (![SharedDataHandler sharedInstance].isUserAuthenticated)
    {
        FUIAlertView *loginAlert = [KUIHelper createAlertViewWithTitle:@"Login Required"
                                                               message:@"You must be logged in to place orders. Please go to the settings menu and login."
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Login", nil];
        [loginAlert show];
    }
    else if (![SharedDataHandler sharedInstance].userCard)
    {
        FUIAlertView *cardAlert = [KUIHelper createAlertViewWithTitle:@"Credit Card Required"
                                                               message:@"You must have a credit card associated with your account to place an order."
                                                              delegate:self
                                                     cancelButtonTitle:@"Add Card"
                                                     otherButtonTitles:nil];
        [cardAlert show];
    }
    else if (status == UIRemoteNotificationTypeNone)
    {
        NSLog(@"User doesn't want to receive push-notifications, need to force use");
        
        [SharedDataHandler sharedInstance].isNotificationsEnabled = NO;
        FUIAlertView *notificationsAlert = [KUIHelper createAlertViewWithTitle:@"Push Notifications Disabled"
                                                              message:@"We cannot let you know when your order is ready without notifications. Please turn notifications on in the Settings App to place the order."
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
        [notificationsAlert show];
    }
    else
    {
        NSLog(@"place order button hit");
        [self placeOrder];
        
//        FUIAlertView *orderAlert = [KUIHelper createAlertViewWithTitle:@"Place Order?"
//                                                              message:@"Would you like to place this order?"
//                                                             delegate:self
//                                                    cancelButtonTitle:@"Cancel"
//                                                    otherButtonTitles:@"Place Order",nil];
//        [orderAlert show];
    }
    
}

#pragma mark - UIAlertView Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Clear Drinks"])
    {
        NSLog(@"Clearing Drinks");
        [self cancelCurrentOrder];
        
    } else if([title isEqualToString:@"Place Order"])
    {
        [self placeOrder];
        
    } else if([title isEqualToString:@"Login"])
    {
        [self showUserProfile];
    } else if([title isEqualToString:@"Cancel"])
    {
        [self.unlockSliderPlaceOrder lockSlider];
    } else if([title isEqualToString:@"Add Card"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldShowCard.io"];
        CreditCardProfileViewController *creditCardProfileVC = [[CreditCardProfileViewController alloc] init];
        [self.navigationController pushViewController:creditCardProfileVC animated:YES];
    }
}

#pragma mark - Ordering Options

-(void)cancelCurrentOrderCheck
{
    FUIAlertView *cancelAlert = [KUIHelper createAlertViewWithTitle:@"Clear Drinks?"
                                                          message:@"Are you sure you want to clear your current order?"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Clear Drinks",nil];
    [cancelAlert show];
}

-(void)cancelCurrentOrder {
    [self.drinksOrdered removeAllObjects];
    [self.tableViewDrinks reloadData];
    [self updatePricesAndTotals];
    [self updatePlaceOrderButton];
}

-(void)placeOrderCheck
{
    NSLog(@"Placing Order");
    [self placeCurrentOrderView];
}

-(void)placeOrder
{
    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
    [order setObject:[NSNumber numberWithInt:[SharedDataHandler sharedInstance].current_section] forKey:@"bar_id"];
    [order setObject:[NSNumber numberWithFloat:self.totalPrice] forKey:@"total"];
    [order setObject:[NSNumber numberWithFloat:0.0] forKey:@"tax"];
    [order setObject:[NSNumber numberWithFloat:self.totalPrice] forKey:@"sub_total"];
    [order setObject:[NSNumber numberWithFloat:(self.totalPrice * self.tipPercent)] forKey:@"tip"];
    [order setObject:[NSNumber numberWithFloat:0.0] forKey:@"fees"];
    [order setObject:[NSNumber numberWithFloat:self.finalPrice] forKey:@"grand_total"];
    [order setObject:[SharedDataHandler sharedInstance].currentDrinkOrder forKey:@"drinks"];
    //    [[SharedDataHandler sharedInstance] placeOrder:order];
    
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


#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.drinksOrdered count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"SpecialCell";
    NewDrinkSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[NewDrinkSelectCell alloc] initWithReuseIdentifier:CellIdentifier];
        cell.delegate = self;
        [cell.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventValueChanged];
        cell.stepper.tag = indexPath.row;
    }
    
    NSMutableDictionary *drink = [self.drinksOrdered objectAtIndex:indexPath.row];
    
    NSLog(@"drink in collapse: %@", drink);
    if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
        [cell.priceLabel setText:[NSString stringWithFormat:@" $%.2f ", [[drink objectForKey:@"happyhour_price"] floatValue]]];
    } else {
        [cell.priceLabel setText:[NSString stringWithFormat:@" $%.2f ", [[drink objectForKey:@"price"] floatValue]]];
    }
    
    cell.quantityLabel.text = [NSString stringWithFormat:@" ADDED x %i ", [[drink objectForKey:@"quantity"] intValue]];
    cell.stepper.Current = [[drink objectForKey:@"quantity"] intValue];
    
    if ([[drink objectForKey:@"quantity"] intValue] == 0)
    {
        [cell.quantityLabel setHidden:YES];
    }
    
    cell.textLabel.text = [drink objectForKey:@"name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([cell isKindOfClass:[ZKRevealingTableViewCell class]]) {
		ZKRevealingTableViewCell *panningTableViewCell = (ZKRevealingTableViewCell*)cell;
        [panningTableViewCell setRevealing:![panningTableViewCell isRevealing]];
	}
}

#pragma mark - Stepper Delegate

- (void)stepperDidStep:(TextStepperField *)stepper
{
    int quantity = (int)stepper.Current;
    
    int tag = stepper.tag;
    
    NSMutableDictionary *dicDrink = [NSMutableDictionary dictionaryWithDictionary:[self.drinksOrdered objectAtIndex:tag]];
    [dicDrink setObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
    [self.drinksOrdered replaceObjectAtIndex:tag withObject:dicDrink];
    
    NSLog(@"dic drink: %@", dicDrink);
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:tag inSection:0];
    if ([[dicDrink objectForKey:@"quantity"] intValue] == 0) {
        [self.drinksOrdered removeObjectAtIndex:tag];
        [self.tableViewDrinks deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        NewDrinkSelectCell *cell = (NewDrinkSelectCell *)[self.tableViewDrinks cellForRowAtIndexPath:path];
        cell.quantityLabel.text = [NSString stringWithFormat:@" ADDED x %i ", quantity];
        [cell.stepper setCurrent:quantity];
    }

    [self updatePricesAndTotals];
    [self updatePlaceOrderButton];
}

-(void)updatePlaceOrderButton
{
    if ([self.drinksOrdered count] > 0) {
        [self.placeOrderButton setEnabled:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.placeOrderButton setEnabled:NO];
    }
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
//    return [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0];
    return [UIColor belizeHoleColor];
}


-(UIColor *)colorForTitleLabelAtIndex:(int)index {
//    return [UIColor colorWithWhite:1.0 alpha:0.85];
    return [UIColor whiteColor];
}

-(UIColor *)colorForTitleArrowAtIndex:(int)index {
    return [UIColor colorWithWhite:0.0 alpha:0.0];
}

-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open
{
    if (!open) {
        [self.collapsableDrinkOrder openCollapseClickCellAtIndex:index animated:NO];
    }
}

#pragma mark - Unlock Slider Delegate
-(void)sliderDidFinishUnlocking
{
    [self placeOrderCheck];
    [self.unlockSliderPlaceOrder lockSlider];
}

@end
