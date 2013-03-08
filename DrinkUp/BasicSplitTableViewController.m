//
//  BasicSplitTableViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BasicSplitTableViewController.h"
#import "BasicCell.h"
#import "ConfirmOrderViewController.h"
#import "SharedDataHandler.h"

#define BOTTOM_BAR_HEIGHT 60.0

static UIView *bottomBar = nil;
static bool isShowingBottomBar = NO;

@interface BasicSplitTableViewController ()
@property (nonatomic) CGFloat upperViewHeight;
@property (nonatomic) CGFloat bottomBarHeight;
@end

@implementation BasicSplitTableViewController

-(id)init {
    return [self initWithUpperViewHieght:150.0];
}

-(id)initWithUpperViewHieght:(CGFloat)upperViewHeight {
    
    self = [super init];
    if (self) {
        self.upperViewHeight = upperViewHeight;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];

    self.bottomBarHeight = BOTTOM_BAR_HEIGHT;
    
    CGFloat upperViewHeight = self.upperViewHeight;
    self.upperView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, upperViewHeight)];
    [self.view addSubview:self.upperView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, upperViewHeight, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - upperViewHeight) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setRowHeight:70.0];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    
    if (!bottomBar) {
        CGFloat bottomBarHeight = self.bottomBarHeight;
    //    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, bottomBarHeight)];
    //    [self.bottomBar setBackgroundColor:[UIColor redColor]];
    //    [self.view addSubview:self.bottomBar];
        bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.view.frame.size.height, self.view.frame.size.width, bottomBarHeight)];
        [bottomBar setBackgroundColor:[UIColor darkGrayColor]];
        [bottomBar setTag:BOTTOM_BAR_TAG];
        [self.navigationController.view addSubview:bottomBar];
        
        UIButton *placeOrderButton = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
        [placeOrderButton setFrame:CGRectMake(0, 0, BOTTOM_BAR_HEIGHT * 3.0, BOTTOM_BAR_HEIGHT - 10.0)];
        [placeOrderButton setCenter:CGPointMake(bottomBar.frame.size.width/2, bottomBar.frame.size.height/2)];
        [placeOrderButton setTitle:@"Place Order" forState:UIControlStateNormal];
        [placeOrderButton addTarget:self action:@selector(viewCurrentOrderView) forControlEvents:UIControlEventTouchUpInside];
        [bottomBar addSubview:placeOrderButton];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkPlaceOrderBarOption];
    
    CGRect tableViewRect = self.tableView.frame;
    if (isShowingBottomBar) {
        tableViewRect.size.height = self.view.frame.size.height - self.upperViewHeight - BOTTOM_BAR_HEIGHT;
    } else {
        tableViewRect.size.height = self.view.frame.size.height - self.upperViewHeight;
    }
    self.tableView.frame = tableViewRect;
}

#pragma mark - TableView Data and Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[BasicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
	}
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Show Place Order Bar
-(void)shouldShowPlaceOrderBarOption:(bool)shouldShow withDuration:(float)duration
{
    NSLog(@"Should Show: %i Is Showing: %i", shouldShow, isShowingBottomBar);
    if (shouldShow != isShowingBottomBar) {
        [UIView animateWithDuration:duration animations:^{
            CGRect bottomBarFrame = bottomBar.frame;
            CGRect tableViewFrame = self.tableView.frame;
            
            if (shouldShow) {
                bottomBarFrame.origin.y -= self.bottomBarHeight;
                tableViewFrame.size.height -= self.bottomBarHeight;
            } else {
                bottomBarFrame.origin.y += self.bottomBarHeight;
                tableViewFrame.size.height += self.bottomBarHeight;
            }
            
            [bottomBar setFrame:bottomBarFrame];
            [self.tableView setFrame:tableViewFrame];
        }];
        
        isShowingBottomBar = !isShowingBottomBar;
    }
}

-(void)checkPlaceOrderBarOption {
    
    [self checkPlaceOrderBarOptionWithDuration:0.5];
}

-(void)checkPlaceOrderBarOptionWithDuration:(float)duration
{
    if ([[SharedDataHandler sharedInstance].currentDrinkOrder count] > 0) {
        [self shouldShowPlaceOrderBarOption:YES withDuration:duration];
    } else {
        [self shouldShowPlaceOrderBarOption:NO withDuration:duration];
    }
}

+(void)forceHidePlaceOrderBar {
    isShowingBottomBar = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect bottomBarFrame = bottomBar.frame;
        bottomBarFrame.origin.y += bottomBar.frame.size.height;
        [bottomBar setFrame:bottomBarFrame];
    }];
}

#pragma mark - Confirm Order Button Method
-(void)viewCurrentOrderView {
    ConfirmOrderViewController *confirmVC = [[ConfirmOrderViewController alloc] init];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

@end
