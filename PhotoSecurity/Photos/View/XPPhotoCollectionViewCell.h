//
//  XPPhotoCollectionViewCell.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class XPPhotoCollectionViewCell;

@protocol XPPhotoCollectionViewCellDelegate <NSObject>

@optional

/**
 图片加载完毕的回调
 */
- (void)photoCollectionViewCell:(XPPhotoCollectionViewCell *)cell didRequestImage:(UIImage *)image atIndex:(NSInteger)index;

/**
 点击图片后的回调
 */
- (void)photoCollectionViewCell:(XPPhotoCollectionViewCell *)cell didTappedImageForSelected:(BOOL)isSelected atIndex:(NSInteger)index;

@end

@interface XPPhotoCollectionViewCell : UICollectionViewCell

/// 代理
@property (nonatomic, weak) id<XPPhotoCollectionViewCellDelegate> delegate;
/// 图片是否选中的状态
@property (nonatomic, assign, getter=isImageSelectedState) BOOL imageSelectedState;


/**
 根据资源去加载系统图片
 当图片加载完毕时会通过代理进行回调

 @param asset 资源
 @param index 索引
 */
- (void)requestImageWithAsset:(PHAsset *)asset index:(NSInteger)index;

/**
 显示图片

 @param image 待显示的图片
 @param index 索引
 */
- (void)showImage:(UIImage *)image index:(NSInteger)index;

@end
