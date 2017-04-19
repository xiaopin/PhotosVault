//
//  XPSQLiteManager.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/15.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPSQLiteManager.h"
#import "XPAlbumModel.h"
#import "XPPhotoModel.h"
#import <FMDB/FMDB.h>

@implementation XPSQLiteManager

#pragma mark - Public

+ (instancetype)sharedSQLiteManager {
    static XPSQLiteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

/**
 初始化数据库
 */
- (void)initializationDatabase {
    NSString *path = [self databaseFilePath];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (isExists) return;
    
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if ([db open] == NO) {
        return;
    }
    
    // 相册表
    NSString *sql =
    @"CREATE TABLE albums("
    "albumid INTEGER PRIMARY KEY AUTOINCREMENT,"// 相册ID
    "directory CHAR(20) NOT NULL," // 目录
    "name CHAR(32) NOT NULL," // 目录的显示名称
    "count INT NOT NULL," // 该目录下图片数
    "orderid INT NOT NULL" // 排序
    ");"
    // 图片表
    "CREATE TABLE photos("
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "albumid INTEGER NOT NULL DEFAULT 0," // 所属相册ID
    "filename CHAR(50) NOT NULL DEFAULT \"\"," // 本地的图片/视频名称
    "originalname CHAR(50) DEFAULT \"\"," // 原始名称
    "addtime INTEGER NOT NULL DEFAULT 0," // 添加时间
    "createtime INTEGER NOT NULL DEFAULT 0," // 图片创建时间
    "filesize INTEGER NOT NULL DEFAULT 0," // 图片内容大小
    "filetype TINYINT NOT NULL DEFAULT 0" // 文件类型, 0:普通图片 1:GIF图片 2:视频
    ");";
    
    [db executeStatements:sql];
    [db close];
}

/**
 获取用户的所有相册数据
 
 @return 相册数组
 */
- (NSMutableArray<XPAlbumModel *> *)requestUserAlbums {
    NSMutableArray *albums = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return albums;
    FMResultSet *set = [db executeQuery:@"SELECT * FROM albums ORDER BY orderid ASC"];
    albums = [self albumsWithResultSet:set];
    
    for (XPAlbumModel *album in albums) {
        // 获取相册下最新添加的图片作为相册缩略图
        if (0 == album.count) continue;
        FMResultSet *thumbSet = [db executeQuery:@"SELECT * FROM photos WHERE albumid = ? ORDER BY id DESC LIMIT 1", @(album.albumid)];
        XPPhotoModel *thumbPhoto = [[self photosWithResultSet:thumbSet] firstObject];
        album.thumbImage = thumbPhoto;
    }
    
    [db close];
    return albums;
}

/**
 创建一个新相册
 
 @param name 相册名称
 @return 新创建的相册
 */
- (XPAlbumModel *)createAlbumWithName:(NSString *)name {
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return nil;
    NSString *directory = createRandomAlbumDirectory();
    // 获取目前最大的排序id
    int maxid = 0;
    FMResultSet *set = [db executeQuery:@"SELECT max(orderid) as maxid FROM albums"];
    while ([set next]) {
        maxid = [set intForColumn:@"maxid"]+1;
        break;
    }
    BOOL success = [db executeUpdate:@"INSERT INTO albums(directory,name,count,orderid) VALUES(?,?,0,?)", directory,name,@(maxid)];
    XPAlbumModel *album = nil;
    if (success) {
        // 创建相册目录文件夹
        NSString *path = [[photoRootDirectory() stringByAppendingPathComponent:directory] stringByAppendingPathComponent:XPThumbDirectoryNameKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        // 获取新创建的相册并返回给调用者
        FMResultSet *set = [db executeQuery:@"SELECT * FROM albums ORDER BY albumid DESC LIMIT 1"];
        album = [[self albumsWithResultSet:set] firstObject];
    }
    [db close];
    return album;
}

/**
 删除相册(会将该相册下的所有图片一并删除)
 
 @param album 相册信息
 @return 是否删除成功
 */
- (BOOL)deleteAlbumWithAlbum:(XPAlbumModel *)album{
    if (nil == album) return NO;
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return NO;
    BOOL success = [db executeUpdate:@"DELETE FROM albums WHERE albumid=?",@(album.albumid)];
    if (success) {
        // 删除相册目录以及图片
        NSString *path = [photoRootDirectory() stringByAppendingPathComponent:album.directory];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        // 移除数据库中的图片记录
        [db executeUpdate:@"DELETE FROM photos WHERE albumid=?",@(album.albumid)];
    }
    [db close];
    return success;
}

/**
 对相册进行重新排序
 
 @param sortAlbums 待排序的相册数组(将根据索引进行排序)
 */
- (BOOL)resortAlbums:(NSArray<XPAlbumModel *> *)sortAlbums {
    if (0 == sortAlbums.count) return NO;
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return NO;
    [db beginTransaction];
    [sortAlbums enumerateObjectsUsingBlock:^(XPAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [db executeUpdate:@"UPDATE albums SET orderid = ? WHERE albumid = ?", @(idx+1),@(obj.albumid)];
    }];
    [db commit];
    [db close];
    return YES;
}





/**
 保存图片信息
 
 @param photos 图片信息数组
 @return BOOL
 */
- (BOOL)addPhotos:(NSArray<XPPhotoModel *> *)photos {
    if (0 == photos.count) return NO;
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return NO;
    NSMutableString *sql = [NSMutableString stringWithString:@"INSERT INTO photos(albumid,filename,originalname,addtime,createtime,filesize,filetype) VALUES"];
    for (XPPhotoModel *photo in photos) {
        [sql appendFormat:@"(%ld, \"%@\", \"%@\", %ld, %ld, %ld, %ld),",
                        photo.albumid, photo.filename, photo.originalname,
                        photo.addtime, photo.createtime, photo.filesize, photo.filetype];
    }
    BOOL success = [db executeUpdate:[sql substringToIndex:sql.length-1]];
    if (success) {
        [db executeUpdate:@"UPDATE albums SET count=count+? WHERE albumid=?", @(photos.count),@(photos.firstObject.albumid)];
    }
    [db close];
    return success;
}

/**
 加载指定相册下的图片数据
 
 @param albumid 相册id
 @param page 页码
 @param pagesize 分页大小
 @return 指定页码对应的图片数据
 */
- (NSMutableArray<XPPhotoModel *> *)requestPhotosWithAlbumid:(NSInteger)albumid page:(NSInteger)page pagesize:(NSInteger)pagesize {
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return nil;
    FMResultSet *set = [db executeQuery:@"SELECT * FROM photos WHERE albumid=? LIMIT ? OFFSET ?", @(albumid),@(pagesize),@(MAX(0, page-1)*pagesize)];
    NSMutableArray<XPPhotoModel *> *photos = [self photosWithResultSet:set];
    [db close];
    return photos;
}

/**
 加载指定相册下的所有图片数据(限定10k张图片之内)
 
 @param albumid 相册id
 @return 该相册下的所有图片数据
 */
- (NSMutableArray<XPPhotoModel *> *)requestAllPhotosWithAlbumid:(NSInteger)albumid {
    return [self requestPhotosWithAlbumid:albumid page:1 pagesize:10000];
}

/**
 获取指定相册下最新添加的N张图片信息
 
 @param albumid 相册id
 @param count 图片数量
 @return 多张图片信息
 */
- (NSArray<XPPhotoModel *> *)requestLatestPhotosWithAlbumid:(NSInteger)albumid count:(NSInteger)count {
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return nil;
    FMResultSet *set = [db executeQuery:@"SELECT * FROM photos WHERE albumid=? ORDER BY id DESC LIMIT ?", @(albumid),@(count)];
    NSMutableArray<XPPhotoModel *> *photos = [self photosWithResultSet:set];
    [db close];
    return [[photos reverseObjectEnumerator] allObjects];
}

/**
 删除某个相册下指定的图片
 
 @param photos 待删除的图片数据
 @param album 相册
 @return 成功删除图片的个数
 */
- (NSUInteger)deletePhotos:(NSArray<XPPhotoModel *> *)photos fromAlbum:(XPAlbumModel *)album {
    if (0 == photos.count || nil == album) return 0;
    FMDatabase *db = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![db open]) return 0;
    NSMutableArray<XPPhotoModel *> *removePhotos = [NSMutableArray array];
    // 开启事务,删除数据库中图片的数据
    [db beginTransaction];
    for (XPPhotoModel *photo in photos) {
        BOOL success = [db executeUpdate:@"DELETE FROM photos WHERE id = ? AND albumid = ?", @(photo.ID), @(album.albumid)];
        if (success) {
            [removePhotos addObject:photo];
        }
    }
    [db executeUpdate:@"UPDATE albums SET count=count-? WHERE albumid=?", @(removePhotos.count), @(album.albumid)];
    [db commit];
    [db close];
    
    // 删除本地图片文件
    NSFileManager *fm = [NSFileManager defaultManager];
    for (XPPhotoModel *photo in removePhotos) {
        NSString *file = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),album.directory,photo.filename];
        NSString *thumbFile = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),album.directory,XPThumbDirectoryNameKey,photo.filename];
        [fm removeItemAtPath:file error:nil];
        [fm removeItemAtPath:thumbFile error:nil];
    }
    
    return removePhotos.count;
}


#pragma mark - Private

/**
 数据库文件路径
 */
- (NSString *)databaseFilePath {
    NSString *filename = @"PhotoSecurity.sqlite";
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [document stringByAppendingPathComponent:filename];
}

/**
 将sqlite的查询结果转成XPAlbumModel模型对象

 @param set sqlite查询结果集
 @return 相册模型数组
 */
- (NSMutableArray<XPAlbumModel *> *)albumsWithResultSet:(FMResultSet *)set {
    NSMutableArray<XPAlbumModel *> *albums = [NSMutableArray array];
    while ([set next]) {
        XPAlbumModel *album = [[XPAlbumModel alloc] init];
        album.albumid     = [set longForColumn:@"albumid"];
        album.directory = [set stringForColumn:@"directory"];
        album.name      = [set stringForColumn:@"name"];
        album.count     = [set intForColumn:@"count"];
        album.orderid   = [set intForColumn:@"orderid"];
        [albums addObject:album];
    }
    return albums;
}

/**
 将sqlite的查询结果转换成XPPhotoModel模型对象

 @param set sqlite查询结果集
 @return 图片模型数组
 */
- (NSMutableArray<XPPhotoModel *> *)photosWithResultSet:(FMResultSet *)set {
    NSMutableArray<XPPhotoModel *> *photos = [NSMutableArray array];
    while ([set next]) {
        XPPhotoModel *photo = [[XPPhotoModel alloc] init];
        photo.ID = [set longForColumn:@"id"];
        photo.albumid = [set longForColumn:@"albumid"];
        photo.filename = [set stringForColumn:@"filename"];
        photo.originalname = [set stringForColumn:@"originalname"];
        photo.addtime = [set longForColumn:@"addtime"];
        photo.createtime = [set longForColumn:@"createtime"];
        photo.filesize = [set longForColumn:@"filesize"];
        photo.filetype = [set intForColumn:@"filetype"];
        [photos addObject:photo];
    }
    return photos;
}

@end
