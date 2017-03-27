//
//  UIColor+XP.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/7.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XP)

/**
 根据RGB获取颜色

 @param r Red色值,0~255
 @param g Green色值,0~255
 @param b Blue色值,0~255
 @return 对应的颜色
 */
+ (instancetype)colorWithR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b;

/**
 通过十六进制字符串获取颜色
 
 @param hexStr 十六进制字符串,如: #FFFFFF,FFFFFF,0xFFFFFF
 @return 对应的颜色实例
 */
+ (instancetype)colorWithHex:(NSString *)hexStr;

/**
 获取随机颜色
 */
+ (instancetype)randomColor;

@end
