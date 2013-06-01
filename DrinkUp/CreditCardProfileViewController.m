//
//  CreditCardProfileViewController.m
//  DrinkUp
//
//  Created by Kinetic on 5/7/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BalancedHelper.h"
#import "BPHCard.h"
#import "SharedDataHandler.h"
#import "CreditCardProfileViewController.h"
#import "QBFlatButton.h"

@interface CreditCardProfileViewController ()
@property (nonatomic, strong) UIView *upperView;
@property (nonatomic) CAGradientLayer *maskLayer;
@property (nonatomic) CGFloat upperViewHeight;
@property (nonatomic, strong) UILabel *digitsLabel;
@end

@implementation CreditCardProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.upperViewHeight = 150.0;
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
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(2.0, 2.0, self.upperView.frame.size.width - 4.0, 30.0)];
    title.text = @"Credit Card Last 4 Digits:";
    [self.upperView addSubview:title];
    
    self.digitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0, CGRectGetMaxY(title.frame) + 5.0, self.upperView.frame.size.width - 4.0, 30.0)];
    [self.upperView addSubview:self.digitsLabel];
    
    QBFlatButton *changeCardButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    changeCardButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
    changeCardButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
    changeCardButton.radius = 6.0;
    changeCardButton.margin = 4.0;
    changeCardButton.depth = 3.0;
    changeCardButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [changeCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeCardButton setTitle:@"Change Card" forState:UIControlStateNormal];
    [changeCardButton setFrame:CGRectMake(10.0, CGRectGetMaxY(self.upperView.frame) + 15.0, self.view.frame.size.width - 20.0, 45.0)];
    [changeCardButton addTarget:self action:@selector(cardImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeCardButton];
    
    QBFlatButton *removeCardButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    removeCardButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
    removeCardButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
    removeCardButton.radius = 6.0;
    removeCardButton.margin = 4.0;
    removeCardButton.depth = 3.0;
    removeCardButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [removeCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [removeCardButton setTitle:@"Remove Card" forState:UIControlStateNormal];
    [removeCardButton setFrame:CGRectMake(10.0, CGRectGetMaxY(changeCardButton.frame) + 5.0, self.view.frame.size.width - 20.0, 45.0)];
    [removeCardButton addTarget:self action:@selector(removeCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeCardButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.digitsLabel.text = [[SharedDataHandler sharedInstance].userCard objectForKey:@"last_four"];
}

-(void)cardImage
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = @"ae8c82d62dc5477e9623e85e82715a1a"; // get your app token from the card.io website
    [self presentViewController:scanViewController animated:YES completion:^{}];
}

-(void)changeCard:(CardIOCreditCardInfo *)info
{
    NSError *error;
    BalancedHelper *balanced = [[BalancedHelper alloc] initWithMarketplaceURI:[SharedDataHandler sharedInstance].marketplace];
    BPHCard *card = [[BPHCard alloc] initWithNumber:info.cardNumber andExperationMonth:[NSString stringWithFormat:@"%i", info.expiryMonth] andExperationYear:[NSString stringWithFormat:@"%i", info.expiryYear] andSecurityCode:info.cvv];
    NSLog(@"c info: %@, %@, %@, %@", info.cardNumber, [NSString stringWithFormat:@"%i", info.expiryMonth], [NSString stringWithFormat:@"%i", info.expiryYear], info.cvv);
//    BPHCard *card = [[BPHCard alloc] initWithNumber:@"341111111111111" andExperationMonth:@"11" andExperationYear:@"2015" andSecurityCode:@"1234"];
    NSLog(@"card: %@", card);
    NSLog(@"%@ and %@", [NSString stringWithFormat:@"%i", info.expiryMonth],  [NSString stringWithFormat:@"%i", info.expiryYear]);
    NSDictionary *response = [balanced tokenizeCard:card error:&error];
    
    if (!error) {
        NSLog(@"%@", response);
        NSLog(@"Current User Info: %@", [[SharedDataHandler sharedInstance] userInformation]);
        if ([[response objectForKey:@"status_code"] intValue] == 409)
        {
            NSLog(@"409 error");
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Credit Card Not Validated"
                                                              message:@"It appears there was an issue validating your card. Please check that the card number, security code, and expiration date are correct."
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
            [message show];
        }
        else
        {
            [[SharedDataHandler sharedInstance] userUpdateCardInfo:[NSMutableDictionary dictionaryWithDictionary:response]];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Credit Card Updated"
                                                              message:@"Your credit card has been successfully updated."
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
            [message show];
        }
    }
    else {
        NSLog(@"%@", [error description]);
    }
}

-(void)removeCard
{
    NSLog(@"remove card does not work yet");
    [[SharedDataHandler sharedInstance] userInvalidateCurrentCard:^(bool successful) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Credit Card Removed"
                                                          message:@"Your credit card has been successfully removed. Please keep in mind that you cannot place orders until you associate a credit card with your account."
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
    }];
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
    [scanViewController dismissViewControllerAnimated:YES completion:^
    {
        [self changeCard:info];
    }];
}

@end
