//
//  CardIOPaymentViewController.h
//  Copyright (c) 2011-2013 PayPal. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "CardIOPaymentViewControllerDelegate.h"

// CardIOPaymentViewController is the main entry point into the card.io SDK.
@interface CardIOPaymentViewController : UINavigationController

// Initializer for scanning only.
- (id)initWithPaymentDelegate:(id<CardIOPaymentViewControllerDelegate>)aDelegate;

// Initializer for scanning only, with extra hooks for controlling whether the camera will be displayed (useful for testing).
// If scanningEnabled is NO, card.io will use manual entry, regardless of whether scanning is supported. (Default value is YES.)
- (id)initWithPaymentDelegate:(id<CardIOPaymentViewControllerDelegate>)aDelegate scanningEnabled:(BOOL)scanningEnabled;

// Set your app token. If not set before presenting the view controller, an exception will be thrown.
@property(nonatomic, copy, readwrite) NSString *appToken;

// If YES, the status bar's style will be kept as whatever your app has set it to.
// If NO, the status bar style will be set to UIStatusBarStyleBlackOpaque.
// Defaults to NO.
@property(nonatomic, assign, readwrite) BOOL keepStatusBarStyle;

// The default appearance of the navigation bar is UIBarStyleDefault, tintColor == nil.
// Set either or both of these properties if you want to override these defaults.
@property(nonatomic, assign, readwrite) UIBarStyle navigationBarStyle;
@property(nonatomic, retain, readwrite) UIColor *navigationBarTintColor;

// Set to NO if you don't need to collect the card expiration. Defaults to YES.
@property(nonatomic, assign, readwrite) BOOL collectExpiry;

// Set to NO if you don't need to collect the CVV from the user. Defaults to YES.
@property(nonatomic, assign, readwrite) BOOL collectCVV;

// Set to YES if you need to collect the billing zip code. Defaults to NO.
@property(nonatomic, assign, readwrite) BOOL collectZip;

// Set to NO if you want to suppress the first-time how-to alert view. Defaults to YES.
@property(nonatomic, assign, readwrite) BOOL showsFirstUseAlert;

// Set to YES to show the card.io logo over the camera instead of the PayPal logo. Defaults to NO.
@property(nonatomic, assign, readwrite) BOOL useCardIOLogo;

// Set to YES to prevent card.io from showing manual entry buttons internally. Defaults to NO.
// If you want to prevent users from *ever* seeing card.io's manual entry screen, you should also:
//   * Check +canReadCardWithCamera before initing the view controller. If +canReadCardWithCamera
//     returns false, card.io will display a manual entry screen if presented.
//   * If needed for UI updates such as disabling/removing card scan buttons, subscribe to scan
//     notifications; see +(start|stop)GeneratingScanAvailabilityNotifications.
@property(nonatomic, assign, readwrite) BOOL disableManualEntryButtons;

// Access to the delegate.
@property(nonatomic, weak, readwrite) id<CardIOPaymentViewControllerDelegate> paymentDelegate;

// Indicates whether this device supports camera-based card scanning, including
// factors like hardware support and OS version. card.io automatically provides
// manual entry of cards as a fallback, so it is not necessary to check this.
+ (BOOL)canReadCardWithCamera;

// Please send the output of this method with any technical support requests.
+ (NSString *)libraryVersion;

@end