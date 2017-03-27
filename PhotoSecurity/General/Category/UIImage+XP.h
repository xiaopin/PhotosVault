//
//  UIImage+XP.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XP)

/**
 将UIColor转换为UIImage且大小为1x1

 @param color 图片颜色
 @return UIImage
 */
+ (instancetype)imageWithColor:(UIColor *)color;

/**
 将UIColor转换为UIImage并指定大小

 @param color 图片颜色
 @param size 图片大小
 @return UIImage
 */
+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 通过视图获取视图快照

 @param view 需要生成快照的视图
 @return 快照图片
 */
+ (instancetype)snapshotImageWithView:(UIView *)view;

/**
 旋转图片

 @param angle 旋转角度
 @return 旋转后的图片
 */
- (UIImage *)imageRotationWithAngle:(CGFloat)angle;

/**
 绘制一个圆形的下标图片
 
 @param imageSize 图片大小
 @param backgoundColor 图片背景色
 @param subscript 下脚标
 @param fontSize 字体大小
 @param textColor 字体颜色
 @return 绘制的下脚标图片
 */
+ (instancetype)roundSubscriptImageWithImageSize:(CGSize)imageSize backgoundColor:(UIColor *)backgoundColor subscript:(NSUInteger)subscript fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor;

/**
 根据图片生成指定大小的缩略图

 @param sourceImage 原始图片
 @param destinationSize 缩略图尺寸
 @return 缩略图
 */
+ (instancetype)thumbnailImageFromSourceImage:(UIImage *)sourceImage destinationSize:(CGSize)destinationSize;

/**
 根据图片二进制数据生成指定大小的缩略图

 @param imageData 原始图片数据
 @param destinationSize 缩略图尺寸
 @return 缩略图
 */
+ (instancetype)thumbnailImageFromSourceImageData:(NSData *)imageData destinationSize:(CGSize)destinationSize;

@end
