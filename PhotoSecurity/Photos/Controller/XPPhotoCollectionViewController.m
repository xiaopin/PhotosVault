//
//  XPPhotoCollectionViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPPhotoCollectionViewController.h"
#import "XPPhotoCollectionViewCell.h"
#import "XPAlbumCollectionModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface XPPhotoCollectionViewController ()<DZNEmptyDataSetSource, XPPhotoCollectionViewCellDelegate>

/// 图片资源数据
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assetResults;
/// 图片缓存
@property (nonatomic, strong) NSMutableDictionary<NSString*, UIImage*> *imageMaps;
/// 当前选中的图片索引
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedAssets;

@end

@implementation XPPhotoCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - Lifecycle

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.album.albumCollection.localizedTitle;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[XPPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.emptyDataSetSource = self;
    UIImage *image = [UIImage roundSubscriptImageWithImageSize:CGSizeMake(25.0, 25.0)
                                                backgoundColor:[UIColor colorWithHex:@"0xC2E4C4"]
                                                     subscript:0
                                                      fontSize:14.0
                                                     textColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 清空缓存
    [_imageMaps removeAllObjects];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XPPhotoCollectionViewCell *cell = (XPPhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XPPhotoCollectionViewCell *photoCell = (XPPhotoCollectionViewCell *)cell;
    NSString *key = [NSString stringWithFormat:@"%ld", indexPath.item];
    UIImage *image = self.imageMaps[key];
    PHAsset *asset = [self.assetResults objectAtIndex:indexPath.row];
    if (image) { // 直接使用缓存图片
        [photoCell showImage:image index:indexPath.row];
    } else { // 加载图片
        [photoCell requestImageWithAsset:asset index:indexPath.row];
    }
    photoCell.imageSelectedState = [self.selectedAssets containsObject:asset];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame);
    int maxItemCount = ceil(width/100.0); // item最大尺寸为(100.0,100.0)
    CGFloat wh = (width-(maxItemCount-1))/maxItemCount;
    return CGSizeMake(wh, wh);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

#pragma mark - <XPPhotoCollectionViewCellDelegate>

- (void)photoCollectionViewCell:(XPPhotoCollectionViewCell *)cell didRequestImage:(UIImage *)image atIndex:(NSInteger)index {
    if (nil == image) return;
    NSString *key = [NSString stringWithFormat:@"%ld", index];
    if (nil == self.imageMaps) {
        self.imageMaps = [NSMutableDictionary dictionary];
    }
    [self.imageMaps setObject:image forKey:key];
}

- (void)photoCollectionViewCell:(XPPhotoCollectionViewCell *)cell didTappedImageForSelected:(BOOL)isSelected atIndex:(NSInteger)index {
    if (nil == self.selectedAssets) {
        self.selectedAssets = [NSMutableArray array];
    }
    PHAsset *asset = [self.assetResults objectAtIndex:index];
    if (isSelected) {
        if (9 <= self.selectedAssets.count) {
            [XPProgressHUD showToast:NSLocalizedString(@"You can only select up to 9 images.", nil)];
            return;
        }
        [self.selectedAssets addObject:asset];
    } else {
        [self.selectedAssets removeObject:asset];
    }
    [cell setImageSelectedState:isSelected];
    
    // 更新右上角的图标
    NSUInteger count = self.selectedAssets.count;
    UIImage *image = [UIImage roundSubscriptImageWithImageSize:CGSizeMake(25.0, 25.0)
                                                backgoundColor:[UIColor colorWithHex:(count==0)?@"0xC2E4C4":@"0x38BD20"]
                                                     subscript:count
                                                      fontSize:14.0
                                                     textColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem.enabled = (count>0);
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"No photo or video", nil);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty-box"];
}

#pragma mark - Actions

/**
 右上角完成选择按钮的点击事件
 */
- (void)doneButtonAction:(UIBarButtonItem *)sender {
    if (nil != self.didSelectAssetsCompletionHandler) {
        NSArray<PHAsset *> *assets = [NSArray arrayWithArray:self.selectedAssets];
        self.didSelectAssetsCompletionHandler(assets);
    }
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setter & getter

- (PHFetchResult<PHAsset *> *)assetResults {
    if (nil == _assetResults) {
        _assetResults = [self.album fetchAssetsWithptions:nil];
    }
    return _assetResults;
}


@end
