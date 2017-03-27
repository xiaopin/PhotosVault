//
//  XPAlbumDetailCell.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/16.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPAlbumDetailCell.h"
#import "XPAlbumModel.h"
#import "XPPhotoModel.h"

@interface XPAlbumDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *selectMaskView;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;

@end

@implementation XPAlbumDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectMaskView.backgroundColor = [[UIColor colorWithR:223.0 g:223.0 b:223.0] colorWithAlphaComponent:0.3];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.stateImageView.hidden = YES;
    self.selectMaskView.hidden = YES;
}

- (void)showImageWithAlbum:(XPAlbumModel *)album photo:(XPPhotoModel *)photo {
    // 加载并显示缩略图,节省内存
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),album.directory,XPThumbDirectoryNameKey,photo.filename];
    self.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
}

- (void)changeSelectState:(BOOL)select {
    self.stateImageView.hidden = !select;
    self.selectMaskView.hidden = !select;
}

@end
