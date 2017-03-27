//
//  UIColor+XP.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/7.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "UIColor+XP.h"

@implementation UIColor (XP)

/**
 根据RGB获取颜色
 
 @param r Red色值,0~255
 @param g Green色值,0~255
 @param b Blue色值,0~255
 @return 对应的颜色
 */
+ (instancetype)colorWithR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

/**
 通过十六进制字符串获取颜色
 
 @param hexStr 十六进制字符串,如: #FFFFFF,FFFFFF,0xFFFFFF
 @return 对应的颜色实例
 */
+ (instancetype)colorWithHex:(NSString *)hexStr {
    if ([hexStr hasPrefix:@"#"]) {
        hexStr = [hexStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    unsigned int hex;
    if (![scanner scanHexInt:&hex]) {
        return [UIColor whiteColor];
    }
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = hex & 0xFF;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

/**
 获取随机颜色
 */
+ (instancetype)randomColor {
    return [UIColor colorWithRed:arc4random_uniform(256)/255.0
                           green:arc4random_uniform(256)/255.0
                            blue:arc4random_uniform(256)/255.0
                           alpha:1.0];
}

@end
