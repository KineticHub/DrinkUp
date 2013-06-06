//
//  BSTDrinkSelectionViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BSTDrinkSelectionViewController.h"
#import "ActionSheetStringPicker.h"
#import "ConfirmOrderViewController.h"
#import "DrinkSelectCell.h"


@interface BSTDrinkSelectionViewController ()
@property int drinkType;
@property (nonatomic, strong) NSString *drinkTypeName;
@property (nonatomic, strong) NSMutableArray *drinks;
@property (nonatomic, strong) NSMutableArray *drinksOrder;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property int SelectedDrinkRow;
@end

@implementation BSTDrinkSelectionViewController

-(id)initWithDrinkType:(int)drinkType typeName:(NSString *)drinkTypeName {
    self = [super initWithUpperViewHieght:60.0];
    if (self) {
        self.drinkType = drinkType;
        self.drinkTypeName = drinkTypeName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.drinks = [[NSMutableArray alloc] init];
    self.drinksOrder = [SharedDataHandler sharedInstance].currentDrinkOrder;
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.upperView.frame.size.width, self.upperView.frame.size.height)];
    [typeLabel setTextAlignment:NSTextAlignmentCenter];
    [typeLabel setText:self.drinkTypeName];
    [typeLabel setFont:[UIFont boldSystemFontOfSize:36.0]];
    [self.upperView addSubview:typeLabel];
    
    [self.tableView setRowHeight:65.0];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinksForSection:[SharedDataHandler sharedInstance].current_section withType:self.drinkType onCompletion:^(NSMutableArray *objects) {
            
            for (NSDictionary *drink in objects) {
                bool found = NO;
                for (NSDictionary *drinkOrdered in self.drinksOrder) {
                    if ([[drink objectForKey:@"id"] intValue] == [[drinkOrdered objectForKey:@"id"] intValue]) {
                        [self.drinks addObject:drinkOrdered];
                        found = YES;
                    }
                }
                if (!found) {
                    [self.drinks addObject:drink];
                }
            }
            
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.drinks count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DrinkSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[DrinkSelectCell alloc] initWithReuseIdentifier:@"CellIdentifier"];
	}
    
    NSDictionary *drink = [self.drinks objectAtIndex:[indexPath section]];
    
    cell.textLabel.text = [drink objectForKey:@"name"];
    [cell setDrinkQuantity:[[drink objectForKey:@"quantity"] intValue]];
    
    if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
        [cell setCostLabelAmount:[NSString stringWithFormat:@"$%@", [drink objectForKey:@"happyhour_price"]]];
    } else {
        [cell setCostLabelAmount:[NSString stringWithFormat:@"$%@", [drink objectForKey:@"price"]]];
    }
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    self.SelectedDrinkRow = [indexPath section];
    NSDictionary *drink = [self.drinks objectAtIndex:self.SelectedDrinkRow];
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
    
    NSString *priceString;
    
    if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
        priceString = [NSString stringWithFormat:@"$%@", [drink objectForKey:@"happyhour_price"]];
    } else {
        priceString = [NSString stringWithFormat:@"$%@", [drink objectForKey:@"price"]];
    }
    
    
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
    
    NSMutableDictionary *dicDrink = [NSMutableDictionary dictionaryWithDictionary:[self.drinks objectAtIndex:self.SelectedDrinkRow]];
    [dicDrink setObject:[NSNumber numberWithInteger:[selectedIndex integerValue]] forKey:@"quantity"];
    
    [self.drinks replaceObjectAtIndex:self.SelectedDrinkRow withObject:dicDrink];
    
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
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:self.SelectedDrinkRow];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [super checkPlaceOrderBarOption];
}

@end
