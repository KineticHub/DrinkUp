//
//  SelectBarViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "DrinkHistoryViewController.h"

@interface DrinkHistoryViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *drinksHistory;
@property int historyType;
@end

@implementation DrinkHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat topViewHeight = 50.0;
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    self.drinksHistory = [[NSMutableArray alloc] init];
    
    UIView *topSection = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, topViewHeight)];
    [topSection setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:topSection];
    
    UISegmentedControl *segControls = [[UISegmentedControl alloc] initWithItems:@[@"Tonight", @"This Week", @"Forever"]];
    [segControls setSelectedSegmentIndex:0];
    [segControls setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
    [segControls addTarget:self action:@selector(segControlsValueChanged:) forControlEvents: UIControlEventValueChanged];
    [topSection addSubview:segControls];
    
    self.historyType = 0;
    [self setupFakeData];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0 + topViewHeight, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - topViewHeight) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.view addSubview:self.tableView];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.historyType == 1) {
        return [self.drinksHistory count];
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.historyType == 1) {
        return [[self.drinksHistory objectAtIndex:section] count];
    }
    return [self.drinksHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (self.historyType == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MonthCellIdentifier"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DrinkCellIdentifier"];
    }
    
    
	if (cell == nil) {
        
        if (self.historyType == 2) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MonthCellIdentifier"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DrinkCellIdentifier"];
        }
	}
    
    if (self.historyType == 0) {
        
        NSDictionary *drink = [self.drinksHistory objectAtIndex:[indexPath row]];
        cell.textLabel.text = [drink objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [drink objectForKey:@"time"], [drink objectForKey:@"bar"] ];
        
    } else if (self.historyType == 1) {
        
        NSDictionary *drink = [[self.drinksHistory objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        cell.textLabel.text = [drink objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [drink objectForKey:@"time"], [drink objectForKey:@"bar"] ];
        
    } else if (self.historyType == 2) {
        
        NSDictionary *monthInfo = [self.drinksHistory objectAtIndex:[indexPath row]];
        cell.textLabel.text = [monthInfo objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", [[monthInfo objectForKey:@"amount"] floatValue]];
    }
    
    return cell;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell Chosen %i", [indexPath row]);
}

#pragma mark - Segment Control Method

-(void)segControlsValueChanged:(id)sender {
    
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    self.historyType = segControl.selectedSegmentIndex;
    
    [self setupFakeData];
    
    // GET NEW DATA SYNCRONOUSLY
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    NSLog(@"Value: %i", segControl.selectedSegmentIndex);
}

#pragma mark - Fake Data
-(void)setupFakeData {
    
    if (self.historyType == 0) {
        NSDictionary *drink1 = @{@"name": @"Sam Lite", @"price": @"5.50", @"quantity":@0};
        NSDictionary *drink2 = @{@"name": @"Budweiser", @"price": @"7.00", @"quantity":@0};
        NSDictionary *drink3 = @{@"name": @"Corona", @"price": @"6.00", @"quantity":@0};
        self.drinksHistory = [NSMutableArray arrayWithArray: @[drink1, drink2, drink3]];
    }
    
    if (self.historyType == 1) {
        NSDictionary *drink1 = @{@"name": @"Sam Lite", @"price": @"5.50", @"quantity":@0};
        NSDictionary *drink2 = @{@"name": @"Budweiser", @"price": @"7.00", @"quantity":@0};
        NSDictionary *drink3 = @{@"name": @"Corona", @"price": @"6.00", @"quantity":@0};
        
        self.drinksHistory = [[NSMutableArray alloc] init];
        NSArray *tempArray;
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
        tempArray = @[drink1, drink2, drink3];
        [self.drinksHistory addObject:tempArray];
    }
    
    if (self.historyType == 2) {
        NSDictionary *month1 = @{@"name": @"January", @"amount": @"20.65"};
        NSDictionary *month2 = @{@"name": @"February", @"amount": @"17.43"};
        self.drinksHistory = [NSMutableArray arrayWithArray: @[month1, month2]];
    }
}

@end
