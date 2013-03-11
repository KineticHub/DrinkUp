//
//  SelectBarSectionViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/4/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "SelectBarSectionViewController.h"

@interface SelectBarSectionViewController ()
@property (nonatomic, strong) NSMutableArray *barSections;
@end

@implementation SelectBarSectionViewController

-(id)initWithBarSections:(NSArray *)barSections {
    self = [super init];
    if (self) {
        self.barSections = [NSMutableArray arrayWithArray:barSections];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.barSections count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCell *cell = (BasicCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *barSection = [self.barSections objectAtIndex:[indexPath row]];
    cell.textLabel.text = [barSection objectForKey:@"name"];
    
    return cell;
}

@end
