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

@interface UserLoginViewController ()
@property (nonatomic, strong) UITextField *loginUsernameOrEmailField;
@property (nonatomic, strong) UITextField *loginPasswordField;
@end

@implementation UserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [[SharedDataHandler sharedInstance] initializeFacebook];
//    Facebook *facebook = [[SharedDataHandler sharedInstance] facebookInstance];

    [self setupUserProfileView];
}

-(void)loginWithFacebook:(id)sender
{
    [[SharedDataHandler sharedInstance] authorizeFacebook];
}

-(void)logoutFacebook:(id)sender {
    
    [[SharedDataHandler sharedInstance].facebookInstance logout];
    
//    UIButton *fb_button = (UIButton *)sender;
//    [fb_button setTitle:@"Login with Facebook" forState:UIControlStateNormal];
//    [fb_button addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)loginToServer:(id)sender {
    
    NSMutableDictionary *creds = [[NSMutableDictionary alloc] init];
    [creds setObject:self.loginUsernameOrEmailField.text forKey:@"username"];
    [creds setObject:self.loginPasswordField.text forKey:@"password"];
    [[SharedDataHandler sharedInstance] userLoginToServerWithCredentials:creds];
    
    [self transitionView:1];
}

-(void)logoutFromServer:(id)sender {
    
    NSLog(@"Logout attempt");
    [[SharedDataHandler sharedInstance] userLogoutOfServer];
    
    [self transitionView:0];
}

-(void)showSignupView {
    SignupViewController *suvc = [[SignupViewController alloc] init];
    [self.navigationController pushViewController:suvc animated:YES];
}

-(void)postToFacebookWall:(id)sender {
    
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I'm not convinced I'm not an actual wolf when I'm wearing my hat.", @"message", nil];
//    [[[SharedDataHandler sharedInstance] facebookInstance] dialog:@"feed" andParams:params andDelegate:[SharedDataHandler sharedInstance]];
//    [[[SharedDataHandler sharedInstance] facebookInstance] requestWithMethodName:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:[SharedDataHandler sharedInstance]];
}

- (void)logoutButtonClicked:(id)sender {
    // Method that gets called when the logout button is pressed
//    [[[SharedDataHandler sharedInstance] facebookInstance] logout];
}

-(void)transitionView:(int)viewChoice
{
    [UIView animateWithDuration:0.8 animations:^
    {
        self.view.alpha = 0.0;
    } completion:^(BOOL finished)
    {
        [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if (viewChoice == 0) {
            [self setupUserLoginView];
        } else {
            [self setupUserProfileView];
        }
        
        [UIView animateWithDuration:0.8 animations:^
         {
             self.view.alpha = 1.0;
         }];
    }];
}

#pragma mark - User Profile View
-(void)setupUserProfileView
{
    CGFloat y = 20.0;
    CGFloat spacer = 10.0;
    CGFloat edgeInset = 10.0;
    CGFloat fieldWidth = 300.0;
    CGFloat fieldHeight = 40.0;
    
    /* this actually goes behind the rest of the content */
    UIView *bgDarkView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [bgDarkView setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.6]];
    [self.view addSubview:bgDarkView];
    
    UIImageView *profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(edgeInset, y, 120, 120)];
    [profilePicView setBackgroundColor:[UIColor redColor]];
    [profilePicView.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
    [profilePicView.layer setBorderWidth:5.0];
    [profilePicView.layer setCornerRadius:8.0];
    [profilePicView.layer setMasksToBounds:YES];
    [profilePicView setCenter:CGPointMake(self.view.frame.size.width/2, profilePicView.center.y)];
    [self.view addSubview:profilePicView];
    
    y += profilePicView.frame.size.height + spacer;
    
    UILabel *profileName = [[UILabel alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [profileName setBackgroundColor:[UIColor clearColor]];
    [profileName setTextAlignment:NSTextAlignmentCenter];
    [profileName setText:@"Hey, UserProfileName!"];
    [profileName setTextColor:[UIColor whiteColor]];
    [profileName setFont:[UIFont boldSystemFontOfSize:24.0]];
    [self.view addSubview:profileName];
    
    //    y += profileName.frame.size.height + spacer;
    
    y = bgDarkView.frame.size.height + spacer * 5;
    
    QBFlatButton *logoutButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    logoutButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
    logoutButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
    logoutButton.radius = 6.0;
    logoutButton.margin = 4.0;
    logoutButton.depth = 3.0;
    logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [logoutButton addTarget:self action:@selector(logoutFromServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
    
    y += logoutButton.frame.size.height + spacer;
}

#pragma mark - User Login Options
-(void)setupUserLoginView
{
    CGFloat y = 10.0;
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
    [coloredBgView1 setBackgroundColor:[UIColor whiteColor]];
    [coloredBgView1.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
    [coloredBgView1.layer setBorderWidth:3.0];
    [coloredBgView1.layer setCornerRadius:5.0];
    [self.view addSubview:coloredBgView1];
    
    self.loginUsernameOrEmailField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.loginUsernameOrEmailField setPlaceholder:@"Email"];
    [self.loginUsernameOrEmailField setTextColor:[UIColor blackColor]];
    [self.loginUsernameOrEmailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.loginUsernameOrEmailField setFont:[UIFont systemFontOfSize:16.0]];
    [self.loginUsernameOrEmailField setBackgroundColor:[UIColor clearColor]];
//    [self.loginUsernameOrEmailField setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [self.view addSubview:self.loginUsernameOrEmailField];
    
    y += self.loginUsernameOrEmailField.frame.size.height + spacer/2;
    
    UIView *coloredBgView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [coloredBgView2 setBackgroundColor:[UIColor whiteColor]];
    [coloredBgView2.layer setBorderColor:[[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] CGColor]];
    [coloredBgView2.layer setBorderWidth:3.0];
    [coloredBgView2.layer setCornerRadius:5.0];
    [self.view addSubview:coloredBgView2];
    
    self.loginPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(edgeInset + 10.0, y, fieldWidth - 20.0, fieldHeight)];
    [self.loginPasswordField setPlaceholder:@"Password"];
    [self.loginPasswordField setSecureTextEntry:YES];
    [self.loginPasswordField setTextColor:[UIColor blackColor]];
    [self.loginPasswordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.loginPasswordField setFont:[UIFont systemFontOfSize:16.0]];
    [self.loginPasswordField setBackgroundColor:[UIColor clearColor]];
//    [self.loginPasswordField setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [self.view addSubview:self.loginPasswordField];
    
    y += self.loginPasswordField.frame.size.height + spacer;
    
    QBFlatButton *loginButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    loginButton.faceColor = [UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0];
    loginButton.sideColor = [UIColor colorWithRed:(50/255.0) green:(140/255.0) blue:(145/255.0) alpha:0.7];
    loginButton.radius = 6.0;
    loginButton.margin = 4.0;
    loginButton.depth = 3.0;
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setTitle:@"Login to DrinkUp" forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight + 5.0)];
    [loginButton addTarget:self action:@selector(loginToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    y += loginButton.frame.size.height + spacer;
    y += spacer;
    
    QBFlatButton *facebookButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    facebookButton.faceColor = [UIColor colorWithRed:(43/255.0) green:(74/255.0) blue:(131/255.0) alpha:1.0];
    facebookButton.sideColor = [UIColor colorWithRed:(33/255.0) green:(64/255.0) blue:(121/255.0) alpha:0.7];
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
    [bottomView1 setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [self.view addSubview:bottomView1];
    
    y += bottomView1.frame.size.height + spacer + 35.0;
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth/2, fieldHeight)];
    [newLabel setText:@"First time here?"];
    [newLabel setTextAlignment:NSTextAlignmentCenter];
    [newLabel setBackgroundColor:[UIColor clearColor]];
    [newLabel setTextColor:[UIColor whiteColor]];
    [bottomView1 addSubview:newLabel];
    
    UIButton *signupButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupButton2 setTitle:@"SignUp" forState:UIControlStateNormal];
    [signupButton2 setTitleColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] forState:UIControlStateNormal];
    [signupButton2 setFrame:CGRectMake(CGRectGetMaxX(newLabel.frame), 0, fieldWidth/2, fieldHeight)];
    [signupButton2 addTarget:self action:@selector(showSignupView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView1 addSubview:signupButton2];
    
    UIView *bottomView2 = [[UIView alloc] initWithFrame:CGRectMake(edgeInset, y, fieldWidth, fieldHeight)];
    [bottomView2 setBackgroundColor:[UIColor colorWithRed:(34/255.0) green:(34/255.0) blue:(34/255.0) alpha:0.7]];
    [self.view addSubview:bottomView2];
    
    y += bottomView2.frame.size.height + spacer/2;
    
    UILabel *recoverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldWidth/2, fieldHeight)];
    [recoverLabel setText:@"Forget password?"];
    [recoverLabel setTextAlignment:NSTextAlignmentCenter];
    [recoverLabel setBackgroundColor:[UIColor clearColor]];
    [recoverLabel setTextColor:[UIColor whiteColor]];
    [bottomView2 addSubview:recoverLabel];
    
    UIButton *forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotButton setTitle:@"Reset" forState:UIControlStateNormal];
    [forgotButton setTitleColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0] forState:UIControlStateNormal];
    [forgotButton setFrame:CGRectMake(CGRectGetMaxX(newLabel.frame), 0, fieldWidth/2, fieldHeight)];
    [bottomView2 addSubview:forgotButton];
}

@end
