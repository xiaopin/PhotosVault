//
//  XPAlbumCollectionModel.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPAlbumCollectionModel.h"

@implementation XPAlbumCollectionModel

- (PHFetchResult<PHAsset *> *)fetchAssetsWithptions:(PHFetchOptions *)options {
    if (nil == self.albumCollection) return nil;
    return [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:options];
}

- (void)setAlbumCollection:(PHAssetCollection *)albumCollection {
    _albumCollection = albumCollection;
    _assetCounts = [self fetchAssetsWithptions:nil].count;
}

@end
