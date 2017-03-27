//
//  XPPhotoCollectionViewCell.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPPhotoCollectionViewCell.h"
#import <Photos/Photos.h>

@interface XPPhotoCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *stateImageView;
@property (nonatomic, strong) UIView *selectedMaskView;

@property (nonatomic, assign) PHImageRequestID requestID;

@end

@implementation XPPhotoCollectionViewCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUserInterface];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (_requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_requestID];
        _requestID = PHInvalidImageRequestID;
    }
    [self setImageSelectedState:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat stateWH = 20.0;
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    _imageView.frame = self.contentView.bounds;
    _selectedMaskView.frame = self.contentView.bounds;
    _stateImageView.frame = CGRectMake(width-stateWH-5.0,
                                       height-stateWH-5.0,
                                       stateWH, stateWH);
}

#pragma mark - Actions

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)sender {
    BOOL isSelected = !self.imageSelectedState;
//    [self setImageSelectedState:isSelected];
    if ([self.delegate respondsToSelector:@selector(photoCollectionViewCell:didTappedImageForSelected:atIndex:)]) {
        [self.delegate photoCollectionViewCell:self didTappedImageForSelected:isSelected atIndex:self.imageView.tag];
    }
}

#pragma mark - Public

- (void)requestImageWithAsset:(PHAsset *)asset index:(NSInteger)index {
    self.imageView.tag = index;
    @weakify(self);
//    PHImageManagerMaximumSize
//    CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(self.contentView.frame.size.width*scale, self.contentView.frame.size.height*scale);
    _requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        @strongify(self);
        if (self.imageView.tag != index) return; // Cell重用
        self.imageView.image = result;
        self.requestID = PHInvalidImageRequestID;
        if ([self.delegate respondsToSelector:@selector(photoCollectionViewCell:didRequestImage:atIndex:)]) {
            [self.delegate photoCollectionViewCell:self didRequestImage:result atIndex:self.imageView.tag];
        }
    }];
}

- (void)showImage:(UIImage *)image index:(NSInteger)index {
    if (_requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_requestID];
        _requestID = PHInvalidImageRequestID;
    }
    self.imageView.tag = index;
    _imageView.image = image;
}

#pragma mark - Private

- (void)configureUserInterface {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_imageView];
    
    _selectedMaskView = [[UIView alloc] init];
    _selectedMaskView.backgroundColor = [[UIColor colorWithR:223.0 g:223.0 b:223.0] colorWithAlphaComponent:0.3];
    [self.contentView addSubview:_selectedMaskView];
    
    _stateImageView = [[UIImageView alloc] init];
    _stateImageView.image = [UIImage imageNamed:@"icon-selected"];
    [self.contentView addSubview:_stateImageView];
    
    SEL action = @selector(tapGestureRecognizerAction:);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [self addGestureRecognizer:tap];
    [self setImageSelectedState:NO];
}

#pragma mark - setter&getter

- (void)setImageSelectedState:(BOOL)imageSelectedState {
    _imageSelectedState = imageSelectedState;
    _selectedMaskView.hidden = !imageSelectedState;
    _stateImageView.hidden = !imageSelectedState;
}

@end
