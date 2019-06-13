//
//  AppDelegate.m
//  Example
//
//  Created by Stefan Nebel on 13.06.19.
//  Copyright © 2019 CosmicMind, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllers.h"

@interface AppDelegate ()
@end



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[VC_1 alloc] init]];
  [nc setModalPresentationStyle:UIModalPresentationFullScreen];
  [[nc navigationBar] setBarTintColor:[UIColor darkGrayColor]];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setRootViewController:nc];
  [self.window makeKeyAndVisible];
  
  return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
