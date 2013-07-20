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
#import "MBProgressHUD.h"
#import "UIColor+FlatUI.h"
#import "KUIHelper.h"
#import "FUIAlertView.h"
#import "UserPictureViewController.h"
#import "UINavigationBar+FlatUI.h"

@interface CreditCardProfileViewController ()
@property (nonatomic, strong) UILabel *cardTypeDataLabel;
@property (nonatomic, strong) UILabel *cardDigitsDataLabel;
@property (nonatomic, strong) UILabel *cardExpirationDataLabel;
@property (nonatomic, strong) FUIButton *changeCardButton;
@property (nonatomic, strong) FUIButton *removeCardButton;
@end

@implementation CreditCardProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Payment Info";
    
    UIView *background = [[UIView alloc] init];
//    [background setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_thread"]]];
    [background setBackgroundColor:[UIColor cloudsColor]];
    background.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    CGFloat y = 15.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 40.0;
    
    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkUpLabel setTextColor:[UIColor midnightBlueColor]];
    [drinkUpLabel setText:@"Payment Info"];
//    [self.view addSubview:drinkUpLabel];
    
//    y += drinkUpLabel.frame.size.height + spacer;
    
    UILabel *cardTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [cardTypeLabel setBackgroundColor:[UIColor clearColor]];
    [cardTypeLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [cardTypeLabel setTextAlignment:NSTextAlignmentLeft];
    [cardTypeLabel setTextColor:[UIColor grayColor]];
    [cardTypeLabel setText:@"Card Type:"];
    [self.view addSubview:cardTypeLabel];
    
    y += cardTypeLabel.frame.size.height;
    
    NSString *cardTypeData = [NSString stringWithFormat:@"  %@",[[[SharedDataHandler sharedInstance].userCard objectForKey:@"card_type"] uppercaseString]];
    self.cardTypeDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight - 10.0)];
    [self.cardTypeDataLabel setBackgroundColor:[UIColor colorWithRed:15.0/255.0 green:15.0/255.0 blue:15.0/255.0 alpha:0.5]];
    [self.cardTypeDataLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.cardTypeDataLabel setTextAlignment:NSTextAlignmentLeft];
    [self.cardTypeDataLabel setTextColor:[UIColor whiteColor]];
    [self.cardTypeDataLabel setText:cardTypeData];
    [self.view addSubview:self.cardTypeDataLabel];
    
    y += self.cardTypeDataLabel.frame.size.height;
    
    UILabel *cardDigitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [cardDigitsLabel setBackgroundColor:[UIColor clearColor]];
    [cardDigitsLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [cardDigitsLabel setTextAlignment:NSTextAlignmentLeft];
    [cardDigitsLabel setTextColor:[UIColor grayColor]];
    [cardDigitsLabel setText:@"Card Ending In:"];
    [self.view addSubview:cardDigitsLabel];
    
    y += cardDigitsLabel.frame.size.height;
    
    NSString *cardDigitsData = [NSString stringWithFormat:@"  %@", [[SharedDataHandler sharedInstance].userCard objectForKey:@"last_four"]];
    self.cardDigitsDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight - 10.0)];
    [self.cardDigitsDataLabel setBackgroundColor:[UIColor colorWithRed:15.0/255.0 green:15.0/255.0 blue:15.0/255.0 alpha:0.5]];
    [self.cardDigitsDataLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.cardDigitsDataLabel setTextAlignment:NSTextAlignmentLeft];
    [self.cardDigitsDataLabel setTextColor:[UIColor whiteColor]];
    [self.cardDigitsDataLabel setText:cardDigitsData];
    [self.view addSubview:self.cardDigitsDataLabel];
    
    y += self.cardDigitsDataLabel.frame.size.height;
    
    UILabel *cardExpirationLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [cardExpirationLabel setBackgroundColor:[UIColor clearColor]];
    [cardExpirationLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [cardExpirationLabel setTextAlignment:NSTextAlignmentLeft];
    [cardExpirationLabel setTextColor:[UIColor grayColor]];
    [cardExpirationLabel setText:@"Card Expiration:"];
    [self.view addSubview:cardExpirationLabel];
    
    y += cardExpirationLabel.frame.size.height;
    
    NSString *cardExpirationData = [NSString stringWithFormat:@"  %@/%@", [[SharedDataHandler sharedInstance].userCard objectForKey:@"expiration_month"], [[SharedDataHandler sharedInstance].userCard objectForKey:@"expiration_year"]];
    self.cardExpirationDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight - 10.0)];
    [self.cardExpirationDataLabel setBackgroundColor:[UIColor colorWithRed:15.0/255.0 green:15.0/255.0 blue:15.0/255.0 alpha:0.5]];
    [self.cardExpirationDataLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.cardExpirationDataLabel setTextAlignment:NSTextAlignmentLeft];
    [self.cardExpirationDataLabel setTextColor:[UIColor whiteColor]];
    [self.cardExpirationDataLabel setText:cardExpirationData];
    [self.view addSubview:self.cardExpirationDataLabel];
    
    y += self.cardDigitsDataLabel.frame.size.height + spacer * 2;
    
//    QBFlatButton *changeCardButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    changeCardButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
//    changeCardButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
//    changeCardButton.radius = 6.0;
//    changeCardButton.margin = 4.0;
//    changeCardButton.depth = 3.0;
//    changeCardButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [changeCardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [changeCardButton setTitle: forState:UIControlStateNormal];
//    [changeCardButton setFrame:];
    
    self.changeCardButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, fieldWidth, 45.0)
                                                               andTitle:@"Change Card"];
    [self.changeCardButton addTarget:self action:@selector(cardImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeCardButton];
    
    y += self.changeCardButton.frame.size.height + spacer;
    
//    QBFlatButton *removeCardButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    removeCardButton.faceColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
//    removeCardButton.sideColor = [UIColor colorWithRed:(170/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
//    removeCardButton.radius = 6.0;
//    removeCardButton.margin = 4.0;
//    removeCardButton.depth = 3.0;
//    removeCardButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [removeCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [removeCardButton setTitle:@"Remove Card" forState:UIControlStateNormal];
//    [removeCardButton setFrame:CGRectMake(edgeInset, y, fieldWidth, 45.0)];
    
    self.removeCardButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, fieldWidth, 45.0)
                                                               andTitle:@"Remove Card"];
    [self.removeCardButton addTarget:self action:@selector(confirmRemoveCard) forControlEvents:UIControlEventTouchUpInside];
    self.removeCardButton.buttonColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
    [self.view addSubview:self.removeCardButton];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isCreatingAccount"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasShownCreditCardScreen"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldShowCard.io"];
        FUIAlertView *postSignUpAlert = [KUIHelper createAlertViewWithTitle:@"Add a Card"
                                                                    message:@"Now that you have an account, let's add a credit card so that you can pay for your drinks."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Add Card"
                                                          otherButtonTitles:nil];
        [postSignUpAlert show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasShownCreditCardScreen"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldShowCard.io"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldShowCard.io"];
        [self cardImage];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refreshCardInfo];
}

-(void)refreshCardInfo
{
    NSLog(@"card info: %@", [SharedDataHandler sharedInstance].userCard);
    
    NSString *nullPlaceholder = @"  No Card";
    
    NSString *cardTypeData = [NSString stringWithFormat:@"  %@", [[[SharedDataHandler sharedInstance].userCard objectForKey:@"card_type"] uppercaseString]];
    NSString *cardDigitsData = [NSString stringWithFormat:@"  %@", [[SharedDataHandler sharedInstance].userCard objectForKey:@"last_four"]];
    NSString *cardExpirationData = [NSString stringWithFormat:@"  %@/%@", [[SharedDataHandler sharedInstance].userCard objectForKey:@"expiration_month"], [[SharedDataHandler sharedInstance].userCard objectForKey:@"expiration_year"]];
    
    if ([SharedDataHandler sharedInstance].userCard)
    {
        self.cardTypeDataLabel.text = cardTypeData;
        self.cardDigitsDataLabel.text = cardDigitsData;
        self.cardExpirationDataLabel.text = cardExpirationData;
        
        [self.removeCardButton setHidden:NO];
        [self.changeCardButton setTitle:@"Change Card" forState:UIControlStateNormal];
    }
    else
    {
        self.cardTypeDataLabel.text = nullPlaceholder;
        self.cardDigitsDataLabel.text = nullPlaceholder;
        self.cardExpirationDataLabel.text = nullPlaceholder;
        
        [self.removeCardButton setHidden:YES];
        [self.changeCardButton setTitle:@"Add Card" forState:UIControlStateNormal];
    }
    
}

-(void)cardImage
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self scanningEnabled:NO];
    scanViewController.appToken = @"ae8c82d62dc5477e9623e85e82715a1a"; // get your app token from the card.io website
    [scanViewController setShowsFirstUseAlert:NO];
    [scanViewController setKeepStatusBarStyle:YES];
    [scanViewController setNavigationBarTintColor:[UIColor midnightBlueColor]];
    [self presentViewController:scanViewController animated:YES completion:^
    {
        [scanViewController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    }];
}

-(void)changeCard:(CardIOCreditCardInfo *)info
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating Card";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    
    NSError *error;
    BalancedHelper *balanced = [[BalancedHelper alloc] initWithMarketplaceURI:[SharedDataHandler sharedInstance].marketplace];
    BPHCard *card = [[BPHCard alloc] initWithNumber:info.cardNumber andExperationMonth:[NSString stringWithFormat:@"%i", info.expiryMonth] andExperationYear:[NSString stringWithFormat:@"%i", info.expiryYear] andSecurityCode:info.cvv];
    NSLog(@"c info: %@, %@, %@, %@", info.cardNumber, [NSString stringWithFormat:@"%i", info.expiryMonth], [NSString stringWithFormat:@"%i", info.expiryYear], info.cvv);
//    BPHCard *card = [[BPHCard alloc] initWithNumber:@"341111111111111" andExperationMonth:@"11" andExperationYear:@"2015" andSecurityCode:@"1234"];
    NSLog(@"card: %@", card);
    NSLog(@"%@ and %@", [NSString stringWithFormat:@"%i", info.expiryMonth],  [NSString stringWithFormat:@"%i", info.expiryYear]);
    NSDictionary *response = [balanced tokenizeCard:card error:&error];
    
    if (!error)
    {
        NSLog(@"%@", response);
        NSLog(@"Current User Info: %@", [[SharedDataHandler sharedInstance] userInformation]);
        if ([[response objectForKey:@"status_code"] intValue] == 409)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            NSLog(@"409 error");
            [[KUIHelper createAlertViewWithTitle:@"Credit Card Not Validated"
                                        message:@"It appears there was an issue validating your card. Please check that the card number, security code, and expiration date are correct."
                                       delegate:self
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil] show];
        }
        else
        {
                [[SharedDataHandler sharedInstance] userUpdateCardInfo:[NSMutableDictionary dictionaryWithDictionary:response] withSuccess:^(bool successful)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                    
                    if (successful)
                    {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isCreatingAccount"])
                        {
                            UserPictureViewController *userPictureVC = [[UserPictureViewController alloc] init];
                            [self.navigationController pushViewController:userPictureVC animated:YES];
                        }
                        else
                        {   
                            [[KUIHelper createAlertViewWithTitle:@"Credit Card Updated"
                                                        message:@"Your credit card has been successfully updated."
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil] show];
                        }
                        
                        [self refreshCardInfo];
                    }
                    else
                    {   
                        [[KUIHelper createAlertViewWithTitle:@"Update Error"
                                                    message:@"There was an error updating the card information. It may be the connecion or an issue on ur side. Please let us know if this continues to occur and we will help you resolve it as quickly as possible."
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil] show];
                    }
                }];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        [[KUIHelper createAlertViewWithTitle:@"Update Error"
                                     message:[error description]
                                    delegate:self
                           cancelButtonTitle:@"Okay"
                           otherButtonTitles:nil] show];
        
        NSLog(@"%@", [error description]);
    }
        });
}

-(void)removeCard
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Removing Card";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] userInvalidateCurrentCard:^(bool successful)
        {
            if (successful)
            {
                [[KUIHelper createAlertViewWithTitle:@"Credit Card Removed"
                                             message:@"Your credit card has been successfully removed. Please keep in mind that you cannot place orders until you associate a credit card with your account."
                                            delegate:self
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
                
                [self refreshCardInfo];
            }
            else
            {
                [[KUIHelper createAlertViewWithTitle:@"Error"
                                             message:@"There was an error removing your credit card. This may be a result of a poor internet connection or a mistake on our end. Please try again, or contact us and we will help you resolve this issue quickly."
                                            delegate:self
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
        
    });
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:^{}];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isCreatingAccount"])
    {
        FUIAlertView *noCardAddedAlert = [KUIHelper createAlertViewWithTitle:@"Card Not Added"
                                                                    message:@"You will not be able to complete an order until a credit card has been added. To add a card at any time, just go to your profile settings."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Okay"
                                                          otherButtonTitles:nil];
        [noCardAddedAlert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCreatingAccount"];
        
        int popNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"popToViewController"];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:popNum] animated:YES];
    }
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

-(void)confirmRemoveCard
{
    [[KUIHelper createAlertViewWithTitle:@"Remove Credit Card?"
                                 message:@"Are you sure you want to remove the credit card associated with your account? You must provide a new one before ordering."
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                       otherButtonTitles:@"Remove", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
        NSLog(@"Cancel was selected.");
    }
    else if([title isEqualToString:@"Remove"])
    {
        NSLog(@"Remove was selected.");
        [self removeCard];
    }
    else if([title isEqualToString:@"Add Card"])
    {
        [self cardImage];
    }
}

@end
