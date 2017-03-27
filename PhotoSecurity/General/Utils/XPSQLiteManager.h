//
//  XPSQLiteManager.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/15.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XPAlbumModel;
@class XPPhotoModel;

@interface XPSQLiteManager : NSObject

/**
 单例
 */
+ (instancetype)sharedSQLiteManager;

/**
 初始化数据库
 */
- (void)initializationDatabase;

/**
 获取用户的所有相册数据
 
 @return 相册数组
 */
- (NSMutableArray<XPAlbumModel *> *)requestUserAlbums;

/**
 创建一个新相册

 @param name 相册名称
 @return 新创建的相册
 */
- (XPAlbumModel *)createAlbumWithName:(NSString *)name;

/**
 删除相册(会将该相册下的所有图片一并删除)

 @param album 相册信息
 @return 是否删除成功
 */
- (BOOL)deleteAlbumWithAlbum:(XPAlbumModel *)album;

/**
 对相册进行重新排序

 @param sortAlbums 待排序的相册数组(将根据索引进行排序)
 */
- (BOOL)resortAlbums:(NSArray<XPAlbumModel *> *)sortAlbums;



/**
 保存图片信息

 @param photos 图片信息数组
 @return BOOL
 */
- (BOOL)addPhotos:(NSArray<XPPhotoModel *> *)photos;

/**
 加载指定相册下的图片数据

 @param albumid 相册id
 @param page 页码
 @param pagesize 分页大小
 @return 指定页码对应的图片数据
 */
- (NSMutableArray<XPPhotoModel *> *)requestPhotosWithAlbumid:(NSInteger)albumid page:(NSInteger)page pagesize:(NSInteger)pagesize;

/**
 加载指定相册下的所有图片数据(限定10k张图片之内)

 @param albumid 相册id
 @return 该相册下的所有图片数据
 */
- (NSMutableArray<XPPhotoModel *> *)requestAllPhotosWithAlbumid:(NSInteger)albumid;

/**
 获取指定相册下最新添加的N张图片信息

 @param albumid 相册id
 @param count 图片数量
 @return 多张图片信息
 */
- (NSArray<XPPhotoModel *> *)requestLatestPhotosWithAlbumid:(NSInteger)albumid count:(NSInteger)count;

/**
 删除某个相册下指定的图片

 @param photos 待删除的图片数据
 @param album 相册
 @return 成功删除图片的个数
 */
- (NSUInteger)deletePhotos:(NSArray<XPPhotoModel *> *)photos fromAlbum:(XPAlbumModel *)album;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
