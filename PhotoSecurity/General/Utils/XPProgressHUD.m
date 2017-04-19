//
//  XPProgressHUD.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/6.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation XPProgressHUD

static NSTimeInterval const kXPProgressHUDDismissDelayTimeInterval = 3.0;

+ (void)load {
    UIActivityIndicatorView *activityView = [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]];
    activityView.color = [UIColor whiteColor];
}

/**
 *  显示一个操作成功的HUD(自动消失)
 *
 *  @param message 提示信息
 *  @param view    目标视图
 */
+ (void)showSuccessHUD:(NSString *)message toView:(UIView *)view {
    MBProgressHUD *hud = [self showCustomHUD:message iconName:@"hud-success" toView:view];
    [hud hideAnimated:YES afterDelay:kXPProgressHUDDismissDelayTimeInterval];
}

/**
 *  显示一个操作失败的HUD(自动消失)
 *
 *  @param message 提示信息
 *  @param view    目标视图
 */
+ (void)showFailureHUD:(NSString *)message toView:(UIView *)view {
    MBProgressHUD *hud = [self showCustomHUD:message iconName:@"hud-error" toView:view];
    [hud hideAnimated:YES afterDelay:kXPProgressHUDDismissDelayTimeInterval];
}

/**
 *  显示一个信息类HUD(自动消失)
 *
 *  @param message 提示信息
 *  @param view    目标视图
 */
+ (void)showInfomationHUD:(NSString *)message toView:(UIView *)view {
    MBProgressHUD *hud = [self showCustomHUD:message iconName:@"hud-info" toView:view];
    [hud hideAnimated:YES afterDelay:kXPProgressHUDDismissDelayTimeInterval];
}

/**
 *  显示一个正在加载的HUD(不会自动消失)
 *  默认会拦截目标视图的点击事件
 *
 *  @param message 提示信息
 *  @param view    目标视图
 *
 *  @return MBProgressHUD
 */
+ (MBProgressHUD *)showLoadingHUD:(NSString *)message toView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.textColor = [UIColor whiteColor];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.userInteractionEnabled = YES;
    hud.bezelView.color = [UIColor blackColor];
    return hud;
}

/**
 *  隐藏HUD(该方法只会隐藏`第一个`添加到view中的HUD)
 *
 *  @param view 目标视图
 */
+ (BOOL)hideHUDForView:(UIView *)view {
    return [MBProgressHUD hideHUDForView:view animated:YES];
}

/**
 *  隐藏view中所有的HUD
 *
 *  @param view 目标视图
 */
+ (void)hideAllHUDForView:(UIView *)view {
    NSMutableArray<MBProgressHUD *> *huds = [NSMutableArray array];
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:[MBProgressHUD class]]) {
            [huds addObject:(MBProgressHUD *)subview];
        }
    }
    
    for (MBProgressHUD *hud in huds) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES];
    }
}

/**
 *  显示一个自定义的HUD(不会自动消失)
 *
 *  @param message 提示信息
 *  @param icon    HUD图标
 *  @param view    目标视图
 *
 *  @return MBProgressHUD
 */
+ (MBProgressHUD *)showCustomHUD:(NSString *)message iconName:(NSString *)icon toView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabel.text = message;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = NO;
    hud.bezelView.color = [UIColor blackColor];
    hud.detailsLabel.textColor = [UIColor whiteColor];
    return hud;
}

/**
 显示一个吐司
 
 @param message 提示信息
 */
+ (void)showToast:(NSString *)message {
    UIWindow *frontWindow = nil;
    NSEnumerator *windows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    for (UIWindow *window in windows) {
        if (window.screen == [UIScreen mainScreen] &&
            window.hidden == NO &&
            window.alpha > 0.0 &&
            window.windowLevel >= UIWindowLevelNormal) {
            frontWindow = window;
            break;
        }
    }
    CGFloat yOffset = [UIScreen mainScreen].bounds.size.height-60.0;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:frontWindow animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor blackColor];
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.text = message;
    hud.offset = CGPointMake(0.0, yOffset);
    [hud hideAnimated:YES afterDelay:kXPProgressHUDDismissDelayTimeInterval];
}

@end
