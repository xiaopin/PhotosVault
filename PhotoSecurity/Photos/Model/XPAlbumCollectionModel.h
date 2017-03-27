//
//  XPAlbumCollectionModel.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface XPAlbumCollectionModel : NSObject

/// 相册
@property (nonatomic, strong) PHAssetCollection *albumCollection;
/// 该相册下图片资源数量
@property (nonatomic, assign, readonly) NSUInteger assetCounts;
/// 相册下的图片资源数据
//@property (nonatomic, strong) PHFetchResult<PHAsset *> *assetResult;

- (PHFetchResult<PHAsset *> *)fetchAssetsWithptions:(PHFetchOptions *)options;

@end
