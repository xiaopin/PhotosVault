//
//  XPAlbumDetailCell.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/16.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPAlbumModel;
@class XPPhotoModel;

@interface XPAlbumDetailCell : UICollectionViewCell

- (void)showImageWithAlbum:(XPAlbumModel *)album photo:(XPPhotoModel *)photo;
- (void)changeSelectState:(BOOL)select;

@end
