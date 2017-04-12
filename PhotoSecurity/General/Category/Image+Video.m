//
//  Image+Video.m
//  
//
//  Created by nhope on 2017/4/12.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "Image+Video.h"
#import <AVFoundation/AVFoundation.h>

@implementation XP_IMAGE (Video)

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
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);
    image = [[NSImage alloc] initWithCGImage:imageRef
                                        size:NSMakeSize(width, height)];
#endif
    CGImageRelease(imageRef);
    return image;
}

@end
