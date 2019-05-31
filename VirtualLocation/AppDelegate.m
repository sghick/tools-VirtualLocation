//
//  AppDelegate.m
//  VirtualLocation
//
//  Created by 丁治文 on 2019/5/8.
//  Copyright © 2019 sumrise. All rights reserved.
//

#import "AppDelegate.h"
#import <SMRBaseCore/SMRBaseCore.h>
#import "SMRNavigationController.h"
#import "SwipLocationController.h"
#import "MapLocationController.h"
#import "ViewController.h"
#import "WebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    MapLocationController *map = [[MapLocationController alloc] init];
    map.isMainPage = YES;
    SMRNavigationController *navMap = [[SMRNavigationController alloc] initWithRootViewController:map];
    navMap.tabBarItem.title = @"地图";
    
    SwipLocationController *swipe = [[SwipLocationController alloc] init];
    swipe.isMainPage = YES;
    SMRNavigationController *navSwipe = [[SMRNavigationController alloc] initWithRootViewController:swipe];
    navSwipe.tabBarItem.title = @"方向";
    
    ViewController *main = [[ViewController alloc] init];
    main.isMainPage = YES;
    SMRNavigationController *navMain = [[SMRNavigationController alloc] initWithRootViewController:main];
    navMain.tabBarItem.title = @"定位";
    
    WebViewController *web = [[WebViewController alloc] init];
    web.isMainPage = YES;
    SMRNavigationController *navWeb = [[SMRNavigationController alloc] initWithRootViewController:web];
    navWeb.tabBarItem.title = @"坐标";
    
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.viewControllers = @[navSwipe, navMain, navWeb];
    
    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
