//
//  PaymentProfilesViewController.m
//  DrinkUp
//
//  Created by Kinetic on 3/5/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//
//  card.io api key = ae8c82d62dc5477e9623e85e82715a1a

#import "PaymentProfilesViewController.h"

@interface PaymentProfilesViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *creditCards;
@end

@implementation PaymentProfilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.creditCards = [[NSMutableArray alloc] init];
    [self addCreditCard];
    
    CGFloat bottomViewHeight = 44.0;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:nil];
    [self.tableView setRowHeight:70.0];
    [self.view addSubview:self.tableView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:bottomView];
    
    UIButton *addNewCard = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    [addNewCard setFrame:CGRectMake(0, 0, 300.0, 30.0)];
    addNewCard.center = CGPointMake(bottomView.frame.size.width/2, bottomView.frame.size.height/2);
    [addNewCard setTitle:@"Current Order" forState:UIControlStateNormal];
    [addNewCard addTarget:self action:@selector(addCreditCard) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addNewCard];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.creditCards count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
	}
    
    NSDictionary *card = [self.creditCards objectAtIndex:[indexPath row]];
    cell.textLabel.text = [card objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Card ending in: %i", [[card objectForKey:@"number"] intValue]];
    
    return cell;
}

#pragma  mark - Credit Card Methods
-(void)addCreditCard {
    
    NSDictionary *newCard = [NSDictionary dictionaryWithObjects:@[@"Visa", @"1111"] forKeys:@[@"name", @"number"]];
    [self.creditCards addObject:newCard];
    
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
//    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
//    scanViewController.appToken = @"ae8c82d62dc5477e9623e85e82715a1a"; // get your app token from the card.io website
//    [self presentViewController:scanViewController animated:YES completion:^{}];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    // Use the card info...
    [scanViewController dismissViewControllerAnimated:YES completion:^{}];
}

@end
