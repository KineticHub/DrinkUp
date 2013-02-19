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

@interface ConfirmOrderViewController ()
@property (nonatomic, strong) NSMutableArray *drinksOrdered;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISlider *tipSlider;
@property float totalPrice;
@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.drinksOrdered = [NSMutableArray arrayWithArray:[[SharedDataHandler sharedInstance] getCurrentOrder]];
    
    self.totalPrice = 0.00;
    for (NSDictionary *drink in self.drinksOrdered) {
        self.totalPrice += [[drink objectForKey:@"quantity"] floatValue] * [[drink objectForKey:@"price"] floatValue];
    }
    
    CGFloat bottomViewHeight = 70.0;
    CGFloat spacer = 25.0;
    CGFloat bbWidth = (self.view.frame.size.width/3) - (spacer);
    CGFloat bbHeight = bottomViewHeight - 20.0;
    CGFloat bbYPosition = 10.0;
    CGFloat bbXPosition = 10.0;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.view addSubview:self.tableView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:bottomView];
    
    UIButton *cancelOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [cancelOrder setFrame:CGRectMake(bbXPosition, bbYPosition, bbWidth, bbHeight)];
//    cancelOrder.center = CGPointMake(cancelOrder.center.x, bottomView.frame.size.height/2);
    [cancelOrder setTitle:@"Cancel Order" forState:UIControlStateNormal];
    cancelOrder.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cancelOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelOrder addTarget:self action:@selector(cancelCurrentOrder) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelOrder];
    bbXPosition += bbWidth + spacer;
    
//    UIButton *addToOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
//    [addToOrder setFrame:CGRectMake(bbXPosition, bbYPosition, bbWidth, bbHeight)];
////    addToOrder.center = CGPointMake(addToOrder.center.x, bottomView.frame.size.height/2);
//    [addToOrder setTitle:@"Add More Drinks" forState:UIControlStateNormal];
//    addToOrder.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    addToOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [addToOrder addTarget:self action:@selector(addDrinksToCurrentOrder) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:addToOrder];
//    bbXPosition += bbWidth + spacer;
    
    UIButton *placeOrder = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [placeOrder setFrame:CGRectMake(bbXPosition, bbYPosition, bbWidth, bbHeight)];
//    [placeOrder setCenter: CGPointMake(placeOrder.center.x, bottomView.frame.size.height/2)];
    [placeOrder setTitle:@"Place Order" forState:UIControlStateNormal];
    placeOrder.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    placeOrder.titleLabel.textAlignment = NSTextAlignmentCenter;
    [placeOrder addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:placeOrder];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return 3;
    }
    
    return [self. drinksOrdered count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Drinks";
    } else {
        return @"Price";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
	}
    
    if ([indexPath section] == 1) {
        switch ([indexPath row]) {
            case 0:
            {
                cell.textLabel.text = @"Tax and fees";
                cell.detailTextLabel.text = @"amount";
                break;
            }
            case 1:
            {
                cell.textLabel.text = @"Tip";
                cell.detailTextLabel.text = @"10%";
                
                self.tipSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150.0, 20.0)];
                [self.tipSlider setCenter:CGPointMake(cell.center.x, cell.center.y)];
                [self.tipSlider setMaximumValue:100];
                [self.tipSlider setMinimumValue:5];
                [self.tipSlider setValue:10];
                [self.tipSlider addTarget:self action:@selector(tipPercentChanged:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:self.tipSlider];
                
                break;
            }
            case 2:
            {
                cell.textLabel.text = @"Total:";
                
                float tipPercentValue = roundf(self.tipSlider.value) / 100;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.totalPrice + (self.totalPrice * tipPercentValue)];
                break;
            }
                
            default:
                break;
        }
        
        return cell;
    }
    
    NSDictionary *drink = [self.drinksOrdered objectAtIndex:[indexPath row]];
    
    NSString *detailString;
    if ([[drink objectForKey:@"quantity"] integerValue] > 0) {
        detailString = [NSString stringWithFormat:@"%i  x  %@", [[drink objectForKey:@"quantity"] integerValue], [drink objectForKey:@"price"]];
    } else {
        detailString = [NSString stringWithFormat:@"%@", [drink objectForKey:@"price"]];
    }
    
    cell.textLabel.text = [drink objectForKey:@"name"];
    cell.detailTextLabel.text = detailString;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[drink objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"blank_square"]];
    
    NSLog(@"Drink for row %i: %@", [indexPath row], drink);
    
    return cell;
}

-(void)tipPercentChanged:(id)sender {
    
    UISlider *tipSlider = (UISlider *)sender;
    UITableViewCell *tipCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    UITableViewCell *totalCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    
    int tipValue = roundf(tipSlider.value);
    float tipPercentValue = roundf(self.tipSlider.value) / 100;
    tipCell.detailTextLabel.text = [NSString stringWithFormat:@"%i%%", tipValue];
    totalCell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", self.totalPrice + (self.totalPrice * tipPercentValue)];
}

#pragma mark - Ordering Options

-(void)cancelCurrentOrder {
    [[SharedDataHandler sharedInstance] clearCurrentDrinkOrder];
}

-(void)placeOrder {
    ThanksViewController *thanksVC = [[ThanksViewController alloc] init];
    [self.navigationController pushViewController:thanksVC animated:YES];
}

@end
