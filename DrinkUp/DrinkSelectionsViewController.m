//
//  DrinkSelectionsViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/21/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "DrinkSelectionsViewController.h"
#import "SharedDataHandler.h"
#import "MBProgressHUD.h"
#import "BasicCell.h"
#import "DrinkSelectCell.h"

@interface DrinkSelectionsViewController ()
@property int section_id;
@property int drinkType;
@property (nonatomic, strong) UITableView *typeTable;
@property (nonatomic, strong) UITableView *drinkTable;
@property (nonatomic, strong) NSMutableArray *drinkTypes;
@property (nonatomic, strong) NSMutableArray *drinks;
@property (nonatomic, strong) NSMutableArray *drinksOrder;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation DrinkSelectionsViewController

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
    
    self.drinkTypes = [[NSMutableArray alloc] init];
    self.drinks = [[NSMutableArray alloc] init];
    self.drinksOrder = [SharedDataHandler sharedInstance].currentDrinkOrder;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinkTypesForBarSection:self.section_id onCompletion:^(NSMutableArray *objects) {
            self.drinkTypes = [NSMutableArray arrayWithArray:objects];
            [self.typeTable reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
    
    self.typeTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 100.0, 80.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 100.0) style:UITableViewStylePlain];
    [self.typeTable setDelegate:self];
    [self.typeTable setDataSource:self];
    [self.typeTable setBackgroundView:nil];
//    [self.typeTable setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:1.0]];
    [self.typeTable setBackgroundColor:[UIColor colorWithRed:(59/255.0) green:(129/255.0) blue:(135/255.0) alpha:0.5]];
    [self.typeTable setRowHeight:70.0];
    [self.typeTable setSeparatorColor:[UIColor clearColor]];
//    [self.typeTable.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(129/255.0) blue:(135/255.0) alpha:1.0] CGColor]];
//    [self.typeTable.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.typeTable.layer setBorderColor: [[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.7] CGColor]];
    [self.typeTable.layer setBorderWidth:1.0];
    [self.view addSubview:self.typeTable];
    
    self.drinkTable = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.typeTable.frame), 100.0, 320.0 - 80.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 100.0) style:UITableViewStylePlain];
    [self.drinkTable setDelegate:self];
    [self.drinkTable setDataSource:self];
    [self.drinkTable setBackgroundView:nil];
//    [self.drinkTable setBackgroundColor:[UIColor clearColor]];
//    [self.drinkTable setBackgroundColor:[UIColor colorWithRed:(250/255.0) green:(250/255.0) blue:(247/255.0) alpha:0.5]];
    [self.drinkTable setBackgroundColor:[UIColor colorWithRed:(59/255.0) green:(129/255.0) blue:(135/255.0) alpha:0.5]];
    [self.drinkTable setRowHeight:70.0];
    [self.drinkTable setSeparatorColor:[UIColor clearColor]];
    [self.drinkTable.layer setBorderColor: [[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.7] CGColor]];
    [self.drinkTable.layer setBorderWidth:1.0];
    [self.view addSubview:self.drinkTable];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, tableView.center.y - 15.0, tableView.frame.size.width, 30.0)];
//        [typeLabel setCenter:CGPointMake(typeLabel.center.x, nearbyView.center.y)];
        [typeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [typeLabel setBackgroundColor:[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.7]];
        [typeLabel setTextAlignment:NSTextAlignmentCenter];
        [typeLabel setTextColor:[UIColor whiteColor]];
        [typeLabel setText:@"Types"];
//        return typeLabel;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
//        return 30.0;
        return 0.0;
    }
    return 0.0;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.typeTable) {
        return [self.drinkTypes count];
    }

	return [self.drinks count];
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.typeTable)
    {
//        BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell"];
        
        if (!cell) {
//            cell = [[BasicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TypeCell"];
            cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TypeCell"];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            
//            UIView *highlightedBackgroundView = [[UIView alloc] init];
//            [highlightedBackgroundView setBackgroundColor:[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.7]];
//            [highlightedBackgroundView.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
//            [highlightedBackgroundView.layer setBorderWidth:2.0];
//            [cell setSelectedBackgroundView:highlightedBackgroundView];
            
//            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *highlightedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame)-5.0, 0.0, 5.0, 70.0)];
            [highlightedBackgroundView setBackgroundColor:[UIColor colorWithRed:(59/255.0) green:(129/255.0) blue:(135/255.0) alpha:0.5]];
//            [highlightedBackgroundView setBackgroundColor:[UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.7]];
//            [highlightedBackgroundView setBackgroundColor:[UIColor colorWithRed:(139/255.0) green:(229/255.0) blue:(234/255.0) alpha:1.0]];
//            [highlightedBackgroundView.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
//            [highlightedBackgroundView.layer setBorderWidth:2.0];
            [cell setSelectedBackgroundView:highlightedBackgroundView];
//            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        NSDictionary *type = [self.drinkTypes objectAtIndex:[indexPath section]];
        cell.textLabel.text = [type objectForKey:@"name"];
        [cell.textLabel setFont:[UIFont systemFontOfSize:18.0]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        cell.contentView.backgroundColor = [UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.7];
//        [cell setCellImage:[NSURLRequest requestWithURL:[NSURL URLWithString:[type objectForKey:@"icon"]]]];
        
        return cell;
    } else
    {
//        DrinkSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DrinkCell"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DrinkCell"];
        
        if (!cell) {
//            cell = [[DrinkSelectCell alloc] initWithReuseIdentifier:@"DrinkCell"];
            cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DrinkCell"];
            [cell.textLabel setBackgroundColor:[UIColor clearColor]];
//            [cell.textLabel setTextColor:[UIColor colorWithRed:(0/255.0) green:(90/255.0) blue:(95/255.0) alpha:1.0]];
//            [cell.textLabel setTextColor:[UIColor blackColor]];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
            [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setTextColor:[UIColor colorWithRed:(139/255.0) green:(229/255.0) blue:(234/255.0) alpha:1.0]];
//            cell.contentView.backgroundColor = [UIColor colorWithRed:(190/255.0) green:(189/255.0) blue:(187/255.0) alpha:0.1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:(26/255.0) green:(26/255.0) blue:(26/255.0) alpha:0.6];
//            cell.contentView.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.8];
        }
        
        NSDictionary *drink = [self.drinks objectAtIndex:[indexPath section]];
        
        NSString *priceKey;
        if ([[SharedDataHandler sharedInstance] isBarHappyHour]) {
            priceKey = @"happyhour_price";
        } else {
            priceKey = @"price";
        }
        NSString *priceString = [NSString stringWithFormat:@"$%@", [drink objectForKey:priceKey]];
        
        cell.textLabel.text = [drink objectForKey:@"name"];
        cell.detailTextLabel.text = @"Price: $4.50\n Quantity: 0";
//        [cell setCostLabelAmount:priceString];
//        [cell setCostLabelAmount:@"$99.99"];
//        [cell setDrinkQuantity:[[drink objectForKey:@"quantity"] intValue]];
//        [cell setDrinkQuantity:12];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    cell.textLabel.text = @"default";
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.typeTable) {
        NSDictionary *selectedType = [self.drinkTypes objectAtIndex:[indexPath section]];
        self.drinkType = [[selectedType objectForKey:@"id"] intValue];
        [self setupDrinkSelection];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *highlightedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame)-5.0, 0.0, 5.0, 70.0)];
        [highlightedBackgroundView setBackgroundColor:[UIColor colorWithRed:(139/255.0) green:(229/255.0) blue:(234/255.0) alpha:1.0]];
//        [cell addSubview:highlightedBackgroundView];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)setupDrinkSelection {
    
    [self.drinks removeAllObjects];
    
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
            
            [self.drinkTable reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

@end
