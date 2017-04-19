//
//  XPProgressHUD.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/6.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBProgressHUD;

@interface XPProgressHUD : NSObject

/**
 *  显示一个操作成功的HUD(自动消失)
 *
 *  @param message 提示信息
 *  @param view    目标视图
 */
+ (void)showSuccessHUD:(NSString *)message toView:(UIView *)view;

/**
 *  显示一个操作失败的HUD(自动消失)
 *
 *  @param message 提示信息
 *  @param view    目标视图
 */
+ (void)showFailureHUD:(NSString *)message toView:(UIView *)view;

/**
 *  显示一个信息类HUD(自动消失)
 *
 *  @param message 提示信息
 *  @param view    目标视图
 */
+ (void)showInfomationHUD:(NSString *)message toView:(UIView *)view;

/**
 *  显示一个正在加载的HUD(不会自动消失)
 *  默认会拦截目标视图的点击事件
 *
 *  @param message 提示信息
 *  @param view    目标视图
 *
 *  @return MBProgressHUD
 */
+ (MBProgressHUD *)showLoadingHUD:(NSString *)message toView:(UIView *)view;

/**
 *  隐藏HUD(该方法只会隐藏`第一个`添加到view中的HUD)
 *
 *  @param view 目标视图
 */
+ (BOOL)hideHUDForView:(UIView *)view;

/**
 *  隐藏view中所有的HUD
 *
 *  @param view 目标视图
 */
+ (void)hideAllHUDForView:(UIView *)view;

/**
 *  显示一个自定义的HUD(不会自动消失)
 *
 *  @param message 提示信息
 *  @param icon    HUD图标
 *  @param view    目标视图
 *
 *  @return MBProgressHUD
 */
+ (MBProgressHUD *)showCustomHUD:(NSString *)message iconName:(NSString *)icon toView:(UIView *)view;

/**
 显示一个吐司

 @param message 提示信息
 */
+ (void)showToast:(NSString *)message;

@end
