//
//  UIViewController+XP.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "UIViewController+XP.h"
#import <objc/runtime.h>

@implementation UIViewController (XP)

#pragma mark - Public

/**
 从Main.storyboard中加载实例对象
 需要设置Storyboard ID且确保和类名保持一致
 
 @return 控制器实例
 */
+ (instancetype)instanceFromMainStoryboard {
    NSString *identifier = NSStringFromClass([self class]);
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    return vc;
}

#pragma mark -

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([UIViewController class], @selector(preferredStatusBarStyle));
        Method swizzledMethod = class_getInstanceMethod([UIViewController class], @selector(xp_preferredStatusBarStyle));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

/**
 *  通过hook系统preferredStatusBarStyle方法,返回App全局的状态栏样式
 *  如果某个控制器需要显示不同的状态栏样式,重写preferredStatusBarStyle方法即可
 *
 *  @return 状态栏样式
 */
- (UIStatusBarStyle)xp_preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
