//
//  XPPasswordTool.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/6.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPPasswordTool : NSObject

/**
 是否已经设置过密码

 @return YES:已设置了密码 NO:首次使用,还未设置密码
 */
+ (BOOL)isSetPassword;

///**
// 是否开启了TouchID功能
// */
//+ (BOOL)isEnableTouchID;

/**
 校验给定的密码是否与用户设置的密码匹配

 @param password 待校验的密码明文
 @return Bool
 */
+ (BOOL)verifyPassword:(NSString *)password;

/**
 存储密码到本地沙盒文件中

 @param password 待存储的密码明文(存储之前会进行加密)
 */
+ (void)storagePassword:(NSString *)password;

@end
