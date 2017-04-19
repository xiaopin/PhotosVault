//
//  XPPhotoModel.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/16.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, XPFileType) {
    XPFileTypeImage         = 0, //普通图片
    XPFileTypeGIFImage      = 1, //GIF图片
    XPFileTypeVideo         = 2, //视频文件
};


@interface XPPhotoModel : NSObject

/// 照片id
@property (nonatomic, assign) NSInteger ID;
/// 所属相册id
@property (nonatomic, assign) NSInteger albumid;
/// 文件名称
@property (nonatomic, copy) NSString *filename;
/// 图片原始名称
@property (nonatomic, copy) NSString *originalname;
/// 图片创建时间
@property (nonatomic, assign) NSInteger createtime;
/// 图片添加时间
@property (nonatomic, assign) NSInteger addtime;
/// 图片大小
@property (nonatomic, assign) NSUInteger filesize;
/// 文件类型
@property (nonatomic, assign) XPFileType filetype;

@end
