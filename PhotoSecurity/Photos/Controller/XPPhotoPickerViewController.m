//
//  XPPhotoPickerViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/9.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPPhotoPickerViewController.h"
#import "XPPhotoCollectionViewController.h"
#import "XPAlbumCollectionModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface XPPhotoPickerViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/// 所有相册数据
@property (nonatomic, strong) NSArray<XPAlbumCollectionModel *> *albums;

@end

@implementation XPPhotoPickerViewController

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [super initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonAction:)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self loadAssetsCollection];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    XPAlbumCollectionModel *album = self.albums[indexPath.row];
    cell.textLabel.text = album.albumCollection.localizedTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", album.assetCounts];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XPPhotoCollectionViewController *vc = [[XPPhotoCollectionViewController alloc] init];
    vc.album = self.albums[indexPath.row];
    @weakify(self);
    vc.didSelectAssetsCompletionHandler = ^(NSArray<PHAsset *> *assets) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(photoPickerViewController:didSelectedAssets:)]) {
            [self.delegate photoPickerViewController:self didSelectedAssets:assets];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"No authorization to access Photo Library", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"Please open in iPhone \"Settings - Privacy - Photos\"", nil);
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
    NSString *text = NSLocalizedString(@"Open settings", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName:  [UIColor colorWithHex:(state==UIControlStateHighlighted?@"0xC6DEF9":@"0x007AFF")]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"unauthorized"];
}

#pragma mark - <DZNEmptyDataSetDelegate>

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        return YES;
    }
    return NO;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Actions

- (void)dismissButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

/**
 获取系统相册数据
 */
- (void)loadAssetsCollection {
    @weakify(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        @strongify(self);
        if (status != PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadEmptyDataSet];
            });
            return;
        }
        NSMutableArray<XPAlbumCollectionModel *> *array = [NSMutableArray array];
        // 获取所有系统的相册
        PHFetchResult<PHAssetCollection *> *smartResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in smartResult) {
            XPAlbumCollectionModel *album = [[XPAlbumCollectionModel alloc] init];
            album.albumCollection = collection;
            [array addObject:album];
        }
        // 获取所有用户创建的相册
        PHFetchResult<PHAssetCollection *> *albumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in albumsResult) {
            XPAlbumCollectionModel *album = [[XPAlbumCollectionModel alloc] init];
            album.albumCollection = collection;
            [array addObject:album];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albums = [NSArray arrayWithArray:array];
            [self.tableView reloadData];
        });
    }];
}

@end
