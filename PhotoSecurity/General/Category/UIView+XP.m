//
//  UIView+XP.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/2.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "UIView+XP.h"

@implementation UIView (XP)

/**
 视图抖动效果
 */
- (void)shake {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.5;
    animation.values = @[
                         [NSValue valueWithCGPoint:self.center],
                         [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                         [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                         [NSValue valueWithCGPoint:self.center],
                         [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                         [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                         [NSValue valueWithCGPoint:self.center],
                         [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                         [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                         [NSValue valueWithCGPoint:self.center]
                         ];
    animation.keyTimes = @[@0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1.0];
    [self.layer addAnimation:animation forKey:nil];
}

@end


@implementation UIView (PCIBInspectable)

- (void)setBorderWidth:(CGFloat)borderWidth {
    [self.layer setBorderWidth:borderWidth];
}

- (CGFloat)borderWidth {
    return [self.layer borderWidth];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self.layer setBorderColor:borderColor.CGColor];
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderHexColor:(NSString *)borderHexColor {
    UIColor *color = [self colorWithHexString:borderHexColor];
    [self.layer setBorderColor:[color CGColor]];
}

- (NSString *)borderHexColor {
    return @"0xFFFFFF";
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    [self.layer setCornerRadius:cornerRadius];
}

- (CGFloat)cornerRadius {
    return [self.layer cornerRadius];
}

- (void)setHexBgColor:(NSString *)hexStr {
    UIColor *color = [self colorWithHexString:hexStr];
    [self setBackgroundColor:color];
}

- (NSString *)hexBgColor {
    return @"0xFFFFFF";
}

#pragma mark - Private

- (UIColor *)colorWithHexString:(NSString *)hexStr {
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

@end
