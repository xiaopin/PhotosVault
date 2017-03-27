//
//  XPPhotoPickerViewController.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPPhotoPickerViewController;
@class PHAsset;


@protocol XPPhotoPickerViewControllerDelegate <NSObject>

@optional

/**
 取消选择图片
 */
- (void)photoPickerViewControllerDidCalcel:(XPPhotoPickerViewController *)picker;

/**
 图片选择后的回调

 @param picker XPPhotoPickerViewController
 @param assets 选中的图片资源
 */
- (void)photoPickerViewController:(XPPhotoPickerViewController *)picker didSelectedAssets:(NSArray<PHAsset *> *)assets;

@end


@interface XPPhotoPickerViewController : UITableViewController

@property (nonatomic, weak) id<XPPhotoPickerViewControllerDelegate> delegate;

@end
