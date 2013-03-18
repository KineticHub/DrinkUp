//
//  AppDelegate.m
//  DrinkUp
//
//  Created by Kinetic on 2/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "AppDelegate.h"

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
@property (nonatomic, strong) UINavigationController *rootNavigationController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
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
    NearbyBarsMapViewController *nbmvc = [[NearbyBarsMapViewController alloc] init];
    self.revealController = [PKRevealController revealControllerWithFrontViewController:nbvc leftViewController:msvc rightViewController:nbmvc options:nil];
    self.revealController.navigationItem.leftBarButtonItem = self.settingsButton;
    self.revealController.navigationItem.rightBarButtonItem = self.mapButton;
//////////////////////
    
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:self.revealController];
    
//    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_background.jpg"]];
    UIView *background = [[UIView alloc] init];
    
//    [background setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pw_maze_white_@2X"]]];
    [background setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"px_by_Gre3g"]]];
//    [background setBackgroundColor:[UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(239/255.0) alpha:1.0]];
//    [background setBackgroundColor:[UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0]];
    background.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.rootNavigationController.view addSubview:background];
    [self.rootNavigationController.view sendSubviewToBack:background];
    [self.rootNavigationController.navigationBar setTintColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0]];
    
    [self.revealController.view addSubview:background];
    [self.revealController.view sendSubviewToBack:background];
    [self.revealController.navigationController.navigationBar setTintColor:[UIColor colorWithRed:(59/255.0) green:(149/255.0) blue:(154/255.0) alpha:1.0]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.rootNavigationController];
//    [self.window setRootViewController:revealController];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[SharedDataHandler sharedInstance].facebookInstance handleOpenURL:url];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

- (void)showMenu
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

-(void)showMap {
    if (self.revealController.focusedController == self.revealController.rightViewController)
    {
        [self.revealController showViewController:self.revealController.frontViewController];
    }
    else
    {
        [self.revealController showViewController:self.revealController.rightViewController];
    }
}
@end
