//
//  AppDelegate.m
//  PhotoSecurity
//
//  Created by xiaopin on 2017/3/1.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "AppDelegate.h"
#import "GHPopupEditView.h"
#import "XPUnlockViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.backgroundColor = [UIColor whiteColor];
    checkPhotoRootDirectory();
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (0 == [userDefaults stringForKey:XPEncryptionPasswordRandomKey].length) {
        NSString *random = randomString(6);
        [userDefaults setObject:random forKey:XPEncryptionPasswordRandomKey];
        [userDefaults synchronize];
    }
    // 初始化数据库
    [[XPSQLiteManager sharedSQLiteManager] initializationDatabase];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([XPPasswordTool isSetPassword]) {
        for (UIView *subview in self.window.subviews) {
            if ([subview isKindOfClass:[GHPopupEditView class]]) {
                [subview removeFromSuperview];
            }
        }
        UIViewController *rootVc = [self.window rootViewController];
        if (nil == rootVc.presentedViewController || ![rootVc.presentedViewController isKindOfClass:[XPUnlockViewController class]]) {
            [rootVc.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *unlockVc = [mainStoryboard instantiateViewControllerWithIdentifier:@"XPUnlockViewController"];
            [rootVc presentViewController:unlockVc animated:NO completion:nil];
        }
    }
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
