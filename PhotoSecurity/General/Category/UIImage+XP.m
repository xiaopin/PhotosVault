//
//  UIImage+XP.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "UIImage+XP.h"

@implementation UIImage (XP)

/**
 将UIColor转换为UIImage且大小为1x1
 
 @param color 图片颜色
 @return UIImage
 */
+ (instancetype)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0, 1.0)];
}

/**
 将UIColor转换为UIImage并指定大小
 
 @param color 图片颜色
 @param size 图片大小
 @return UIImage
 */
+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = (CGRect){CGPointZero, size};
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 通过视图获取视图快照
 
 @param view 需要生成快照的视图
 @return 快照图片
 */
+ (instancetype)snapshotImageWithView:(UIView *)view {
    if (nil == view) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 旋转图片
 
 @param angle 旋转角度
 @return 旋转后的图片
 */
- (UIImage *)imageRotationWithAngle:(CGFloat)angle {
    CGRect rect = (CGRect){CGPointMake(-self.size.width/2, -self.size.height/2), self.size};
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, rect.size.width/2, rect.size.height/2);
    CGContextRotateCTM(ctx, angle/180.0*M_PI);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawImage(ctx, rect, [self CGImage]);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 绘制一个圆形的下标图片

 @param imageSize 图片大小
 @param backgoundColor 图片背景色
 @param subscript 下脚标
 @param fontSize 字体大小
 @param textColor 字体颜色
 @return 绘制的下脚标图片
 */
+ (instancetype)roundSubscriptImageWithImageSize:(CGSize)imageSize backgoundColor:(UIColor *)backgoundColor subscript:(NSUInteger)subscript fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    // draw background
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [backgoundColor CGColor]);
    CGContextFillEllipseInRect(context, (CGRect){CGPointZero, imageSize});
    
    // draw text
    NSString *text = [NSString stringWithFormat:@"%ld",subscript];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize textSize = [text boundingRectWithSize:imageSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
    CGRect drawRect = CGRectMake((imageSize.width-textSize.width)/2, (imageSize.height-textSize.height)/2, textSize.width, textSize.height);
    [text drawInRect:drawRect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:textColor}];
    
    // get image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 根据图片生成指定大小的缩略图
 
 @param sourceImage 原始图片
 @param destinationSize 缩略图尺寸
 @return 缩略图
 */
+ (instancetype)thumbnailImageFromSourceImage:(UIImage *)sourceImage destinationSize:(CGSize)destinationSize {
    CGRect rect = CGRectMake(0, 0, destinationSize.width, destinationSize.height);
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(destinationSize, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGFloat ratio = MAX(rect.size.width/sourceImage.size.width, rect.size.height/sourceImage.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path addClip];
    
    CGSize clipSize = CGSizeMake(sourceImage.size.width*ratio, sourceImage.size.height*ratio);
    CGRect clipRect = CGRectMake((rect.size.width-clipSize.width)*0.5,
                                 (rect.size.height-clipSize.height)*0.5,
                                 clipSize.width, clipSize.height);
    [sourceImage drawInRect:clipRect];
    UIImage *thumbImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbImage;
}

/**
 根据图片二进制数据生成指定大小的缩略图
 
 @param imageData 原始图片数据
 @param destinationSize 缩略图尺寸
 @return 缩略图
 */
+ (instancetype)thumbnailImageFromSourceImageData:(NSData *)imageData destinationSize:(CGSize)destinationSize {
    UIImage *image = [UIImage imageWithData:imageData];
    return [self thumbnailImageFromSourceImage:image destinationSize:destinationSize];
}

@end
