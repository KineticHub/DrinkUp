//
//  BasicSplitTableViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "BasicSplitTableViewController.h"
#import "ConfirmOrderViewController.h"

#define BOTTOM_BAR_HEIGHT 60.0

static UIView *bottomBar = nil;
static bool isShowingBottomBar = NO;

@interface BasicSplitTableViewController ()
@property (nonatomic) UIView *gradientView;
@property (nonatomic) CAGradientLayer *maskLayer;
@property (nonatomic) CGFloat upperViewHeight;
@property (nonatomic) CGFloat bottomBarHeight;
@end

@implementation BasicSplitTableViewController

-(id)init {
    return [self initWithUpperViewHieght:180.0];
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
    self.upperView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - 10.0, upperViewHeight - 10.0)];
    [self.upperView.layer setCornerRadius:8.0];
    [self.upperView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.upperView.layer setBorderWidth:4.0];
    [self.upperView.layer setMasksToBounds:YES];
    
    UIView *shadowUpperView = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, self.view.frame.size.width - 10.0, upperViewHeight - 10.0)];
    [shadowUpperView.layer setShadowRadius:4.0];
    [shadowUpperView.layer setShadowOpacity:0.5];
    [shadowUpperView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [shadowUpperView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    [shadowUpperView addSubview:self.upperView];
    [self.view addSubview:shadowUpperView];
//    [self.view addSubview:self.upperView];
    
    UIView *background = [[UIView alloc] init];
    [background setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_thread"]]];
    background.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, upperViewHeight, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - upperViewHeight) style:UITableViewStylePlain];
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - upperViewHeight) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:background];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
//    [self.tableView setOpaque:NO];
    [self.tableView setRowHeight:100.0];
//    [self.tableView setSeparatorColor:[UIColor colorWithRed:(31/255.0) green:(31/255.0) blue:(31/255.0) alpha:1.0]];
//    [self.tableView setSeparatorColor:[UIColor colorWithRed:(181/255.0) green:(163/255.0) blue:(28/255.0) alpha:1.0]];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
    [self.view addSubview:self.tableView];
    
    self.gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(shadowUpperView.frame), self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - upperViewHeight)];
    [self.gradientView setBackgroundColor:[UIColor clearColor]];
    [self.gradientView setOpaque:NO];
//    [self.view addSubview:self.gradientView];
//    [self.gradientView addSubview:self.tableView];
//    [self initTableMask];
    
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

-(void)initTableMask {
    self.maskLayer = [CAGradientLayer layer];
    self.maskLayer.colors = @[
                              (id)[UIColor clearColor].CGColor,
                              (id)[UIColor whiteColor].CGColor,
                              (id)[UIColor whiteColor].CGColor,
                              (id)[UIColor whiteColor].CGColor,
                              (id)[UIColor whiteColor].CGColor];
    self.maskLayer.locations = @[ @0.0f, @0.1f, @0.1f, @0.1f, @0.1f ];
    self.maskLayer.frame = self.gradientView.bounds;
    self.gradientView.layer.mask = self.maskLayer;
}

#pragma mark - TableView Data and Delegate Methods

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return 
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return 12.0;
//    }
    
    return 0.0;
}

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
    
    [UIView animateWithDuration:0.0 animations:^{
        CGRect bottomBarFrame = bottomBar.frame;
        bottomBarFrame.origin.y += bottomBar.frame.size.height;
        [bottomBar setFrame:bottomBarFrame];
    }];
}

#pragma mark - Confirm Order Button Method
-(void)viewCurrentOrderView
{
    UIRemoteNotificationType status = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (![SharedDataHandler sharedInstance].isUserAuthenticated)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Login Required"
                                                          message:@"You must be logged in to place orders. Please go to the settings menu and login."
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
    }
    else if (![SharedDataHandler sharedInstance].userCard)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Credit Card Required"
                                                          message:@"You must have a credit card associated with your account to place and order."
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
    }
    else if (status == UIRemoteNotificationTypeNone)
    {
        NSLog(@"User doesn't want to receive push-notifications, need to force use");
        [SharedDataHandler sharedInstance].isNotificationsEnabled = NO;
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Push Notifications Disabled"
                                                          message:@"We cannot let you know when your order is ready without notifications. Please turn notifications on in the Settings App to place the order."
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
    }
    else
    {
        ConfirmOrderViewController *confirmVC = [[ConfirmOrderViewController alloc] init];
        [self.navigationController pushViewController:confirmVC animated:YES];
    }
    
}

@end
