//
//  XPPasswordTool.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/6.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPPasswordTool.h"

@implementation XPPasswordTool

/**
 是否已经设置过密码
 
 @return YES:已设置了密码 NO:首次使用,还未设置密码
 */
+ (BOOL)isSetPassword {
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:XPPasswordKey];
    // 密码采用MD5加密,长度固定为32个字符
    return password.length==32;
}

///**
// 是否开启了TouchID功能
// */
//+ (BOOL)isEnableTouchID {
//    BOOL isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:XPTouchEnableStateKey];
//    return isEnable;
//}

/**
 校验给定的密码是否与用户设置的密码匹配
 
 @param password 待校验的密码明文
 @return Bool
 */
+ (BOOL)verifyPassword:(NSString *)password {
    if (password.length < XPPasswordMinimalLength || ![self isSetPassword]) {
        return NO;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *localPassword = [userDefaults stringForKey:XPPasswordKey];
    NSString *random = [userDefaults stringForKey:XPEncryptionPasswordRandomKey];
    NSString *newPassword = encryptionPassword(password, random);
    return [localPassword isEqualToString:newPassword];
}

/**
 存储密码到本地沙盒文件中
 
 @param password 待存储的密码明文(存储之前会进行加密)
 */
+ (void)storagePassword:(NSString *)password {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *random = [userDefaults stringForKey:XPEncryptionPasswordRandomKey];
    NSString *result = encryptionPassword(password, random);
    [userDefaults setObject:result forKey:XPPasswordKey];
    [userDefaults synchronize];
}

@end
