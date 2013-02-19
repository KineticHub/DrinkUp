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
@property (nonatomic, strong) NSMutableArray *drinks;
@property (nonatomic, strong) NSMutableArray *drinksOrder;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property int SelectedDrinkRow;
@end

@implementation DrinkSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    self.drinks = [[NSMutableArray alloc] init];
    self.drinksOrder = [[NSMutableArray alloc] initWithArray:[[SharedDataHandler sharedInstance] getCurrentOrder]];
    
    //check drinks order and update the quantity in current drink dictionary
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] loadDrinksForBar:@"" onCompletion:^(NSMutableArray *objects) {
            
            self.drinks = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    });
    
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
    [addToOrder setTitle:@"Add to Order" forState:UIControlStateNormal];
    [addToOrder addTarget:self action:@selector(addDrinksToCurrentOrder) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addToOrder];
}

-(void)addDrinksToCurrentOrder {
    [[SharedDataHandler sharedInstance] addDrinksToCurrentOrder:self.drinksOrder];
    
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
        detailString = [NSString stringWithFormat:@"%i  x  %@", [[drink objectForKey:@"quantity"] integerValue], [drink objectForKey:@"price"]];
    } else {
        detailString = [NSString stringWithFormat:@"%@", [drink objectForKey:@"price"]];
    }
    
    cell.textLabel.text = [drink objectForKey:@"name"];;
    cell.detailTextLabel.text = detailString;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[drink objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    
    NSLog(@"Drink for row %i: %@", [indexPath row], drink);
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell Chosen %i", [indexPath row]);
    self.SelectedDrinkRow = [indexPath row];
    
    NSArray *amounts = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Quantity" rows:amounts initialSelection:0 target:self successAction:@selector(quantityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:[tableView cellForRowAtIndexPath:indexPath]];
}

-(void)actionPickerCancelled {
    NSLog(@"Cancelled");
}

- (void)quantityWasSelected:(NSNumber *)selectedIndex element:(id)element {
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    NSLog(@"Quantity %i", [selectedIndex intValue]);
    
    NSMutableDictionary *dicDrink = [NSMutableDictionary dictionaryWithDictionary:[self.drinks objectAtIndex:self.SelectedDrinkRow]];
    [dicDrink setObject:[NSNumber numberWithInteger:[selectedIndex integerValue] + 1] forKey:@"quantity"];
    [self.drinks replaceObjectAtIndex:self.SelectedDrinkRow withObject:dicDrink];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.SelectedDrinkRow inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//#pragma mark - Setup ActionSheet
//-(void)setupPickerAndActionSheet {
//    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//    
//    
//    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,40, 320, 216)];
//    self.pickerView.showsSelectionIndicator=YES;
//    self.pickerView.dataSource = self;
//    self.pickerView.delegate = self;
////    picker.tag=SelectedDropDown;
//    [self.actionSheet addSubview:self.pickerView];
//    
//    
//    
//    UIToolbar *tools=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,320,40)];
//    tools.barStyle=UIBarStyleBlackOpaque;
//    [self.actionSheet addSubview:tools];
//    
//    
//    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(btnActionDoneClicked)];
//    doneButton.imageInsets=UIEdgeInsetsMake(200, 6, 50, 25);
//    UIBarButtonItem *CancelButton=[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(btnActionCancelClicked)];
//    UIBarButtonItem *flexSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    
//    NSArray *array = [[NSArray alloc]initWithObjects:CancelButton,flexSpace,flexSpace,doneButton,nil];
//    
//    [tools setItems:array];
//    
//    
//    //picker title
//    UILabel *lblPickerTitle=[[UILabel alloc]initWithFrame:CGRectMake(60,8, 200, 25)];
//    lblPickerTitle.text=@"Quantity";
//    lblPickerTitle.backgroundColor=[UIColor clearColor];
//    lblPickerTitle.textColor=[UIColor whiteColor];
//    lblPickerTitle.textAlignment=NSTextAlignmentCenter;
//    lblPickerTitle.font=[UIFont boldSystemFontOfSize:15];
//    [tools addSubview:lblPickerTitle];
//    
//    [self.actionSheet showFromRect:CGRectMake(0,480, 320,215) inView:self.view animated:YES];
//    [self.actionSheet setBounds:CGRectMake(0,0, 320, 411)];
//}
//
//#pragma mark - PickerView Delegate Methods
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 1;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    return 20;
//}
//
//-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
//    label.text = [NSString stringWithFormat:@"%i", row + 1];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor clearColor];
//    return label;
//}
//
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSLog(@"Selected: %i", row);
//}
//
//-(void)btnActionDoneClicked {
//    NSLog(@"Selected: %i", [self.pickerView selectedRowInComponent:0]);
//    [UIView animateWithDuration:0.2 delay:0.0 options:nil
//                     animations:^{
//                         self.actionSheet.frame = CGRectMake(0, 480, 320, 215);
//                     }
//                     completion:nil];
//}
//
//-(void)btnActionCancelClicked {
//    [UIView animateWithDuration:0.2 delay:0.0 options:nil
//                     animations:^{
//                         self.actionSheet.frame = CGRectMake(0, 480, 320, 215);
//                     }
//                     completion:nil];
//}

@end
