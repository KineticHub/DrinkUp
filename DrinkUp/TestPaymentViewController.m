////
////  TestPaymentViewController.m
////  DrinkUp
////
////  Created by Kinetic on 3/9/13.
////  Copyright (c) 2013 Kinetic. All rights reserved.
////
//
///*
// API Login ID 8VE9t69ax5m
// Transaction Key 2fQY43tp65Kbr99Y
// */
//
//#import "TestPaymentViewController.h"
//#import "MobileDeviceLoginRequest.h"
//
//@interface TestPaymentViewController ()
//@property (nonatomic) NSString *sessionToken;
//@end
//
//@implementation TestPaymentViewController
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	
//    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [registerButton addTarget:self action:@selector(registerDevice) forControlEvents:UIControlEventTouchUpInside];
//    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
//    [registerButton setFrame:CGRectMake(0.0,0.0,320.0,45.0)];
//    [self.view addSubview:registerButton];
//    
//    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [loginButton addTarget:self action:@selector(loginToGateway) forControlEvents:UIControlEventTouchUpInside];
//    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
//    [loginButton setFrame:CGRectMake(0.0,55.0,320.0,45.0)];
//    [self.view addSubview:loginButton];
//    
//    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [payButton addTarget:self action:@selector(createTransaction) forControlEvents:UIControlEventTouchUpInside];
//    [payButton setTitle:@"Pay" forState:UIControlStateNormal];
//    [payButton setFrame:CGRectMake(0.0,110.0,320.0,45.0)];
//    [self.view addSubview:payButton];
//}
//
//-(void)registerDevice
//{
//    MobileDeviceRegistrationRequest *registrationRequest=[MobileDeviceRegistrationRequest mobileDeviceRegistrationRequest];
//    
//    registrationRequest.anetApiRequest.merchantAuthentication.name = @"DrinkUp314";
//    
//    registrationRequest.anetApiRequest.merchantAuthentication.password = @"Password!";
//    
//    registrationRequest.mobileDevice.mobileDescription=@"asd";
//    registrationRequest.mobileDevice.mobileDeviceId=[[[UIDevice currentDevice] uniqueIdentifier]
//                                                     stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
//    [AuthNet authNetWithEnvironment:ENV_TEST];
//    AuthNet *an = [AuthNet getInstance];
//    
//    [an setDelegate:self];
//    
//    [an mobileDeviceRegistrationRequest:registrationRequest];
//    
//}
//
//- (void) loginToGateway {
//    
//    NSLog(@"Loggin into gateway");
//    
//    MobileDeviceLoginRequest *mobileDeviceLoginRequest =
//    [MobileDeviceLoginRequest mobileDeviceLoginRequest];
//    mobileDeviceLoginRequest.anetApiRequest.merchantAuthentication.name = @"DrinkUp314";
//    mobileDeviceLoginRequest.anetApiRequest.merchantAuthentication.password = @"Password!";
////    mobileDeviceLoginRequest.anetApiRequest.merchantAuthentication.transactionKey = @"2fQY43tp65Kbr99Y";
//    mobileDeviceLoginRequest.anetApiRequest.merchantAuthentication.sessionToken = self.sessionToken;
//    
//    mobileDeviceLoginRequest.anetApiRequest.merchantAuthentication.mobileDeviceId = [[[UIDevice currentDevice] uniqueIdentifier]
//     stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
//    
//    [AuthNet authNetWithEnvironment:ENV_TEST];
//    
//    AuthNet *an = [AuthNet getInstance];
//    [an setDelegate:self];
//    [an mobileDeviceLoginRequest: mobileDeviceLoginRequest];
//}
//
//- (void) createTransaction {
//    
//    NSLog(@"Creating transaction");
//    
//    AuthNet *an = [AuthNet getInstance];
//    
//    [an setDelegate:self];
//    
//    CreditCardType *creditCardType = [CreditCardType creditCardType];
//    creditCardType.cardNumber = @"4111111111111111";
//    creditCardType.cardCode = @"100";
//    creditCardType.expirationDate = @"1214";
//    
//    PaymentType *paymentType = [PaymentType paymentType];
//    paymentType.creditCard = creditCardType;
//    
//    ExtendedAmountType *extendedAmountTypeTax = [ExtendedAmountType extendedAmountType];
//    extendedAmountTypeTax.amount = @"0";
//    extendedAmountTypeTax.name = @"Tax";
//    
//    ExtendedAmountType *extendedAmountTypeShipping = [ExtendedAmountType extendedAmountType];
//    extendedAmountTypeShipping.amount = @"0";
//    extendedAmountTypeShipping.name = @"Shipping";
//    
//    LineItemType *lineItem = [LineItemType lineItem];
//    lineItem.itemName = @"Soda";
//    lineItem.itemDescription = @"Soda";
//    lineItem.itemQuantity = @"1";
//    lineItem.itemPrice = @"1.00";
//    lineItem.itemID = @"1";
//    
//    TransactionRequestType *requestType = [TransactionRequestType transactionRequest];
//    requestType.lineItems = [NSArray arrayWithObject:lineItem];
//    requestType.amount = @"1.00";
//    requestType.payment = paymentType;
//    requestType.tax = extendedAmountTypeTax;
//    requestType.shipping = extendedAmountTypeShipping;
//    
//    CreateTransactionRequest *request = [CreateTransactionRequest createTransactionRequest];
//    request.transactionRequest = requestType;
//    request.transactionType = AUTH_ONLY;
//    request.anetApiRequest.merchantAuthentication.mobileDeviceId =
//    [[[UIDevice currentDevice] uniqueIdentifier]
//     stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
//    request.anetApiRequest.merchantAuthentication.sessionToken = self.sessionToken;
//    [an purchaseWithRequest:request];
//}
//
//- (void) requestFailed:(AuthNetResponse *)response {
//    // Handle a failed request
//}
//
//- (void) connectionFailed:(AuthNetResponse *)response {
//    // Handle a failed connection
//}
//
//- (void) paymentSucceeded:(CreateTransactionResponse *) response {
//    // Handle payment success
//}
//
//- (void) mobileDeviceLoginSucceeded:(MobileDeviceLoginResponse *)response {
//
//    self.sessionToken = response.sessionToken;
////    [self createTransaction];
//};
//@end
