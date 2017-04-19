//
//  XPAlbumDetailViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/8.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPAlbumDetailViewController.h"
#import "XPPhotoPickerViewController.h"
#import "XPNavigationController.h"
#import "XPAlbumDetailCell.h"
#import "XPAlbumModel.h"
#import "XPPhotoModel.h"
#import <Photos/Photos.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <AVFoundation/AVFoundation.h>
#import <QuickLook/QuickLook.h>
#import <MobileCoreServices/MobileCoreServices.h>


#define OPERATION_TOOLBAR_TAG                   999
#define OPERATION_TOOLBAR_HEIGHT                49.0
#define OPERATION_TOOLBAR_INDICATOR_ITEM_TAG    123


@interface XPAlbumDetailViewController ()
<DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate,
XPPhotoPickerViewControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate>

/// 该相册下的图片数据
@property (nonatomic, strong) NSMutableArray<XPPhotoModel *> *photos;
/// 是否处于编辑模式
@property (nonatomic, assign) BOOL editing;
/// 选中列表(key为下标索引,value固定为@(YES))
@property (nonatomic, strong) NSMutableDictionary *selectMaps;

@end

@implementation XPAlbumDetailViewController

static CGFloat const kCellBorderMargin = 1.0;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.album.name;
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    // 加载相册所有图片数据
    XPSQLiteManager *manager = [XPSQLiteManager sharedSQLiteManager];
    self.photos = [manager requestAllPhotosWithAlbumid:self.album.albumid];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColor];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XPPhotoModel *photo = self.photos[indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld", indexPath.row];
    BOOL isSelect = _editing && ([_selectMaps objectForKey:key] ? YES : NO);
    XPAlbumDetailCell *photoCell = (XPAlbumDetailCell *)cell;
    [photoCell showImageWithAlbum:self.album photo:photo];
    [photoCell changeSelectState:isSelect];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (_editing) {
        NSString *key = [NSString stringWithFormat:@"%ld", indexPath.row];
        if (nil == _selectMaps) _selectMaps = [NSMutableDictionary dictionary];
        BOOL isExists = [_selectMaps objectForKey:key] ? YES : NO;
        XPAlbumDetailCell *cell = (XPAlbumDetailCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (isExists) {
            [_selectMaps removeObjectForKey:key];
            [cell changeSelectState:NO];
        } else {
            if (9 <= _selectMaps.count) {
                [XPProgressHUD showToast:NSLocalizedString(@"You can only select up to 9 images.", nil)];
                return;
            }
            [_selectMaps setObject:@(YES) forKey:key];
            [cell changeSelectState:YES];
        }
        [self updateToolbarIndicator];
    } else {
        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.delegate = self;
        previewController.dataSource = self;
        previewController.currentPreviewItemIndex = indexPath.row;
        [self.navigationController pushViewController:previewController animated:YES];
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame);
    int maxItemCount = ceil(width/XPThumbImageWidthAndHeightKey);
    CGFloat wh = (width-(maxItemCount-1)*kCellBorderMargin)/maxItemCount;
    return CGSizeMake(wh, wh);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellBorderMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCellBorderMargin;
}

#pragma mark - <QLPreviewControllerDataSource>

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.photos.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    XPPhotoModel *photo = self.photos[index];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,photo.filename];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}


#pragma mark - <XPPhotoPickerViewControllerDelegate>

- (void)photoPickerViewController:(XPPhotoPickerViewController *)picker didSelectedAssets:(NSArray<PHAsset *> *)assets {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [XPProgressHUD showLoadingHUD:NSLocalizedString(@"Copying the pictures...", nil) toView:window];
    
    @weakify(self);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.0daybug.globalqueue", DISPATCH_QUEUE_CONCURRENT);
    __block NSMutableArray<XPPhotoModel *> *photos = [NSMutableArray array];
    // 从系统中拷贝图片/视频到沙盒目录
    for (PHAsset *asset in assets) {
        if (asset.mediaType == PHAssetMediaTypeUnknown || asset.mediaType == PHAssetMediaTypeAudio) continue;
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            @strongify(self);
            if (asset.mediaType == PHAssetMediaTypeVideo) { // 视频
                [self fetchVideoForPHAsset:asset completionHandler:^(XPPhotoModel *photo) {
                    [photos addObject:photo];
                    dispatch_group_leave(group);
                }];
            } else if (asset.mediaType == PHAssetMediaTypeImage) { // 图片
                [self fetchImageForPHAsset:asset completionHandler:^(XPPhotoModel *photo) {
                    [photos addObject:photo];
                    dispatch_group_leave(group);
                }];
            }
        });
    }
    // 所有图片/视频已拷贝完毕
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [[XPSQLiteManager sharedSQLiteManager] addPhotos:photos]; // 将图片数据写入数据库
            self.album.count += photos.count;
            [XPProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
            
            // 获取允许删除的图片资源
            NSMutableArray<PHAsset *> *deleteAssets = [NSMutableArray array];
            for (PHAsset *asset in assets) {
                if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
                    [deleteAssets addObject:asset];
                }
            }
            if (deleteAssets.count) {
                // 提示用户是否删除系统图片
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Whether to delete the selected image from the photo library?", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        /**
                         删除图片注意点:
                         1、图片将会被移入"最近删除"的相册中,30天后会自动删除
                         2、不能删除通过iTunes同步的图片,[asset canPerformEditOperation:PHAssetEditOperationDelete]可判断图片是否可以删除
                         
                         针对情况1可以先将图片修改成一个默认图片然后才删除,情况二就无解了,苹果不允许这种操作,只能通过iTunes取消同步来删除
                         */
                        [PHAssetChangeRequest deleteAssets:deleteAssets];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (success == NO) {
                            NSString *message = NSLocalizedString(@"Delete fail.", nil);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [XPProgressHUD showFailureHUD:message toView:[UIApplication sharedApplication].keyWindow];
                            });
                        }
                    }];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            // 加载最新添加的图片信息并显示在最后
            NSArray *latestPhotos = [[XPSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:photos.count];
            if (nil == self.photos) {
                self.photos = [NSMutableArray array];
            }
            [self.photos addObjectsFromArray:latestPhotos];
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *data = nil;
    NSString *filename = nil;
    UIImage *previewImage = nil;
    XPFileType filetype = XPFileTypeImage;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    CGSize size = CGSizeMake(XPThumbImageWidthAndHeightKey, XPThumbImageWidthAndHeightKey);
    if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) { // 视频
        NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
        data = [NSData dataWithContentsOfURL:mediaURL];
        filename = [NSString stringWithFormat:@"%@.%@", generateUniquelyIdentifier(),mediaURL.pathExtension];
        previewImage = [UIImage snapshotImageWithVideoURL:mediaURL];
        previewImage = [UIImage thumbnailImageFromSourceImage:previewImage destinationSize:size];
        filetype = XPFileTypeVideo;
    } else { // 拍照
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        data = UIImageJPEGRepresentation(image, 0.75);
        filename = [NSString stringWithFormat:@"%@.JPG", generateUniquelyIdentifier()];
        previewImage = [UIImage thumbnailImageFromSourceImageData:data destinationSize:size];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,filename];
    BOOL isSuccess = [data writeToFile:path atomically:YES];
    if (isSuccess) {
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),self.album.directory,XPThumbDirectoryNameKey,filename];
        NSData *thumbData = UIImageJPEGRepresentation(previewImage, 0.75);
        [thumbData writeToFile:thumbPath atomically:YES];
        
        // 保存图片记录到数据库
        XPPhotoModel *photo = [[XPPhotoModel alloc] init];
        photo.albumid = self.album.albumid;
        photo.filename = filename;
        photo.originalname = @"";
        photo.createtime = photo.addtime = [[NSDate date] timeIntervalSince1970];
        photo.filesize = data.length;
        photo.filetype = filetype;
        [[XPSQLiteManager sharedSQLiteManager] addPhotos:@[photo]];
        self.album.count++;
        
        // 加载最新添加的图片信息并显示在最后
        NSArray *latestPhotos = [[XPSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:1];
        if (nil == self.photos) {
            self.photos = [NSMutableArray array];
        }
        [self.photos addObjectsFromArray:latestPhotos];
        [self.collectionView reloadData];
    } else {
        [XPProgressHUD showFailureHUD:NSLocalizedString(@"Photo saved failed", nil) toView:self.view];
    }
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"Album is empty", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"Please click the button below to add a picture.", nil);
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = NSLocalizedString(@"Add pictures", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName:  [UIColor colorWithHex:(state==UIControlStateHighlighted?@"0xC6DEF9":@"0x007AFF")]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty-box"];
}

#pragma mark - <DZNEmptyDataSetDelegate>

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self showAddPictureSheet:button];
}

#pragma mark - Actions

/**
 添加相片
 */
- (IBAction)showAddPictureSheet:(id)sender {
    @weakify(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // 照片图库
        @strongify(self);
        XPPhotoPickerViewController *pickerVc = [[XPPhotoPickerViewController alloc] init];
        XPNavigationController *nav = [[XPNavigationController alloc] initWithRootViewController:pickerVc];
        pickerVc.delegate = self;
        [self presentViewController:nav animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo or Video", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // 拍照
        @strongify(self);
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 没有摄像头
            [XPProgressHUD showFailureHUD:NSLocalizedString(@"The camera is not available", nil) toView:self.view];
            return;
        }
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            // 没有授权使用摄像头
            NSString *title = NSLocalizedString(@"Not authorized to use the camera", nil);
            NSString *message = NSLocalizedString(@"Please open in iPhone \"Settings - Privacy - Camera\"", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        UIImagePickerController *pickerVc = [[UIImagePickerController alloc] init];
        pickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerVc.mediaTypes = @[(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie];
        pickerVc.delegate = self;
        [self presentViewController:pickerVc animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    if (iPad()) {
        UIPopoverPresentationController *popover = [alert popoverPresentationController];
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            popover.barButtonItem = sender;
        } else {
            popover.sourceView = sender;
            popover.sourceRect = [(UIView *)sender bounds];
        }
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)editButtonAction:(UIBarButtonItem *)sender {
    _editing = !_editing;
    if (_editing) {
        sender.image = [UIImage imageNamed:@"icon-done"];
        self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, OPERATION_TOOLBAR_HEIGHT, 0.0);
        CGFloat contentHeight = self.collectionView.contentSize.height;
        CGFloat offsetY = self.collectionView.contentOffset.y;
        CGFloat visibleHeight = CGRectGetHeight(self.collectionView.frame);
        BOOL isEndBottom = contentHeight>=visibleHeight && offsetY+visibleHeight >= contentHeight;
        if (isEndBottom) {
            // 滚动视图已滑动到底部,当显示Toolbar时将滚动视图网上偏移,以免Toolbar遮挡图片
            CGPoint offset = self.collectionView.contentOffset;
            offset.y += OPERATION_TOOLBAR_HEIGHT;
            [UIView animateWithDuration:0.5 animations:^{
                self.collectionView.contentOffset = offset;
            }];
        }
        [self addOperationToolbar];
    } else {
        sender.image = [UIImage imageNamed:@"icon-edit"];
        self.collectionView.contentInset = UIEdgeInsetsZero;
        [[self.view viewWithTag:OPERATION_TOOLBAR_TAG] removeFromSuperview];
        if (_selectMaps.count) { // 取消图片的选中状态
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
            for (NSString *key in _selectMaps) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:key.integerValue inSection:0];
                [indexPaths addObject:indexPath];
            }
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        }
        [_selectMaps removeAllObjects];
    }
}

/// 保存选中的图片
- (void)saveButtonItemAction:(UIBarButtonItem *)sender {
    if (0 == _selectMaps.count) {
        return [XPProgressHUD showToast:NSLocalizedString(@"Please select the pictures you want to save", nil)];
    }
    @weakify(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (status != PHAuthorizationStatusAuthorized) {
                [XPProgressHUD showFailureHUD:NSLocalizedString(@"No authorization to access Photo Library", nil) toView:self.view];
                return;
            }
            [XPProgressHUD showLoadingHUD:NSLocalizedString(@"Copying the pictures...", nil) toView:self.view];
            // 保存图片到系统相册(可以保存到自定义相册)
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                for (NSString *key in self.selectMaps) {
                    NSInteger index = [key integerValue];
                    XPPhotoModel *photo = self.photos[index];
                    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,photo.filename];
                    NSURL *fileURL = [NSURL fileURLWithPath:path];
                    [PHAssetCreationRequest creationRequestForAssetFromImageAtFileURL:fileURL];
                }
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [XPProgressHUD hideHUDForView:self.view];
                    if (error) {
                        [XPProgressHUD showFailureHUD:NSLocalizedString(@"Photo saved failed", nil) toView:self.view];
                    } else {
                        [XPProgressHUD showSuccessHUD:NSLocalizedString(@"Photo saved successfully", nil) toView:self.view];
                    }
                });
            }];
        });
    }];
}

/// 删除选中的图片
- (void)deleteButtonItemAction:(UIBarButtonItem *)sender {
    if (0 == _selectMaps.count) {
        return [XPProgressHUD showToast:NSLocalizedString(@"Please select the pictures you want to delete", nil)];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure you want to delete the selected photos?", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    @weakify(self);
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [XPProgressHUD showLoadingHUD:NSLocalizedString(@"Deleting pictures...", nil)
                               toView:[UIApplication sharedApplication].keyWindow];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            NSMutableArray<XPPhotoModel *> *photos = [NSMutableArray array];
            for (NSString *key in self.selectMaps) {
                NSInteger index = [key integerValue];
                XPPhotoModel *photo = self.photos[index];
                [photos addObject:photo];
            }
            XPSQLiteManager *manager = [XPSQLiteManager sharedSQLiteManager];
            BOOL success = [manager deletePhotos:photos fromAlbum:self.album];
            if (success) {
                [self.photos removeObjectsInArray:photos];
                self.album.count = MAX(0, self.album.count-photos.count);
            }
            [self.selectMaps removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [XPProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
                [self.selectMaps removeAllObjects];
                [self updateToolbarIndicator];
            });
        });
    }]];
    if (iPad()) {
        UIPopoverPresentationController *popover = [alert popoverPresentationController];
        popover.barButtonItem = sender;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private

/// 从系统中获取视频文件
- (void)fetchVideoForPHAsset:(PHAsset *)asset completionHandler:(void(^)(XPPhotoModel *photo))completionHandler {
    @weakify(self);
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        @strongify(self);
        if (![asset isKindOfClass:[AVURLAsset class]]) return;
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        // 视频文件
        NSString *suffix = [urlAsset.URL.absoluteString pathExtension];
        NSString *filename = [NSString stringWithFormat:@"%@.%@", generateUniquelyIdentifier(),suffix];
        NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL];
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,filename];
        [videoData writeToFile:path atomically:YES];
        // 视频预览图
        UIImage *thumbImage = [UIImage snapshotImageWithVideoURL:urlAsset.URL];
        thumbImage = [UIImage thumbnailImageFromSourceImage:thumbImage destinationSize:CGSizeMake(XPThumbImageWidthAndHeightKey, XPThumbImageWidthAndHeightKey)];
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),self.album.directory,XPThumbDirectoryNameKey,filename];
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.75);
        [thumbData writeToFile:thumbPath atomically:YES];
        // 保存视频信息
        XPPhotoModel *photo = [[XPPhotoModel alloc] init];
        photo.albumid = self.album.albumid;
        photo.filename = filename;
        photo.originalname = [urlAsset.URL.absoluteString lastPathComponent];
        photo.addtime = [[NSDate date] timeIntervalSince1970];
        photo.filesize = videoData.length;
        photo.filetype = XPFileTypeVideo;
        
        if (nil != completionHandler) {
            completionHandler(photo);
        }
    }];
}

/// 从系统中获取图片文件
- (void)fetchImageForPHAsset:(PHAsset *)asset completionHandler:(void(^)(XPPhotoModel *photo))completionHandler {
    @weakify(self);
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        @strongify(self);
        NSURL *imageFileURL = info[@"PHImageFileURLKey"];
        XPPhotoModel *photo = [[XPPhotoModel alloc] init];
        photo.albumid = self.album.albumid;
        photo.filename = [NSString stringWithFormat:@"%@.%@",generateUniquelyIdentifier(),imageFileURL.pathExtension];
        photo.originalname = [imageFileURL lastPathComponent];
        photo.createtime = [asset.creationDate timeIntervalSince1970];
        photo.addtime = [[NSDate date] timeIntervalSince1970];
        photo.filesize = imageData.length;
        photo.filetype = [imageFileURL.pathExtension.uppercaseString isEqualToString:@"GIF"] ? XPFileTypeGIFImage : XPFileTypeImage;
        
        // 将图片写入目标文件
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,photo.filename];
        [imageData writeToFile:path atomically:YES];
        
        // 生成缩略图并保存
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),self.album.directory,XPThumbDirectoryNameKey,photo.filename];
        UIImage *thumbImage = nil;
        CGSize thumbImageSize = CGSizeMake(XPThumbImageWidthAndHeightKey, XPThumbImageWidthAndHeightKey);
        if (photo.filetype == XPFileTypeGIFImage) {
            UIImage *tmpImage = [UIImage snapshotImageWithGIFImageURL:imageFileURL];
            thumbImage = [UIImage thumbnailImageFromSourceImage:tmpImage destinationSize:thumbImageSize];
        } else {
            thumbImage = [UIImage thumbnailImageFromSourceImageData:imageData destinationSize:thumbImageSize];
        }
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.75);
        [thumbData writeToFile:thumbPath atomically:YES];
        
        if (nil != completionHandler) {
            completionHandler(photo);
        }
    }];
}

/// 添加底部的操作条
- (void)addOperationToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.tag = OPERATION_TOOLBAR_TAG;
    [self.view addSubview:toolbar];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(toolbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar(==height)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:@{@"height":@(OPERATION_TOOLBAR_HEIGHT)} views:NSDictionaryOfVariableBindings(toolbar)]];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveButtonItemAction:)];
    UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonItemAction:)];
    UIImage *image = [[UIImage roundSubscriptImageWithImageSize:CGSizeMake(30.0, 30.0) backgoundColor:[UIColor colorWithHex:@"0xC2E4C4"] subscript:0 fontSize:16.0 textColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *numberItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    numberItem.tag = OPERATION_TOOLBAR_INDICATOR_ITEM_TAG;
    numberItem.enabled = NO;
    toolbar.items = @[saveItem, spaceItem1, numberItem, spaceItem2, deleteItem];
}

/// 更新toolbar上的数字
- (void)updateToolbarIndicator {
    NSUInteger count = _selectMaps.count;
    UIColor *backgroundColor = [UIColor colorWithHex:(count==0 ? @"0xC2E4C4" : @"0x38BD20")];
    UIImage *image = [[UIImage roundSubscriptImageWithImageSize:CGSizeMake(30.0, 30.0) backgoundColor:backgroundColor subscript:count fontSize:16.0 textColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIToolbar *toolbar = [self.view viewWithTag:OPERATION_TOOLBAR_TAG];
    for (UIBarButtonItem *item in toolbar.items) {
        if (item.tag == OPERATION_TOOLBAR_INDICATOR_ITEM_TAG) {
            item.image = image;
            break;
        }
    }
}

@end
