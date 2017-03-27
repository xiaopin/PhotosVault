//
//  XPNavigationController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPNavigationController.h"

@interface XPNavigationController ()

@end

@implementation XPNavigationController

#pragma mark - Lifecycle

+ (void)initialize {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTranslucent:NO];
    [navigationBar setBarTintColor:rgbColor(60.0, 65.0, 70.0)];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    UIImage *backImage = [[UIImage imageNamed:@"icon-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navigationBar setBackIndicatorImage:backImage];
    [navigationBar setBackIndicatorTransitionMaskImage:backImage];
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    NSDictionary *dict = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                           NSForegroundColorAttributeName: [UIColor whiteColor]
                           };
    [barButtonItem setTitleTextAttributes:dict forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count > 0) {
        /// 清除掉返回按钮的文字
        UIBarButtonItem *backItem =[[UIBarButtonItem alloc] initWithTitle:@""
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:nil
                                                                   action:nil];
        [self.topViewController.navigationItem setBackBarButtonItem:backItem];
    }
    [viewController setHidesBottomBarWhenPushed:YES];
    [super pushViewController:viewController animated:YES];
}

/// 将状态栏样式交给当前控制器处理
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.topViewController != nil) {
        return [self.topViewController preferredStatusBarStyle];
    }
    return [super preferredStatusBarStyle];
}

@end
