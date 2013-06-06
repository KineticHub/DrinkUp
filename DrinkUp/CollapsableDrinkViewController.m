//
//  CollapsableDrinkViewController.m
//  DrinkUp
//
//  Created by Kinetic on 6/6/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "CollapsableDrinkViewController.h"
#import "NewDrinkSelectCell.h"

@interface CollapsableDrinkViewController ()
@property int section_id;
@property (nonatomic, strong) CollapseClick *collapsableDrinkTypes;
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
	
    self.collapsableDrinkTypes = [[CollapseClick alloc] initWithFrame:self.view.frame];
    [self.collapsableDrinkTypes setCollapseClickDelegate:self];
    [self.collapsableDrinkTypes reloadCollapseClick];
    [self.view addSubview:self.collapsableDrinkTypes];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0) {
        return 2;
    } else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"SpecialCell";
    NewDrinkSelectCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[NewDrinkSelectCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    cell.priceLabel.text = @" $12.50 ";
    cell.quantityLabel.text = @" ADDED x 4 ";
    cell.textLabel.text = @"VODKA & CLUB SODA (RAIL)";
    
    return cell;
}

#pragma mark - Collapse Click Delegate

// Required Methods
-(int)numberOfCellsForCollapseClick {
    return 3;
}

-(NSString *)titleForCollapseClickAtIndex:(int)index {
    switch (index) {
        case 0:
            return @"Login To CollapseClick";
            break;
        case 1:
            return @"Create an Account";
            break;
        case 2:
            return @"Terms of Service";
            break;
            
        default:
            return @"Another Cell";
            break;
    }
}

-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index {
    switch (index) {
        case 0:
        {
            UITableView *testView1 = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300, 65 * 2)];
            [testView1 setBackgroundColor:[UIColor whiteColor]];
            [testView1 setDelegate:self];
            [testView1 setDataSource:self];
            [testView1 setRowHeight:65.0];
            testView1.tag = 0;
            return testView1;
            break;
        }
        case 1:
        {
            UITableView *testView1 = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300, 65 * 4)];
            [testView1 setBackgroundColor:[UIColor whiteColor]];
            [testView1 setDelegate:self];
            [testView1 setDataSource:self];
            [testView1 setRowHeight:65.0];
            testView1.tag = 1;
            return testView1;
            break;
        }
        case 2:
        {
            UITableView *testView1 = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300, 65 * 4)];
            [testView1 setBackgroundColor:[UIColor whiteColor]];
            [testView1 setDelegate:self];
            [testView1 setDataSource:self];
            [testView1 setRowHeight:65.0];
            testView1.tag = 1;
            return testView1;
            break;
        }
        default:
        {
            UITableView *testView1 = [[UITableView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300, 65 * 2)];
            [testView1 setBackgroundColor:[UIColor whiteColor]];
            [testView1 setDelegate:self];
            [testView1 setDataSource:self];
            [testView1 setRowHeight:65.0];
            testView1.tag = 0;
            return testView1;
            break;
        }
    }
}


// Optional Methods

-(UIColor *)colorForCollapseClickTitleViewAtIndex:(int)index {
    return [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0];
}


-(UIColor *)colorForTitleLabelAtIndex:(int)index {
    return [UIColor colorWithWhite:1.0 alpha:0.85];
}

-(UIColor *)colorForTitleArrowAtIndex:(int)index {
    return [UIColor colorWithWhite:1.0 alpha:0.25];
}

@end
