//
//  NSString+XP.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/3.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "NSString+XP.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XP)

/**
 去除字符串首尾的空白字符
 
 @return 过滤后的字符串
 */
- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 MD5加密
 
 @return 加密的字符串
 */
- (NSString *)md5 {
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

/**
 判断字符串是否为IP地址
 
 @return YES:合法的IP地址 NO:不是IP地址
 */
- (BOOL)isIP {
    if (nil == self || 0 == self.length) {
        return NO;
    }
    NSString *regexp = @"^(\\d{1,3}\\.){3}\\d{1,3}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];
    return [predicate evaluateWithObject:self];
}


@end
