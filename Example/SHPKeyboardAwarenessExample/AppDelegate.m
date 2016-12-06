//
//  AppDelegate.m
//  SHPKeyboardAwarenessExample
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AdvancedViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *viewController = [ViewController new];
    AdvancedViewController *advancedViewController = [AdvancedViewController new];
    
    viewController.tabBarItem.title = @"Example 1";
    advancedViewController.tabBarItem.title = @"Example 2";
    
    UITabBarController *tabBarController = [UITabBarController new];
    [tabBarController setViewControllers:@[ viewController, advancedViewController ]];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
