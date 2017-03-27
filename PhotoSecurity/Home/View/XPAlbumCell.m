//
//  XPAlbumCell.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/24.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPAlbumCell.h"
#import "XPAlbumModel.h"
#import "XPPhotoModel.h"

@interface XPAlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation XPAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureWithAlbum:(XPAlbumModel *)album {
    UIImage *image = nil;
    if (album.count && album.thumbImage) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),album.directory,XPThumbDirectoryNameKey,album.thumbImage.filename];
        image = [[UIImage alloc] initWithContentsOfFile:path];
    }
    self.nameLabel.text = album.name;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", album.count];
    self.thumbImageView.image = image ?: [UIImage imageNamed:@"album-placeholder"];
}

@end
