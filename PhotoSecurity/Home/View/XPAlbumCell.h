//
//  XPAlbumCell.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/24.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPAlbumModel;

@interface XPAlbumCell : UITableViewCell

- (void)configureWithAlbum:(XPAlbumModel *)album;

@end
