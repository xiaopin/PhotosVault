//
//  QLPreviewController+XP.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/23.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "QLPreviewController+XP.h"
#import <objc/runtime.h>

/**
 由于QLPreviewController在真机测试时(iPhone5s iOS9.3.5)未能返回正确的状态栏样式
 重新对QLPreviewController的`-preferredStatusBarStyle`方法进行hook，返回正确的状态栏样式
 
 至于为什么在`UIViewController+XP`文件中的hook失败原因，初步猜想有可能是：
    因为QuickLook.framework是系统动态库，系统在App使用前已经将QLPreviewController类加载进内存了，
    导致在`UIViewController+XP`的hook失败，此时需要重新hook，并指明是QLPreviewController类的Category
 */

@implementation QLPreviewController (XP)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([QLPreviewController class], @selector(preferredStatusBarStyle));
        Method swizzledMethod = class_getInstanceMethod([QLPreviewController class], @selector(ql_preferredStatusBarStyle));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}


- (UIStatusBarStyle)ql_preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
