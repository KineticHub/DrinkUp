//
//  AppDelegate.m
//  DrinkUp
//
//  Created by Kinetic on 2/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "AppDelegate.h"
#import <UAirship.h>
#import <UAPush.h>
#import "FacebookSDK.h"

#import "RecentBarsViewController.h"
#import "BSTNearbyBarsViewController.h"
#import "BSTNearbyBarsViewController.h"
#import "FindBarSearchViewController.h"
#import "DrinkHistoryViewController.h"
#import "UserLoginViewController.h"
#import "SignupViewController.h"
#import "MainSettingsViewController.h"
#import "SharedDataHandler.h"
#import "NearbyBarsMapViewController.h"

#import "REMenu.h"
#import "PKRevealController.h"

@interface AppDelegate ()
@property (nonatomic, strong) REMenu *menu;
@property (nonatomic, strong) PKRevealController *revealController;
@property (nonatomic, strong) UIBarButtonItem *settingsButton;
@property (nonatomic, strong) UIBarButtonItem *mapButton;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Call takeOff, passing in the launch options so the library can properly record when
    // the app is launched from a push notification
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // This prevents the UA Library from registering with UIApplcation by default when
    // registerForRemoteNotifications is called. This will allow you to prompt your
    // users at a later time. This gives your app the opportunity to explain the benefits
    // of push or allows users to turn it on explicitly in a settings screen.
    // If you just want everyone to immediately be prompted for push, you can
    // leave this line out.
//    [UAPush setDefaultPushEnabledValue:NO];
    
    // Create Airship singleton that's used to talk to Urban Airhship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge];//zero badge on startup
    
    // Register for remote notfications. With the default value of push set to no,
    // UAPush will record the desired remote notifcation types, but not register for
    // push notfications as mentioned above.
    // When push is enabled at a later time, the registration will occur as normal.
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
    
    
    self.loginViewController = [[UserLoginViewController alloc] init];
    self.session = [FBSession activeSession];
    
    
    RecentBarsViewController *rbvc = [[RecentBarsViewController alloc] init];
    rbvc.title  = @"Recent Bars";
    
//    NearbyBarsViewController *nbvc = [[NearbyBarsViewController alloc] init];
    BSTNearbyBarsViewController *nbvc = [[BSTNearbyBarsViewController alloc] init];
    nbvc.title  = @"Nearby Bars";
//    nbvc.tabBarItem.image = [UIImage imageNamed:@"info_bar"];
    
    FindBarSearchViewController *fbvc = [[FindBarSearchViewController alloc] init];
    fbvc.title  = @"Find Bars";
    //    nbvc.tabBarItem.image = [UIImage imageNamed:@"info_bar"];
    
    UITabBarController *tbvc = [[UITabBarController alloc] init];
    
//    [tbvc addChildViewController:rbvc];
    [tbvc addChildViewController:nbvc];
    [tbvc addChildViewController:fbvc];
    
//    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:tbvc];
//    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:nbvc];

    NSMutableArray *navItemsArray = [[NSMutableArray alloc] init];
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"History"
                                  style:UIBarButtonItemStylePlain
                                  target:self action:@selector(viewHistoryController:)];
    [navItemsArray addObject:historyButton];
    
    self.mapButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Map"
                                      style:UIBarButtonItemStylePlain
                                      target:self action:@selector(showMap)];
    
    // Instantiate a New button to invoke the addTask: method when tapped.
    self.settingsButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Settings"
                                      style:UIBarButtonItemStylePlain
                                      target:self action:@selector(showMenu)];
//    [navItemsArray addObject:settingsButton];
    
    // Set up the Add custom button on the right of the navigation bar
    tbvc.navigationItem.rightBarButtonItems = navItemsArray;
    nbvc.navigationItem.rightBarButtonItems = navItemsArray;
    
//    nbvc.navigationItem.leftBarButtonItem = settingsButton;
    
//////////////////////
    MainSettingsViewController *msvc = [[MainSettingsViewController alloc] init];
//    [msvc.view setBackgroundColor:[UIColor clearColor]];
    NearbyBarsMapViewController *nbmvc = [[NearbyBarsMapViewController alloc] init];
//    [nbmvc.view setBackgroundColor:[UIColor clearColor]];
//    [nbmvc.view setBackgroundColor:[UIColor clearColor]];
    self.revealController = [PKRevealController revealControllerWithFrontViewController:nbvc leftViewController:nbmvc rightViewController:nil options:nil];
    self.revealController.navigationItem.rightBarButtonItem = self.settingsButton;
    self.revealController.navigationItem.leftBarButtonItem = self.mapButton;
//////////////////////
    
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:self.revealController];
    
//    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_background.jpg"]];
    UIView *background = [[UIView alloc] init];
    
//    [background setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pw_maze_white_@2X"]]];
    [background setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black_thread"]]];
//    [background setBackgroundColor:[UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(239/255.0) alpha:1.0]];
//    [background setBackgroundColor:[UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0]];
    background.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.rootNavigationController.view addSubview:background];
    [self.rootNavigationController.view sendSubviewToBack:background];
    [self.rootNavigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
//    [self.rootNavigationController.navigationBar setTintColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0]];
    
    [self.revealController.view addSubview:background];
    [self.revealController.view sendSubviewToBack:background];
    [self.revealController.frontViewController.navigationController.view addSubview:background];
    [self.revealController.frontViewController.navigationController.view sendSubviewToBack:background];
//    [self.revealController.navigationController.navigationBar setTintColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.rootNavigationController];
//    [self.window setRootViewController:revealController];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{    
    return [[SharedDataHandler sharedInstance].facebookInstance handleOpenURL:url];
    
//    // Facebook SDK * login flow *
//    // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
//    if ([[FBSession activeSession] handleOpenURL:url]) {
//        return YES;
//    } else {
//        // Facebook SDK * App Linking *
//        // For simplicity, this sample will ignore the link if the session is already
//        // open but a more advanced app could support features like user switching.
//        // Otherwise extract the app link data from the url and open a new active session from it.
//        NSString *appID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
//        FBAccessTokenData *appLinkToken = [FBAccessTokenData createTokenFromFacebookURL:url
//                                                                                  appID:appID
//                                                                        urlSchemeSuffix:nil];
//        if (appLinkToken) {
//            if ([FBSession activeSession].isOpen) {
//                NSLog(@"INFO: Ignoring app link because current session is open.");
//            } else {
//                [self handleAppLink:appLinkToken];
//                return YES;
//            }
//        }
//    }
//    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[UAPush shared] resetBadge]; // zero badge after push received
    
    NSLog(@"applicationWillEnterForeground");
    [SharedDataHandler sharedInstance].isNotificationsEnabled = YES;
    UIRemoteNotificationType status = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (status == UIRemoteNotificationTypeNone)
    {
        NSLog(@"User doesn't want to receive push-notifications, need to force use");
        [SharedDataHandler sharedInstance].isNotificationsEnabled = NO;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=Network"]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application	{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [UAirship land];
    [FBSession.activeSession close];
}

#pragma mark - NavBar Button Methods
-(void)viewHistoryController:(id)sender {
    DrinkHistoryViewController *historyVC = [[DrinkHistoryViewController alloc] init];
    [self.rootNavigationController pushViewController:historyVC animated:YES];
}

-(void)viewSettingsController:(id)sender {
//    UserLoginViewController *settingsVC = [[UserLoginViewController alloc] init];
//    [self.rootNavigationController pushViewController:settingsVC animated:YES];
    
    MainSettingsViewController *msvc = [[MainSettingsViewController alloc] init];
    [self.rootNavigationController pushViewController:msvc animated:YES];
}

- (void)showMap
{
    if (self.revealController.focusedController == self.revealController.leftViewController)
    {
        [self.revealController showViewController:self.revealController.frontViewController];
    }
    else
    {
        [self.revealController showViewController:self.revealController.leftViewController];
    }
}

-(void)showMenu
{
    UserLoginViewController *userLoginVC = [[UserLoginViewController alloc] init];
    [self.rootNavigationController pushViewController:userLoginVC animated:YES];
//    if (self.revealController.focusedController == self.revealController.rightViewController)
//    {
//        [self.revealController showViewController:self.revealController.frontViewController];
//    }
//    else
//    {
//        [self.revealController showViewController:self.revealController.rightViewController];
//    }
}

#pragma mark - Push Notifications Methods

// Implement the iOS device token registration callback
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UALOG(@"APN device token: %@", deviceToken);
    
    // Updates the device token and registers the token with UA. This won't occur until
    // push is enabled if the outlined process is followed.

    NSLog(@"registering device");
//    [[UAPush shared] setAlias:[[[SharedDataHandler sharedInstance] userInformation] objectForKey:@"ua_username"]];
    [[UAPush shared] registerDeviceToken:deviceToken];
}

// Implement the iOS callback for incoming notifications
//
// Incoming Push notifications can be handled by the UAPush default alert handler,
// which displays a simple UIAlertView, or you can provide you own delegate which
// conforms to the UAPushNotificationDelegate protocol.
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Send the alert to UA
    [[UAPush shared] handleNotification:userInfo
                       applicationState:application.applicationState];
    
    // Reset the badge if you are using that functionality
    [[UAPush shared] resetBadge]; // zero badge after push received
    [[UAPush shared] setBadgeNumber:0];
    
    NSLog(@"notification: %@", userInfo);
    NSString *messageText = messageText = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Order Update"
                                                      message:messageText
                                                     delegate:self
                                            cancelButtonTitle:@"Sounds Good"
                                            otherButtonTitles:nil];
    [message show];
}

#pragma  mark -Facebook Helper
// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                  [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    self.isNavigating = NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isNavigating = YES;
}
@end
