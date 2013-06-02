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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[SharedDataHandler sharedInstance] initializeFacebook];
//    Facebook *facebook = [[SharedDataHandler sharedInstance] facebookInstance];

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
        [self.profilePicView setImageWithURL:[NSURL URLWithString:[[SharedDataHandler sharedInstance].userInformation objectForKey:@"profile_image"]]];
    }
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
        [[[UIAlertView alloc] initWithTitle:alertTitle
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
    
    [[SharedDataHandler sharedInstance] authorizeFacebook];
    
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

-(void)logoutFromServer:(id)sender {
    
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
//    [self.navigationController pushViewController:suvc animated:YES];
    [self.navigationController presentViewController:suvc animated:YES completion:^{
    }];
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
    
    self.profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(edgeInset, y, 100, 100)];
//    self.profilePicView.contentMode = UIViewContentModeScaleAspectFit;
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profilePicView setBackgroundColor:[UIColor clearColor]];
    [self.profilePicView.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
    [self.profilePicView.layer setBorderWidth:5.0];
    [self.profilePicView.layer setCornerRadius:8.0];
    [self.profilePicView.layer setMasksToBounds:YES];
    [self.profilePicView setImageWithURL:[NSURL URLWithString:[[SharedDataHandler sharedInstance].userInformation objectForKey:@"profile_image"]]];
    [self.view addSubview:self.profilePicView];
    
    if ([[SharedDataHandler sharedInstance].facebookInstance isSessionValid]) {
        self.fbProfilePicView = [[FBProfilePictureView alloc] initWithProfileID:[[SharedDataHandler sharedInstance].userInformation objectForKey:@"fb_id"] pictureCropping:FBProfilePictureCroppingSquare];
        [self.fbProfilePicView setFrame:self.profilePicView.frame];
        [self.fbProfilePicView.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
        [self.fbProfilePicView.layer setBorderWidth:5.0];
        [self.fbProfilePicView.layer setCornerRadius:8.0];
        [self.view addSubview:self.fbProfilePicView];
        [self.profilePicView setHidden:YES];
    }
    
//    y += profilePicView.frame.size.height + spacer;
    
    UILabel *profileName = [[UILabel alloc] initWithFrame:CGRectMake(self.profilePicView.frame.size.width + edgeInset + edgeInset,  self.profilePicView.frame.origin.y, fieldWidth, fieldHeight * 3)];
    [profileName setBackgroundColor:[UIColor clearColor]];
    [profileName setTextAlignment:NSTextAlignmentLeft];
    NSString *profileNameText = [NSString stringWithFormat:@"%@", [[SharedDataHandler sharedInstance].userInformation objectForKey:@"username" ]];
    NSLog(@"user setupUserProfileView: %@", [SharedDataHandler sharedInstance].userInformation);
    [profileName setText:profileNameText];
    [profileName setTextColor:[UIColor whiteColor]];
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
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileName.frame.origin.x, CGRectGetMaxY(profileName.frame) + 5.0, fieldWidth, fieldHeight)];
    [emailLabel setText:[[SharedDataHandler sharedInstance].userInformation objectForKey:@"email"]];
    [emailLabel setBackgroundColor:[UIColor clearColor]];
    [emailLabel setTextAlignment:NSTextAlignmentLeft];
    [emailLabel setTextColor:[UIColor lightGrayColor]];
    [emailLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [emailLabel setNumberOfLines:2];
    [emailLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [emailLabel sizeToFit];
    [self.view addSubview:emailLabel];
    
    y = CGRectGetMaxY(self.profilePicView.frame) + spacer * 2;
    
    QBFlatButton *changeProfileImageButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    changeProfileImageButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    changeProfileImageButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    changeProfileImageButton.radius = 6.0;
    changeProfileImageButton.margin = 4.0;
    changeProfileImageButton.depth = 3.0;
    changeProfileImageButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [changeProfileImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeProfileImageButton setTitle:@"Change Profile Image" forState:UIControlStateNormal];
    [changeProfileImageButton setFrame:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)];
    [changeProfileImageButton addTarget:self action:@selector(transitionProfilePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeProfileImageButton];
    
    y += changeProfileImageButton.frame.size.height + spacer;
    
    QBFlatButton *changePaymentButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    changePaymentButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    changePaymentButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    changePaymentButton.radius = 6.0;
    changePaymentButton.margin = 4.0;
    changePaymentButton.depth = 3.0;
    changePaymentButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [changePaymentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changePaymentButton setTitle:@"Change Payment Card" forState:UIControlStateNormal];
    [changePaymentButton setFrame:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)];
    [changePaymentButton addTarget:self action:@selector(transitionChangeCreditCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changePaymentButton];
    
    y += changePaymentButton.frame.size.height + spacer;
    
    QBFlatButton *logoutButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    logoutButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
//    logoutButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
    logoutButton.faceColor = [UIColor colorWithRed:(200/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0];
    logoutButton.sideColor = [UIColor colorWithRed:(170/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
    logoutButton.radius = 6.0;
    logoutButton.margin = 4.0;
    logoutButton.depth = 3.0;
    logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setFrame:CGRectMake(edgeInset, y, buttonWidth, fieldHeight + 5.0)];
    [logoutButton addTarget:self action:@selector(logoutFromServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
    
    y += logoutButton.frame.size.height + spacer;
}

#pragma mark - User Login Options
-(void)setupUserLoginView
{
    CGFloat y = 5.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 40.0;
    
    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkUpLabel setTextColor:[UIColor whiteColor]];
    [drinkUpLabel setText:@"DrinkUp Account"];
    [self.view addSubview:drinkUpLabel];
    
    y += drinkUpLabel.frame.size.height + spacer;
    
    UIView *coloredBgView1 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [coloredBgView1 setBackgroundColor:[UIColor clearColor]];
    [coloredBgView1.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
    [coloredBgView1.layer setBorderWidth:3.0];
    [coloredBgView1.layer setCornerRadius:5.0];
    [self.view addSubview:coloredBgView1];
    
    self.loginUsernameOrEmailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.loginUsernameOrEmailField setPlaceholder:@"Email"];
    [self.loginUsernameOrEmailField setTextColor:[UIColor whiteColor]];
    [self.loginUsernameOrEmailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.loginUsernameOrEmailField setFont:[UIFont systemFontOfSize:16.0]];
    [self.loginUsernameOrEmailField setBackgroundColor:[UIColor clearColor]];
    [self.loginUsernameOrEmailField setAutocorrectionType:UITextAutocorrectionTypeNo];
//    [self.loginUsernameOrEmailField setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [self.view addSubview:self.loginUsernameOrEmailField];
    
    y += self.loginUsernameOrEmailField.frame.size.height + spacer/2;
    
    UIView *coloredBgView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [coloredBgView2 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
    [coloredBgView2.layer setBorderWidth:3.0];
    [coloredBgView2.layer setCornerRadius:5.0];
    [self.view addSubview:coloredBgView2];
    
    self.loginPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.loginPasswordField setPlaceholder:@"Password"];
    [self.loginPasswordField setSecureTextEntry:YES];
    [self.loginPasswordField setTextColor:[UIColor whiteColor]];
    [self.loginPasswordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.loginPasswordField setFont:[UIFont systemFontOfSize:16.0]];
    [self.loginPasswordField setBackgroundColor:[UIColor clearColor]];
    [self.loginPasswordField setAutocorrectionType:UITextAutocorrectionTypeNo];
//    [self.loginPasswordField setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [self.view addSubview:self.loginPasswordField];
    
    y += self.loginPasswordField.frame.size.height + spacer;
    
    QBFlatButton *loginButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
//    loginButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
//    loginButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
    loginButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    loginButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    loginButton.radius = 6.0;
    loginButton.margin = 4.0;
    loginButton.depth = 3.0;
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButton setTitle:@"Login to DrinkUp" forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    y += loginButton.frame.size.height + spacer;
    y += spacer;
    
    QBFlatButton *facebookButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    facebookButton.faceColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(200/255.0) alpha:1.0];
    facebookButton.sideColor = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(170/255.0) alpha:0.7];
    facebookButton.radius = 6.0;
    facebookButton.margin = 4.0;
    facebookButton.depth = 3.0;
    facebookButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [facebookButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [facebookButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    y += facebookButton.frame.size.height + spacer;
    
    UIView *bottomView1 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y + 35.0, fieldWidth, fieldHeight)];
//    [bottomView1 setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
//    [bottomView1 setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
    [bottomView1 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bottomView1];
    
    y += bottomView1.frame.size.height + spacer * 4;
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth/2, fieldHeight)];
    [newLabel setText:@"First time here?"];
    [newLabel setTextAlignment:NSTextAlignmentCenter];
    [newLabel setBackgroundColor:[UIColor clearColor]];
    [newLabel setTextColor:[UIColor lightGrayColor]];
    [bottomView1 addSubview:newLabel];
    
    UIButton *signupButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupButton2 setTitle:@"SignUp" forState:UIControlStateNormal];
//    [signupButton2 setTitleColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] forState:UIControlStateNormal];
    [signupButton2 setTitleColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] forState:UIControlStateNormal];
    [signupButton2 setFrame:CGRectMake(CGRectGetMaxX(newLabel.frame), 0, fieldWidth/2, fieldHeight)];
    [signupButton2 addTarget:self action:@selector(showSignupView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView1 addSubview:signupButton2];
    
    UIView *bottomView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [bottomView2 setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [bottomView2 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bottomView2];
    
    y += 5.0;
    
    UILabel *recoverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth/2, fieldHeight)];
    [recoverLabel setText:@"Forget password?"];
    [recoverLabel setTextAlignment:NSTextAlignmentCenter];
    [recoverLabel setBackgroundColor:[UIColor clearColor]];
    [recoverLabel setTextColor:[UIColor lightGrayColor]];
    [bottomView2 addSubview:recoverLabel];
    
    UIButton *forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotButton setTitle:@"Reset" forState:UIControlStateNormal];
//    [forgotButton setTitleColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] forState:UIControlStateNormal];
    [forgotButton setTitleColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] forState:UIControlStateNormal];
    [forgotButton setFrame:CGRectMake(CGRectGetMaxX(newLabel.frame), 0, fieldWidth/2, fieldHeight)];
    [bottomView2 addSubview:forgotButton];
}

-(void)setupUserLoginViewSimple
{
    self.isShowingProfileView = NO;
    
    CGFloat y = 5.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 40.0;
    
    UILabel *drinkUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [drinkUpLabel setBackgroundColor:[UIColor clearColor]];
    [drinkUpLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
    [drinkUpLabel setTextAlignment:NSTextAlignmentCenter];
    [drinkUpLabel setTextColor:[UIColor whiteColor]];
    [drinkUpLabel setText:@"DrinkUp Account"];
    [self.view addSubview:drinkUpLabel];
    
    y += drinkUpLabel.frame.size.height + spacer;
    
//    UIView *coloredBgView1 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [coloredBgView1 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView1.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView1.layer setBorderWidth:3.0];
//    [coloredBgView1.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView1];
//    
//    self.loginUsernameOrEmailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
//    [self.loginUsernameOrEmailField setPlaceholder:@"Email"];
//    [self.loginUsernameOrEmailField setTextColor:[UIColor whiteColor]];
//    [self.loginUsernameOrEmailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    [self.loginUsernameOrEmailField setFont:[UIFont systemFontOfSize:16.0]];
//    [self.loginUsernameOrEmailField setBackgroundColor:[UIColor clearColor]];
//    [self.loginUsernameOrEmailField setAutocorrectionType:UITextAutocorrectionTypeNo];
//    [self.view addSubview:self.loginUsernameOrEmailField];
//    
//    y += self.loginUsernameOrEmailField.frame.size.height + spacer/2;
//    
//    UIView *coloredBgView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [coloredBgView2 setBackgroundColor:[UIColor clearColor]];
//    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] CGColor]];
//    [coloredBgView2.layer setBorderWidth:3.0];
//    [coloredBgView2.layer setCornerRadius:5.0];
//    [self.view addSubview:coloredBgView2];
//    
//    self.loginPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
//    [self.loginPasswordField setPlaceholder:@"Password"];
//    [self.loginPasswordField setSecureTextEntry:YES];
//    [self.loginPasswordField setTextColor:[UIColor whiteColor]];
//    [self.loginPasswordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    [self.loginPasswordField setFont:[UIFont systemFontOfSize:16.0]];
//    [self.loginPasswordField setBackgroundColor:[UIColor clearColor]];
//    [self.loginPasswordField setAutocorrectionType:UITextAutocorrectionTypeNo];
//    [self.view addSubview:self.loginPasswordField];
//    
//    y += self.loginPasswordField.frame.size.height + spacer;
    
    QBFlatButton *loginButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    loginButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    loginButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    loginButton.radius = 6.0;
    loginButton.margin = 4.0;
    loginButton.depth = 3.0;
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButton setTitle:@"Log In with DrinkUp" forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [loginButton addTarget:self action:@selector(transitionLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    y += loginButton.frame.size.height + spacer;
    
//    UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
//    [orLabel setText:@"or"];
//    [orLabel setTextAlignment:NSTextAlignmentCenter];
//    [orLabel setBackgroundColor:[UIColor clearColor]];
//    [orLabel setTextColor:[UIColor whiteColor]];
//    [self.view addSubview:orLabel];
//    
//    y += orLabel.frame.size.height + 5.0;
    
    QBFlatButton *facebookButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    facebookButton.faceColor = [UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(200/255.0) alpha:1.0];
    facebookButton.sideColor = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(170/255.0) alpha:0.7];
    facebookButton.radius = 6.0;
    facebookButton.margin = 4.0;
    facebookButton.depth = 3.0;
    facebookButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookButton setTitle:@"Log In via Facebook" forState:UIControlStateNormal];
    [facebookButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [facebookButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    y += facebookButton.frame.size.height + spacer;
    
    UIView *firstTimeContainer = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - fieldHeight * 3, fieldWidth, fieldHeight * 3)];
    [firstTimeContainer setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:firstTimeContainer];
    
    UILabel *firstTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth, fieldHeight)];
    [firstTimeLabel setText:@"First time here?"];
    [firstTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [firstTimeLabel setBackgroundColor:[UIColor clearColor]];
    [firstTimeLabel setTextColor:[UIColor whiteColor]];
    [firstTimeContainer addSubview:firstTimeLabel];
    
    UIButton *signupButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupButton2 setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signupButton2 setTitleColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0] forState:UIControlStateNormal];
    [signupButton2 setFrame:CGRectMake(0, CGRectGetMaxY(firstTimeLabel.frame) + 5.0, fieldWidth, fieldHeight)];
    [signupButton2 addTarget:self action:@selector(showSignupView) forControlEvents:UIControlEventTouchUpInside];
//    [firstTimeContainer addSubview:signupButton2];
    
    QBFlatButton *signupButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    signupButton.faceColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    signupButton.sideColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:0.7];
    signupButton.radius = 6.0;
    signupButton.margin = 4.0;
    signupButton.depth = 3.0;
    signupButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [signupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signupButton setFrame:CGRectMake(0, CGRectGetMaxY(firstTimeLabel.frame) + 5.0, fieldWidth, fieldHeight)];
    [signupButton addTarget:self action:@selector(showSignupView) forControlEvents:UIControlEventTouchUpInside];
    [firstTimeContainer addSubview:signupButton];
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
    [self.navigationController presentViewController:drinkUpLoginVC animated:YES completion:^{
    }];
}

@end
