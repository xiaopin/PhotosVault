//
//  functions.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 获取相册根目录

 @return 相册根目录的绝对路径
 */
UIKIT_EXTERN NSString* photoRootDirectory();

/**
 检测相册根目录,如果不存在则创建
 */
UIKIT_EXTERN void checkPhotoRootDirectory();

/**
 对密码进行加密

 @param password 密码明文
 @param random 随机字符
 @return 加密后的新密码
 */
UIKIT_EXTERN NSString *encryptionPassword(NSString *password, NSString *random);

/**
 随机字符串

 @param length 字符串长度
 @return 返回规定长度的随机字符串
 */
UIKIT_EXTERN NSString* randomString(int length);

/**
 创建一个随机且不存在的相册目录

 @return 随机目录
 */
UIKIT_EXTERN NSString* createRandomAlbumDirectory();

/**
 生成唯一标识的字符串(由当前时间加一个5位随机数组成)
 
 @return 唯一标识符
 */
UIKIT_EXTERN NSString* generateUniquelyIdentifier();

/**
 是否开启TouchID功能

 @return YES:已启动TouchID, NO:未启用TouchID
 */
UIKIT_EXTERN BOOL isEnableTouchID();

/**
 判断系统版本是否大于等于给定的版本
 
 @param majorVersion 主版本号
 @param minorVersion 次版本号
 @param patchVersion 补丁版本号
 @return BOOL
 */
UIKIT_EXTERN BOOL isOperatingSystemAtLeastVersion(NSInteger majorVersion, NSInteger minorVersion, NSInteger patchVersion);


///////////////////////////////
////        内联函数        ////
///////////////////////////////

/**
 通过RGB获取颜色
 */
UIKIT_STATIC_INLINE UIColor* rgbColor(CGFloat r, CGFloat g, CGFloat b)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

/**
 判断当前设备是否为iPad
 */
UIKIT_STATIC_INLINE BOOL iPad()
{
    return UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad;
}


///////////////////////////
////        常量        ////
///////////////////////////

/// 密码
FOUNDATION_EXTERN NSString * const XPPasswordKey;
/// 密码随机字符
FOUNDATION_EXTERN NSString * const XPEncryptionPasswordRandomKey;
/// 密码最小长度
FOUNDATION_EXTERN NSInteger const XPPasswordMinimalLength;
/// TouchID是否启用
FOUNDATION_EXTERN NSString * const XPTouchEnableStateKey;
/// 缩略图目录名称
FOUNDATION_EXTERN NSString * const XPThumbDirectoryNameKey;
/// 生成的缩略图的宽高尺寸
FOUNDATION_EXTERN CGFloat const XPThumbImageWidthAndHeightKey;

