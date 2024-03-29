//
//  CollapsableDrinkViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CollapsableDrinkViewController.h"
#import "NewDrinkSelectCell.h"
#import "MBProgressHUD.h"
#import "SharedDataHandler.h"
#import "ActionSheetPicker.h"
#import "TextStepperField.h"
#import "UserLoginViewController.h"
#import "ConfirmOrderViewController.h"
#import "OrderViewController.h"
#import "QBFlatButton.h"
#import "CustomBarButton.h"

#import "UIColor+FlatUI.h"
#import "FUIAlertView.h"
#import "UIFont+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "KUIHelper.h"

#define kCellHeight 65.0

@interface CollapsableDrinkViewController ()
{
	ZKRevealingTableViewCell *_currentlyRevealedCell;
}
@property bool collapseReload;
@property int section_id;
@property (nonatomic, retain) ZKRevealingTableViewCell *currentlyRevealedCell;
@property (nonatomic, strong) CollapseClick *collapsableDrinkTypes;
@property (nonatomic, strong) UIBarButtonItem *orderBarButtonItem;
@property (nonatomic, strong) NSMutableDictionary *tableViewDictionary;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexes;
@property (nonatomic, strong) NSMutableArray *selectedCollapses;
@property (nonatomic, strong) NSMutableArray *drinkTypes;
@property (nonatomic, strong) NSMutableArray *drinksOrder;
@property (nonatomic, strong) NSMutableDictionary *drinks;
@end

@implementation CollapsableDrinkViewController

- (id)initWithBarSection:(int)section_id
{
    self = [super init];
    if (self) {
        self.section_id = section_id;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collapseReload = YES;
    
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height -= self.navigationController.navigationBar.frame.size.height;
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Bar" style:UIBarButtonItemStyleDone target:self action:@selector(showLeavingOptions)];
//    [backButton setTintColor:[UIColor whiteColor]];
//    [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
//    self.navigationItem.leftBarButtonItem = backButton;
    
//    QBFlatButton *leaveButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    leaveButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
//    leaveButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
//    leaveButton.radius = 6.0;
//    leaveButton.margin = 2.0;
//    leaveButton.depth = 2.0;
//    leaveButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [leaveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [leaveButton setTitle:@"Leave Bar" forState:UIControlStateNormal];
//    [leaveButton setFrame:CGRectMake(0.0, 0.0, 85.0, 32.0)];
//    [leaveButton addTarget:self action:@selector(showLeavingOptions) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:leaveButton];
    
//    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
//    [backButton setCustomView:leaveButton];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Bar"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showLeavingOptions)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Create the refresh, fixed-space (optional), and profile buttons.
//    UIBarButtonItem *settingsProfileButton = [[UIBarButtonItem alloc]
//                                             initWithImage:[UIImage imageNamed:@"settings_icon"]
//                                             style:UIBarButtonItemStylePlain
//                                             target:self action:@selector(showUserProfile)];
//    [settingsProfileButton setTintColor:[UIColor whiteColor]];
    
//    UIImage *settingsImage = [UIImage imageNamed:@"gear_24.png"];
//    CustomBarButton *settingsButton = [[CustomBarButton alloc] init];
//    [settingsButton setButtonWithImage:settingsImage];
//    [settingsButton addTarget:self action:@selector(showUserProfile) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsProfileButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showUserProfile)];
//    [settingsProfileButton setCustomView:settingsButton];
    
    //    // Optional: if you want to add space between the refresh & profile buttons
    //    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //    fixedSpaceBarButtonItem.width = 12;
    
//    QBFlatButton *orderButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    orderButton.faceColor = [UIColor grayColor];
//    orderButton.sideColor = [UIColor darkGrayColor];
//    orderButton.radius = 6.0;
//    orderButton.margin = 2.0;
//    orderButton.depth = 2.0;
//    orderButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [orderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [orderButton setTitle:@"View Order" forState:UIControlStateNormal];
//    [orderButton setFrame:CGRectMake(0.0, 0.0, 95.0, 32.0)];
//    [orderButton addTarget:self action:@selector(viewCurrentOrderView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:orderButton];
    
//    self.orderBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"View Order" style:UIBarButtonItemStylePlain target:self action:@selector(viewCurrentOrderView)];
    
    self.orderBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Order"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(viewCurrentOrderView)];
//    [self.orderBarButtonItem setCustomView:orderButton];
    
//    self.orderBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(cancelCurrentOrderCheck)];
//    [self.orderBarButtonItem setTitle:@"View Order"];
//    [self.orderBarButtonItem configureFlatButtonWithColor:[UIColor grayColor] highlightedColor:[UIColor grayColor] cornerRadius:3.0];
    
    self.navigationItem.rightBarButtonItems = @[self.orderBarButtonItem, /* fixedSpaceBarButtonItem, */ settingsProfileButton];
	
    self.collapsableDrinkTypes = [[CollapseClick alloc] initWithFrame:viewFrame];
    [self.collapsableDrinkTypes setCollapseClickDelegate:self];
    [self.view addSubview:self.collapsableDrinkTypes];
    
    self.selectedCollapses = [[NSMutableArray alloc] init];
    self.selectedIndexes = [[NSMutableDictionary alloc] init];
    self.tableViewDictionary = [[NSMutableDictionary alloc] init];
    self.drinkTypes = [[NSMutableArray alloc] init];
    self.drinks = [[NSMutableDictionary alloc] init];
    self.drinksOrder = [SharedDataHandler sharedInstance].currentDrinkOrder;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"open collapses: %@", self.selectedCollapses);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading drinks";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinkTypesForBarSection:self.section_id onCompletion:^(NSMutableArray *objects)
         {
             self.drinkTypes = [NSMutableArray arrayWithArray:objects];
             
             int __block drinkLoadingCounter = [self.drinkTypes count];
             for (NSDictionary *type in self.drinkTypes)
             {
                 [[SharedDataHandler sharedInstance] loadDrinksForSection:[SharedDataHandler sharedInstance].current_section withType:[[type objectForKey:@"id"] intValue] onCompletion:^(NSMutableArray *objects) {
                     
                     NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                     for (NSDictionary *drink in objects)
                     {
                         bool found = NO;
                         for (NSDictionary *drinkOrdered in self.drinksOrder) {
                             if ([[drink objectForKey:@"id"] intValue] == [[drinkOrdered objectForKey:@"id"] intValue]) {
                                 [tempArray addObject:drinkOrdered];
                                 found = YES;
                             }
                         }
                         if (!found) {
                             [tempArray addObject:drink];
                         }
                     }
                     
                     [self.drinks setObject:tempArray forKey:[type objectForKey:@"name"]];
                     
                     UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300, kCellHeight * [tempArray count])];
                     [tableView setBackgroundColor:[UIColor whiteColor]];
                     [tableView setDelegate:self];
                     [tableView setDataSource:self];
                     [tableView setRowHeight:kCellHeight];
                     [tableView setTag:[[type objectForKey:@"id"] intValue]];
                     [self.tableViewDictionary setObject:tableView forKey:[type objectForKey:@"name"]];
                     
                     drinkLoadingCounter--;
                     if (drinkLoadingCounter == 0)
                     {
                         [self updateOrderButton];
                         [self.collapsableDrinkTypes reloadCollapseClick];
                         [self.collapsableDrinkTypes openCollapseClickCellsWithIndexes:self.selectedCollapses animated:NO];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         });
                     }
                 }];
             }
         }];
    });
}

-(void) showLeavingOptions {
    
    if ([[SharedDataHandler sharedInstance].currentDrinkOrder count] > 0)
    {
        [[KUIHelper createAlertViewWithTitle:@"Clear Selected Drinks?"
                                    message:@"Leaving this bar will clear any drinks currently selected at this bar."
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Clear Drinks", nil] show];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) showUserProfile
{
    UserLoginViewController *userLoginVC = [[UserLoginViewController alloc] init];
    [self.navigationController pushViewController:userLoginVC animated:YES];
}

#pragma mark - Confirm Order Button Method
-(void)viewCurrentOrderView
{
    OrderViewController *confirmVC = [[OrderViewController alloc] init];
    [self.navigationController pushViewController:confirmVC animated:YES];
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

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (NSDictionary *type in self.drinkTypes)
    {
        if ([[type objectForKey:@"id"] intValue] == tableView.tag)
        {
            return [[self.drinks objectForKey:[type objectForKey:@"name"]] count];
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"SpecialCell";
    NewDrinkSelectCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[NewDrinkSelectCell alloc] initWithReuseIdentifier:CellIdentifier];
        cell.delegate = self;
        [cell.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventValueChanged];
        cell.stepper.tag = tableView.tag * 1000 + indexPath.row;
    }
    
    NSMutableDictionary *drink;
    for (NSDictionary *type in self.drinkTypes)
    {
        if ([[type objectForKey:@"id"] intValue] == tableView.tag)
        {
            drink = [[self.drinks objectForKey:[type objectForKey:@"name"]] objectAtIndex:indexPath.row];
        }
    }
    
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

- (void)stepperDidStep:(TextStepperField *)stepper
{
    int quantity = (int)stepper.Current;
    
    int tag = stepper.tag;
    int typeIndex = 0;
    while (tag >= 1000) {
        tag -= 1000;
        typeIndex++;
    }
    
    NSDictionary *drinkType;
    for (NSDictionary *type in self.drinkTypes)
    {
        if ([[type objectForKey:@"id"] intValue] == typeIndex)
        {
            drinkType = [NSDictionary dictionaryWithDictionary:type];
        }
    }
    
    NSMutableDictionary *dicDrink = [NSMutableDictionary dictionaryWithDictionary:[[self.drinks objectForKey:[drinkType objectForKey:@"name"]] objectAtIndex:tag]];
    NSLog(@"dic drink: %@", dicDrink);
    [dicDrink setObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];

    [[self.drinks objectForKey:[drinkType objectForKey:@"name"]] setObject:dicDrink atIndex:tag];

    bool addDrink = YES;
    NSDictionary *foundDrink;
    for (NSDictionary *drink in self.drinksOrder) {
        if ([[drink objectForKey:@"id"] intValue] == [[dicDrink objectForKey:@"id"] intValue]) {
            if ([[dicDrink objectForKey:@"quantity"] intValue] == 0) {
                addDrink = NO;
            }
            foundDrink = drink;
            break;
        }
    }

    [self.drinksOrder removeObject:foundDrink];
    if (addDrink && [[dicDrink objectForKey:@"quantity"] intValue] > 0) {
        NSLog(@"ordered: %@", dicDrink);
        [self.drinksOrder addObject:dicDrink];
    }

    NSIndexPath *path = [NSIndexPath indexPathForRow:tag inSection:0];
    NewDrinkSelectCell *cell = (NewDrinkSelectCell *)[[self.tableViewDictionary objectForKey:[drinkType objectForKey:@"name"]] cellForRowAtIndexPath:path];

    [cell.quantityLabel setHidden:NO];
    cell.quantityLabel.text = [NSString stringWithFormat:@" ADDED x %i ", quantity];
    [cell.stepper setCurrent:quantity];
    
    if (quantity == 0) {
        [cell.quantityLabel setHidden:YES];
    }
    
    [self updateOrderButton];
}

-(void)updateOrderButton
{
    NSLog(@"print drinks: %@", [SharedDataHandler sharedInstance].currentDrinkOrder);
    
    if ([self.drinksOrder count] > 0)
    {
//        [self.orderBarButtonItem setTintColor:[UIColor blueColor]];
//        ((QBFlatButton *)self.orderBarButtonItem.customView).faceColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(200/255.0) alpha:1.0];
//        ((QBFlatButton *)self.orderBarButtonItem.customView).sideColor = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(170/255.0) alpha:0.7];
        [self.orderBarButtonItem configureFlatButtonWithColor:[UIColor turquoiseColor] highlightedColor:[UIColor turquoiseColor] cornerRadius:3.0];
        [self.orderBarButtonItem setEnabled:YES];
    } else {
//        [self.orderBarButtonItem setTintColor:[UIColor grayColor]];
//        ((QBFlatButton *)self.orderBarButtonItem.customView).faceColor = [UIColor grayColor];
//        ((QBFlatButton *)self.orderBarButtonItem.customView).sideColor = [UIColor darkGrayColor];
        [self.orderBarButtonItem configureFlatButtonWithColor:[UIColor grayColor] highlightedColor:[UIColor grayColor] cornerRadius:3.0];
        [self.orderBarButtonItem setEnabled:NO];
    }
}

#pragma mark - Collapse Click Delegate

// Required Methods
-(int)numberOfCellsForCollapseClick {
    return [self.drinkTypes count];
}

-(NSString *)titleForCollapseClickAtIndex:(int)index
{
    return [[self.drinkTypes objectAtIndex:index] objectForKey:@"name"];
}

-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index
{
    return [self.tableViewDictionary objectForKey:[[self.drinkTypes objectAtIndex:index] objectForKey:@"name"]];
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
//    return [UIColor colorWithWhite:1.0 alpha:0.25];
    return [UIColor colorWithWhite:1.0 alpha:0.8];
}

-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open
{
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (NSNumber *indexSelected in self.selectedCollapses) {
        if ([indexSelected intValue] == index) {
            [objectsToRemove addObject:indexSelected];
        }
    }
    [self.selectedCollapses removeObjectsInArray:objectsToRemove];
    
    if (open)
    {
        [self.selectedCollapses addObject:[NSNumber numberWithInt:index]];
        [self.collapsableDrinkTypes scrollToCollapseClickCellAtIndex:index animated:YES];
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

@end
