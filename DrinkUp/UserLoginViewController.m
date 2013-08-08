//
//  UserLoginViewController.m
//  DrinkUp
//
//  Created by Kinetic on 2/26/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "UserLoginViewController.h"
#import "SharedDataHandler.h"
#import "FBConnect.h"
#import "SignupViewController.h"
#import "QBFlatButton.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "CreditCardProfileViewController.h"
#import "UserPictureViewController.h"
#import "DrinkUpLoginViewController.h"
#import "UIImageView+AFNetworking.h"
#import "OrderHistorySelectionViewController.h"

#import "UIColor+FlatUI.h"
#import "FUIButton.h"
#import "FUIAlertView.h"
#import "UIFont+FlatUI.h"
#import "KUIHelper.h"

@interface UserLoginViewController ()
@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) FBProfilePictureView *fbProfilePicView;
@property (nonatomic, strong) UITextField *loginUsernameOrEmailField;
@property (nonatomic, strong) UITextField *loginPasswordField;
@property bool isShowingProfileView;
@property bool isUpdatingProfilePicture;
@end

@implementation UserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.title = @"Settings";
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[SharedDataHandler sharedInstance] initializeFacebook];
//    Facebook *facebook = [[SharedDataHandler sharedInstance] facebookInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookAuthorized:)
                                                 name:@"FacebookServerLoginAuthorized"
                                               object:nil];

    NSLog(@"view did load");
    if ([SharedDataHandler sharedInstance].isUserAuthenticated) {
        [self setupUserProfileView];
    } else {
        [self setupUserLoginViewSimple];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([SharedDataHandler sharedInstance].isUserAuthenticated && !self.isShowingProfileView)
    {
        [self transitionView:1];
    }
    
    if (self.isUpdatingProfilePicture)
    {
        self.isUpdatingProfilePicture = NO;
        [self.profilePicView setImage:[[SharedDataHandler sharedInstance] getUserProfileImage]];
    }
    
    NSLog(@"Current user info for login and profile: %@", [SharedDataHandler sharedInstance].userInformation);
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[KUIHelper createAlertViewWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] show];
    }
}

-(void)loginWithFacebook:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookAuthorized:)
                                                 name:@"FacebookServerLoginAuthorized"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookAuthorizationFailure:)
                                                 name:@"FacebookServerLoginFailure"
                                               object:nil];
    
    [[SharedDataHandler sharedInstance] authorizeFacebook];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
//    // get the app delegate so that we can access the session property
//    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
//    
//    // this button's job is to flip-flop the session from open to closed
//    if (appDelegate.session.isOpen) {
//        // if a user logs out explicitly, we delete any cached token information, and next
//        // time they run the applicaiton they will be presented with log in UX again; most
//        // users will simply close the app or switch away, without logging out; this will
//        // cause the implicit cached-token login to occur on next launch of the application
//        [appDelegate.session closeAndClearTokenInformation];
//        
//    } else {
//        if (appDelegate.session.state != FBSessionStateCreated) {
//            // Create a new, logged out session.
//            appDelegate.session = [[FBSession alloc] init];
//        }
//        
//        // if the session isn't open, let's open it now and present the login UX to the user
//        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                         FBSessionState status,
//                                                         NSError *error) {
//            // and here we make sure to update our UX according to the new session state
//            [self transitionView:1];
//        }];
//    }
}

-(void)facebookAuthorized:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self transitionView:1];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)facebookAuthorizationFailure:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)logoutFacebook:(id)sender {
    
    [[SharedDataHandler sharedInstance].facebookInstance logout];
    
//    UIButton *fb_button = (UIButton *)sender;
//    [fb_button setTitle:@"Login with Facebook" forState:UIControlStateNormal];
//    [fb_button addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
}

//-(void)loginToServer:(id)sender
//{
//    if ([self.loginUsernameOrEmailField.text length] > 0 && [self.loginPasswordField.text length] > 0)
//    {
//        NSMutableDictionary *creds = [[NSMutableDictionary alloc] init];
//        [creds setObject:self.loginUsernameOrEmailField.text forKey:@"username"];
//        [creds setObject:self.loginPasswordField.text forKey:@"password"];
//        
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            
//            [[SharedDataHandler sharedInstance] userLoginToServerWithCredentials:creds andCompletion:^(bool successful)
//            {
//                if (successful)
//                {
//                    [self transitionView:1];
//                } else {
//                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Login Failed"
//                                                                      message:@"Please check your username and password and try again."
//                                                                     delegate:self
//                                                            cancelButtonTitle:@"Okay"
//                                                            otherButtonTitles:nil];
//                    [message show];
//                }
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [MBProgressHUD hideHUDForView:self.view animated:YES];
//                 });
//             }];
//        });
//    } else {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Missing Fields"
//                                                          message:@"Please make sure you have entered a username and password."
//                                                         delegate:self
//                                                cancelButtonTitle:@"Okay"
//                                                otherButtonTitles:nil];
//        [message show];
//    }
//}

-(void)logoutFromServer
{    
    NSLog(@"Logout attempt");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging Out";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[SharedDataHandler sharedInstance] userLogoutOfServer:^(bool successful)
        {
            if ([[[SharedDataHandler sharedInstance] facebookInstance] isSessionValid] )
            {
                [[SharedDataHandler sharedInstance].facebookInstance logout];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self transitionView:0];
        }];
    });
}

-(void)showSignupView {
    SignupViewController *suvc = [[SignupViewController alloc] init];
    [self.navigationController pushViewController:suvc animated:YES];
//    [self.navigationController presentViewController:suvc animated:YES completion:^{
//    }];
}

//-(void)postToFacebookWall:(id)sender {
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I'm not convinced I'm not an actual wolf when I'm wearing my hat.", @"message", nil];
//    [[[SharedDataHandler sharedInstance] facebookInstance] dialog:@"feed" andParams:params andDelegate:[SharedDataHandler sharedInstance]];
//    [[[SharedDataHandler sharedInstance] facebookInstance] requestWithMethodName:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:[SharedDataHandler sharedInstance]];
//}

//- (void)logoutButtonClicked:(id)sender {
    // Method that gets called when the logout button is pressed
//    [[[SharedDataHandler sharedInstance] facebookInstance] logout];
//}

-(void)transitionView:(int)viewChoice
{
    [UIView animateWithDuration:0.2 animations:^
    {
        self.view.alpha = 0.0;
    } completion:^(BOOL finished)
    {
        [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if (viewChoice == 0) {
            [self setupUserLoginViewSimple];
        } else {
            [self setupUserProfileView];
        }
        
        [UIView animateWithDuration:0.1 animations:^
         {
             self.view.alpha = 1.0;
         }];
    }];
}

#pragma mark - User Profile View
-(void)setupUserProfileView
{
    self.isShowingProfileView = YES;
    
    UIBarButtonItem *leaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Let's Drink!"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(transitionLeaving)];
    
    self.navigationItem.leftBarButtonItem = leaveButton;
    
    CGFloat y = 10.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 320 - 100 - 10 - 10;
    CGFloat fieldHeight = 40.0;
    CGFloat buttonWidth = 320 - 10 - 10;
    
    /* this actually goes behind the rest of the content */
    UIView *bgDarkView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height/2)];
//    [bgDarkView setBackgroundColor:[UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.8]];
    [bgDarkView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bgDarkView];
    
    self.profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(round(edgeInset), round(y), 100, 100)];
//    self.profilePicView.contentMode = UIViewContentModeScaleAspectFit;
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profilePicView setBackgroundColor:[UIColor clearColor]];
//    [self.profilePicView.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
    [self.profilePicView.layer setBorderColor:[[UIColor midnightBlueColor] CGColor]];
    [self.profilePicView.layer setBorderWidth:5.0];
    [self.profilePicView.layer setCornerRadius:8.0];
    [self.profilePicView.layer setMasksToBounds:YES];
    [self.profilePicView setImage:[[SharedDataHandler sharedInstance] getUserProfileImage]];
    [self.view addSubview:self.profilePicView];
    
    if ([[SharedDataHandler sharedInstance].facebookInstance isSessionValid]) {
        self.fbProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:[[SharedDataHandler sharedInstance].userInformation objectForKey:@"fb_id"] pictureCropping:FBProfilePictureCroppingSquare];
        [self.fbProfilePicView setFrame:self.profilePicView.frame];
//        [self.fbProfilePicView.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
        [self.fbProfilePicView.layer setBorderColor:[[UIColor midnightBlueColor] CGColor]];
        [self.fbProfilePicView.layer setBorderWidth:5.0];
        [self.fbProfilePicView.layer setCornerRadius:8.0];
        [self.view addSubview:self.fbProfilePicView];
        [self.profilePicView setHidden:YES];
    }
    
//    y += profilePicView.frame.size.height + spacer;
    
    UILabel *profileName = [[UILabel alloc] initWithFrame:CGRectMake(round(self.profilePicView.frame.size.width + edgeInset + edgeInset),  round(self.profilePicView.frame.origin.y), fieldWidth, fieldHeight * 3)];
    [profileName setBackgroundColor:[UIColor clearColor]];
    [profileName setTextAlignment:NSTextAlignmentLeft];
    NSString *profileNameText = [NSString stringWithFormat:@"%@", [[SharedDataHandler sharedInstance].userInformation objectForKey:@"username" ]];
    NSLog(@"user setupUserProfileView: %@", [SharedDataHandler sharedInstance].userInformation);
    [profileName setText:profileNameText];
    [profileName setTextColor:[UIColor midnightBlueColor]];
    [profileName setFont:[UIFont boldSystemFontOfSize:24.0]];
    [profileName setNumberOfLines:2];
    [profileName setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:profileName];
    
    if ([[SharedDataHandler sharedInstance].facebookInstance isSessionValid]) {
        NSString *usernameLabelText = [NSString stringWithFormat:@"%@", [[SharedDataHandler sharedInstance].userInformation objectForKey:@"fb_firstname"]];
        [profileName setText:usernameLabelText];
    }
    
    [profileName sizeToFit];
    [profileName setCenter:CGPointMake(profileName.center.x, self.profilePicView.center.y)];
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(round(profileName.frame.origin.x), round(CGRectGetMaxY(profileName.frame) + 5.0), fieldWidth, fieldHeight)];
    [emailLabel setText:[[SharedDataHandler sharedInstance].userInformation objectForKey:@"email"]];
    [emailLabel setBackgroundColor:[UIColor clearColor]];
    [emailLabel setTextAlignment:NSTextAlignmentLeft];
    [emailLabel setTextColor:[UIColor darkGrayColor]];
    [emailLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [emailLabel setNumberOfLines:2];
    [emailLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [emailLabel sizeToFit];
    [self.view addSubview:emailLabel];
    
    y = CGRectGetMaxY(self.profilePicView.frame) + spacer * 2;
    
    FUIButton *orderHistoryButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)
                                                                 andTitle:@"View Order History"];
    [orderHistoryButton addTarget:self action:@selector(transitionOrderHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:orderHistoryButton];
    y += orderHistoryButton.frame.size.height + spacer;
    
    FUIButton *changeProfileImageButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)
                                                                       andTitle:@"Change Profile Image"];
    [changeProfileImageButton addTarget:self action:@selector(transitionProfilePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeProfileImageButton];
    y += changeProfileImageButton.frame.size.height + spacer;
    
    FUIButton *changePaymentButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)
                                                                       andTitle:@"Change Credit Card"];
    [changePaymentButton addTarget:self action:@selector(transitionChangeCreditCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changePaymentButton];
    y += changePaymentButton.frame.size.height + spacer;
    
    FUIButton *logoutButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)
                                                            andTitle:@"Logout"];
    [logoutButton addTarget:self action:@selector(confirmLogout) forControlEvents:UIControlEventTouchUpInside];
    logoutButton.buttonColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
    [self.view addSubview:logoutButton];
    y += logoutButton.frame.size.height + spacer;
}

-(void)setupUserLoginViewSimple
{
    self.isShowingProfileView = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(showLeavingOptions)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    CGFloat y = 5.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 40.0;
    
    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkUpLabel setTextColor:[UIColor blackColor]];
    [drinkUpLabel setText:@"DrinkUp Account"];
    [self.view addSubview:drinkUpLabel];
    
    y += drinkUpLabel.frame.size.height + spacer;

    FUIButton *loginButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)
                                                        andTitle:@"Log In with DrinkUp"];
    [loginButton addTarget:self action:@selector(transitionLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    y += loginButton.frame.size.height + spacer;
    
    FUIButton *facebookButton = [KUIHelper createBannerButtonWithRect:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)
                                                           andTitle:@"Log In with Facebook"];
    [facebookButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    facebookButton.buttonColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(200/255.0) alpha:1.0];
    facebookButton.shadowColor = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(170/255.0) alpha:0.7];
    [self.view addSubview:facebookButton];
    
    y += facebookButton.frame.size.height + spacer;
    
    UIView *firstTimeContainer = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - fieldHeight * 3, fieldWidth, fieldHeight * 3)];
    [firstTimeContainer setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:firstTimeContainer];
    
    UILabel *firstTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight)];
    [firstTimeLabel setText:@"First time here?"];
    [firstTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [firstTimeLabel setBackgroundColor:[UIColor clearColor]];
    [firstTimeLabel setTextColor:[UIColor blackColor]];
    [firstTimeContainer addSubview:firstTimeLabel];
    
    FUIButton *signupButton = [KUIHelper createBannerButtonWithRect:CGRectMake(0, CGRectGetMaxY(firstTimeLabel.frame) + 5.0, fieldWidth, fieldHeight) andTitle:@"Sign Up"];
    [signupButton addTarget:self action:@selector(showSignupView) forControlEvents:UIControlEventTouchUpInside];
    [firstTimeContainer addSubview:signupButton];
}

-(void)showLeavingOptions
{
    [[KUIHelper createAlertViewWithTitle:@"Not Logged In"
                                 message:@"If you leave without logging in, you cannot order drinks. Are you sure?"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                       otherButtonTitles:@"Leave", nil] show];
}

#pragma mark - UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) hideKeyboard
{
    [self.loginUsernameOrEmailField resignFirstResponder];
    [self.loginPasswordField resignFirstResponder];
}

#pragma mark - Transitions
-(void)transitionChangeCreditCard
{
    CreditCardProfileViewController *cardVC = [[CreditCardProfileViewController alloc] init];
    [self.navigationController pushViewController:cardVC animated:YES];
}

-(void)transitionProfilePicture
{
    UserPictureViewController *picVC = [[UserPictureViewController alloc] init];
    [self.navigationController pushViewController:picVC animated:YES];
    self.isUpdatingProfilePicture = YES;
}

-(void)transitionLoginView
{
    DrinkUpLoginViewController *drinkUpLoginVC = [[DrinkUpLoginViewController alloc] init];
//    [self.navigationController presentViewController:drinkUpLoginVC animated:YES completion:^{}];
    [self.navigationController pushViewController:drinkUpLoginVC animated:YES];
}

-(void)transitionOrderHistory
{
    OrderHistorySelectionViewController *drinkUpHistoryVC = [[OrderHistorySelectionViewController alloc] init];
    [self.navigationController pushViewController:drinkUpHistoryVC animated:YES];
}

-(void)transitionLeaving
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmLogout
{
    [[KUIHelper createAlertViewWithTitle:@"Account Logout"
                                 message:@"Are you sure you want to logout?"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                       otherButtonTitles:@"Logout", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
        NSLog(@"logout cancelled");
    }
    else if([title isEqualToString:@"Logout"])
    {
        NSLog(@"user logout");
        [self logoutFromServer];
    }
    else if ([title isEqualToString:@"Leave"])
    {
        [self transitionLeaving];
    }
}

@end
