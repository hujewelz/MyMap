//
//  AppDelegate.m
//  MyMap
//
//  Created by jewelz on 15/6/19.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () 
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _mapManager = [[BMKMapManager alloc] init];
    
    BOOL ret = [_mapManager start:KEY generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [BMKMapView willBackGround];//当应用即将后台时调用，停止一切调用opengl相关的操作

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
