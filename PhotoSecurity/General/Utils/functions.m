//
//  functions.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "functions.h"
#import <LocalAuthentication/LocalAuthentication.h>

/**
 获取相册根目录
 
 @return 相册根目录的绝对路径
 */
NSString* photoRootDirectory()
{
    static NSString *root;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        root = [document stringByAppendingPathComponent:@"Photos"];
    });
    return root;
}

/**
 检测相册根目录,如果不存在则创建
 */
void checkPhotoRootDirectory()
{
    NSString *photoRootDir = photoRootDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL isExists = [fileManager fileExistsAtPath:photoRootDir isDirectory:&isDirectory];
    if (isExists && isDirectory) return;
    if (isExists) [fileManager removeItemAtPath:photoRootDir error:nil];
    [fileManager createDirectoryAtPath:photoRootDir withIntermediateDirectories:YES attributes:nil error:nil];
    // 禁止备份该目录
    NSURL *url = [NSURL fileURLWithPath:photoRootDir];
    [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
}

/**
 对密码进行加密
 
 @param password 密码明文
 @param random 随机字符
 @return 加密后的新密码
 */
NSString *encryptionPassword(NSString *password, NSString *random)
{
    NSString *value = [[password md5] stringByAppendingString:random];
    return [value md5];
}

/**
 随机字符串
 
 @param length 字符串长度
 @return 返回规定长度的随机字符串
 */
NSString* randomString(int length)
{
    NSString *characters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *value = [NSMutableString string];
    for (int i=0; i<length; i++)
    {
        int index = arc4random_uniform((unsigned int)characters.length);
        NSString *character = [characters substringWithRange:NSMakeRange(index, 1)];
        [value appendString:character];
    }
    return [NSString stringWithString:value];
}

/**
 创建一个随机且不存在的相册目录
 
 @return 随机目录
 */
NSString* createRandomAlbumDirectory()
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *rootPath = photoRootDirectory();
    while (YES) {
        NSString *directory = randomString(10);
        NSString *path = [rootPath stringByAppendingPathComponent:directory];
        if (![fm fileExistsAtPath:path]) return directory;
    }
    return nil;
}

/**
 生成唯一标识的字符串(由当前时间加一个5位随机数组成)

 @return 唯一标识符
 */
NSString* generateUniquelyIdentifier()
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timestr = [formatter stringFromDate:[NSDate date]];
    NSString *result = [timestr stringByAppendingFormat:@"%05d", arc4random_uniform(100000)];
    return result;
}

/**
 是否开启TouchID功能
 
 @return YES:已启动TouchID, NO:未启用TouchID
 */
BOOL isEnableTouchID()
{
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:XPTouchEnableStateKey];
    if (!state) return NO;
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL isSupport = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return (isSupport && nil == error);
}

/**
 判断系统版本是否大于等于给定的版本
 
 @param majorVersion 主版本号
 @param minorVersion 次版本号
 @param patchVersion 补丁版本号
 @return BOOL
 */
BOOL isOperatingSystemAtLeastVersion(NSInteger majorVersion, NSInteger minorVersion, NSInteger patchVersion)
{
    NSOperatingSystemVersion version = {
                                        .majorVersion=majorVersion,
                                        .minorVersion=minorVersion,
                                        .patchVersion=patchVersion
                                        };
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    return [processInfo isOperatingSystemAtLeastVersion:version];
}


///////////////////////////
////        常量        ////
///////////////////////////

/// 密码
NSString * const XPPasswordKey                      = @"XPPasswordKey";
/// 密码随机字符
NSString * const XPEncryptionPasswordRandomKey      = @"XPEncryptionPasswordRandomKey";
/// 密码最小长度
NSInteger const XPPasswordMinimalLength             = 6;
/// TouchID是否启用
NSString * const XPTouchEnableStateKey              = @"XPTouchEnableStateKey";
/// 缩略图目录名称
NSString * const XPThumbDirectoryNameKey            = @"Thumb";
/// 生成的缩略图的宽高尺寸
CGFloat const XPThumbImageWidthAndHeightKey         = 100.0;



