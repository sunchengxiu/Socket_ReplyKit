//
//  AppDelegate.m
//  Socket_Replykit
//
//  Created by 孙承秀 on 2020/5/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
       if (@available(iOS 13,*)) {
            return YES;
        } else {
            self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            UINavigationController *rootNavgationController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
            self.window.rootViewController = rootNavgationController;
            [self.window makeKeyAndVisible];
            return YES;
        }

 
    return YES;
}


#pragma mark - UISceneSession lifecycle




@end
