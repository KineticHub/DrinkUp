//
//  DrinkSelectionViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/16/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "DrinkSelectionViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "ActionSheetStringPicker.h"
#import "SharedDataHandler.h"
#import "ConfirmOrderViewController.h"

@interface DrinkSelectionViewController ()
@property int drinkType;
@property (nonatomic, strong) NSMutableArray *drinks;
@property (nonatomic, strong) NSMutableArray *drinksOrder;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property int SelectedDrinkRow;
@end

@implementation DrinkSelectionViewController

-(id)initWithDrinkType:(int)drinkType {
    
    self = [super init];
    
    if (self) {
        self.drinkType = drinkType;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    //check drinks order and update the quantity in current drink dictionary
    
    CGFloat bottomViewHeight = 44.0;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.view addSubview:self.tableView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:bottomView];
    
    UIButton *addToOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [addToOrder setFrame:CGRectMake(0, 0, 300.0, 30.0)];
    addToOrder.center = CGPointMake(bottomView.frame.size.width/2, bottomView.frame.size.height/2);
    [addToOrder setTitle:@"Current Order" forState:UIControlStateNormal];
    [addToOrder addTarget:self action:@selector(viewCurrentOrderConfirm) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addToOrder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.drinks = [[NSMutableArray alloc] init];
    self.drinksOrder = [SharedDataHandler sharedInstance].currentDrinkOrder;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinksForSection:[SharedDataHandler sharedInstance].current_section withType:self.drinkType onCompletion:^(NSMutableArray *objects) {
            
            NSLog(@"drinks ordered so far drink selection view: %@", self.drinksOrder);
            
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
            
            NSLog(@"drinks to select: %@", self.drinks);
            
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
}

-(void)viewCurrentOrderConfirm {
    ConfirmOrderViewController *confirmVC = [[ConfirmOrderViewController alloc] init];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.drinks count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
	}
    
    NSDictionary *drink = [self.drinks objectAtIndex:[indexPath row]];
    
    NSString *detailString;
    if ([[drink objectForKey:@"quantity"] integerValue] > 0) {
        detailString = [NSString stringWithFormat:@"%i  x  $%@", [[drink objectForKey:@"quantity"] integerValue], [drink objectForKey:@"price"]];
    } else {
        detailString = [NSString stringWithFormat:@"$%@", [drink objectForKey:@"price"]];
    }
    
    cell.textLabel.text = [drink objectForKey:@"name"];;
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
    if (addDrink) {
        [self.drinksOrder addObject:dicDrink];
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.SelectedDrinkRow inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
