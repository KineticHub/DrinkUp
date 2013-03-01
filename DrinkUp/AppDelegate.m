//
//  AppDelegate.m
//  DrinkUp
//
//  Created by Kinetic on 2/14/13.
//  Copyright (c) 2013 Kinetic. All rights reserved.
//

#import "AppDelegate.h"

#import "RecentBarsViewController.h"
#import "NearbyBarsViewController.h"
#import "FindBarSearchViewController.h"
#import "DrinkHistoryViewController.h"

#import "SharedDataHandler.h"

@interface AppDelegate ()
@property (nonatomic, strong) UINavigationController *rootNavigationController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    RecentBarsViewController *rbvc = [[RecentBarsViewController alloc] init];
    rbvc.title  = @"Recent Bars";
    
    NearbyBarsViewController *nbvc = [[NearbyBarsViewController alloc] init];
    nbvc.title  = @"Nearby Bars";
//    nbvc.tabBarItem.image = [UIImage imageNamed:@"info_bar"];
    
    FindBarSearchViewController *fbvc = [[FindBarSearchViewController alloc] init];
    fbvc.title  = @"Find Bars";
    //    nbvc.tabBarItem.image = [UIImage imageNamed:@"info_bar"];
    
    UITabBarController *tbvc = [[UITabBarController alloc] init];
    
    [tbvc addChildViewController:rbvc];
    [tbvc addChildViewController:nbvc];
    [tbvc addChildViewController:fbvc];
    
   self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:tbvc];
    // Instantiate a New button to invoke the addTask: method when tapped.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"History"
                                  style:UIBarButtonItemStylePlain
                                  target:self action:@selector(viewHistoryController:)];
    
    // Set up the Add custom button on the right of the navigation bar
    tbvc.navigationItem.rightBarButtonItem = addButton;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.rootNavigationController];
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
@end
