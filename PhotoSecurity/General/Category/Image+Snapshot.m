//
//  Image+Video.m
//  
//
//  Created by nhope on 2017/4/12.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "Image+Snapshot.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@implementation XP_IMAGE (Snapshot)

/**
 从视频文件中提取缩略图
 
 @param videoURL 本地视频文件URL
 @return 视频缩略图
 */
+ (instancetype)snapshotImageWithVideoURL:(NSURL *)videoURL {
    if (![videoURL isFileURL]) {
        return nil;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero
                                                 actualTime:NULL
                                                      error:nil];
    XP_IMAGE *image = nil;
#if TARGET_OS_IPHONE || TARGET_OS_TV
    image = [[UIImage alloc] initWithCGImage:imageRef];
#elif TARGET_OS_MAC
    NSSize size = NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    image = [[NSImage alloc] initWithCGImage:imageRef size:size];
#endif
    CGImageRelease(imageRef);
    return image;
}

/**
 从GIF图片中提取第一帧作为缩略图
 
 @param gifURL 本地GIF文件URL
 @return 缩略图
 */
+ (instancetype)snapshotImageWithGIFImageURL:(NSURL *)gifURL {
    if (![gifURL isFileURL]) {
        return nil;
    }
    CFURLRef urlRef = (__bridge CFURLRef)gifURL;
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL(urlRef, NULL);
    if (0 == CGImageSourceGetCount(sourceRef)) { // empty gif file.
        return nil;
    }
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, NULL);
    XP_IMAGE *image = nil;
#if TARGET_OS_IPHONE || TARGET_OS_TV
    image = [[UIImage alloc] initWithCGImage:imageRef];
#elif TARGET_OS_MAC
    NSSize size = NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    image = [[NSImage alloc] initWithCGImage:imageRef size:size];
#endif
    CGImageRelease(imageRef);
    return image;
}

@end
