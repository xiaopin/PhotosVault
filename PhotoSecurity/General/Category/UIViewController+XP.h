//
//  UIViewController+XP.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (XP)

/**
 从Main.storyboard中加载实例对象
 需要设置Storyboard ID且确保和类名保持一致

 @return 控制器实例
 */
+ (instancetype)instanceFromMainStoryboard;

@end
