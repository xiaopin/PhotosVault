//
//  NSString+XP.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/3.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XP)

/**
 去除字符串首尾的空白字符
 
 @return 过滤后的字符串
 */
- (NSString *)trim;

/**
 MD5加密

 @return 加密的字符串
 */
- (NSString *)md5;

/**
 判断字符串是否为IP地址

 @return YES:合法的IP地址 NO:不是IP地址
 */
- (BOOL)isIP;

@end
