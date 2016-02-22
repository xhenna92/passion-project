//
//  AppDelegate.m
//  grocery-objc
//
//  Created by Shena Yoshida on 2/16/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "AppDelegate.h"
//model
#import "YALTabBarItem.h"

//controller
#import "YALFoldingTabBarController.h"

//helpers
#import "YALAnimatingTabBarConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
COLOR KEY: 
 
white color: [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1]
peach color: [UIColor colorWithRed:248.0/255.0 green:213.0/255.0 blue:199.0/255.0 alpha:1]
 
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UINavigationBar.appearance.barTintColor = [UIColor blackColor];
    
    
    YALFoldingTabBarController *tabBarController = (YALFoldingTabBarController *) self.window.rootViewController;
    
    //prepare leftBarItems
    YALTabBarItem *item1 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"kitchen"]
                                                      leftItemImage:nil
                                                     rightItemImage:nil];
    
    tabBarController.leftBarItems = @[item1];
    
    //prepare rightBarItems
    
    
    YALTabBarItem *item3 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"cooking-4"]
                                                      leftItemImage:nil
                                                     rightItemImage:nil];
    
    tabBarController.rightBarItems = @[item3];
    
    tabBarController.centerButtonImage = [UIImage imageNamed:@"sign"];
    
    tabBarController.selectedIndex = 0;
    
    //customize tabBarView
    tabBarController.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight;
    tabBarController.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset;
    tabBarController.tabBarView.backgroundColor = [UIColor blackColor];
    tabBarController.tabBarView.tabBarColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
//    tabBarController.tabBarView.dotColor = [UIColor colorWithRed:94.0/255.0 green:91.0/255.0 blue:149.0/255.0 alpha:1];
    tabBarController.tabBarViewHeight = YALTabBarViewDefaultHeight;
    tabBarController.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets;
    tabBarController.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
