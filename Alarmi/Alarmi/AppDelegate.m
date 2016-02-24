//
//  AppDelegate.m
//  Alarmi
//
//  Created by zhangyuanke on 16/2/24.
//  Copyright © 2016年 kdtm. All rights reserved.
//

#import "AppDelegate.h"
#import "AMIMineViewController.h"
#import "AMISettingViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 初始化数据
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"timevalue"];
    if (value == nil) {
        // 默认1s
        NSNumber *number = [NSNumber numberWithInt:1];
        [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"timevalue"];
    }
    NSNumber *number = [NSNumber numberWithInt:10];
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"timevalue"];
    
    // 初始化页面
    [self setupTabbarController];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setupTabbarController
{
    self.tabBarController = [[UITabBarController alloc] init];
    
    AMIMineViewController *mineViewController = [[AMIMineViewController alloc] initWithNibName:nil bundle:nil];
    AMISettingViewController *settingViewController = [[AMISettingViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController *mineNavController = [[UINavigationController alloc] initWithRootViewController:mineViewController];
    UINavigationController *settingNavController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mineNavController, settingNavController, nil];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *tabItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabItem2 = [tabBar.items objectAtIndex:1];
    
    tabItem1.title = @"我的";
    tabItem2.title = @"设置";
    
    tabItem1.image = [UIImage imageNamed:@"icon_tabbar_mine"];
    tabItem2.image = [UIImage imageNamed:@"icon_tabbar_misc"];
    
    tabItem1.selectedImage = [[UIImage imageNamed:@"icon_tabbar_mine_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabItem2.selectedImage = [[UIImage imageNamed:@"icon_tabbar_misc_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication* app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
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
