//
//  XPHomeViewController.m
//  PhotoSecurity
//
//  Created by xiaopin on 2017/3/1.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPHomeViewController.h"
#import "XPAlbumDetailViewController.h"
#import "GHPopupEditView.h"
#import "XPAlbumCell.h"
#import "XPAlbumModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface XPHomeViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/// 用户的相册数据
@property (nonatomic, strong) NSMutableArray<XPAlbumModel *> *userAlbums;
/// 是否需要重新排序
@property (nonatomic, assign, getter=isReSequence) BOOL reSequence;

@end

@implementation XPHomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.navigationController.view.hidden = YES;
    self.userAlbums = [[XPSQLiteManager sharedSQLiteManager] requestUserAlbums];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 实时更新UI
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    // 打开应用必须先解锁才能使用
    static dispatch_once_t onceToken;
    @weakify(self);
    dispatch_once(&onceToken, ^{
        @strongify(self);
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSString *identifier = [XPPasswordTool isSetPassword] ? @"XPUnlockViewController" : @"XPSetPasswordViewController";
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        [self presentViewController:vc animated:NO completion:^{
            self.navigationController.view.hidden = NO;
        }];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AlbumDetailSegue"]) {
        XPAlbumDetailViewController *detailVc = (XPAlbumDetailViewController *)segue.destinationViewController;
        detailVc.album = (XPAlbumModel *)sender;
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    XPAlbumModel *album = self.userAlbums[indexPath.row];
    XPAlbumCell *albumCell = (XPAlbumCell *)cell;
    [albumCell configureWithAlbum:album];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XPAlbumModel *album = self.userAlbums[indexPath.row];
    [self performSegueWithIdentifier:@"AlbumDetailSegue" sender:album];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XPAlbumModel *album = self.userAlbums[indexPath.row];
        NSString *title = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Delete", nil),album.name];
        NSString *message = NSLocalizedString(@"Are you sure you want to delete the album? All the pictures under the album will be deleted.", nil);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        @weakify(self);
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Album", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            XPAlbumModel *album = self.userAlbums[indexPath.row];
            BOOL success = [[XPSQLiteManager sharedSQLiteManager] deleteAlbumWithAlbum:album];
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [XPProgressHUD showFailureHUD:NSLocalizedString(@"Delete fail.", nil) toView:self.view];
                });
                return;
            }
            [self.userAlbums removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (0 == self.userAlbums.count) {
                [self.tableView reloadEmptyDataSet];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        if (iPad()) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            alert.popoverPresentationController.sourceView = cell;
            // 直接cell.bounds会导致弹出框往左偏移不居中
            alert.popoverPresentationController.sourceRect = CGRectMake(cell.contentView.frame.origin.x, 0.0, cell.bounds.size.width+ABS(cell.contentView.frame.origin.x)*2, cell.bounds.size.height);
            alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", nil);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.row == destinationIndexPath.row) {
        return; // 未移动位置
    }
    XPAlbumModel *album = self.userAlbums[sourceIndexPath.row];
    [self.userAlbums removeObjectAtIndex:sourceIndexPath.row];
    [self.userAlbums insertObject:album atIndex:destinationIndexPath.row];
    _reSequence = YES;
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"No albums", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"No albums, please create an album to facilitate the storage of photos.", nil);
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
    NSString *text = NSLocalizedString(@"Create a new album", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName:  [UIColor colorWithHex:(state==UIControlStateHighlighted?@"0xC6DEF9":@"0x007AFF")]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"home-album"];
}

#pragma mark - <DZNEmptyDataSetDelegate>

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self showCreateAlbumAlert];
}

#pragma mark - Actions

- (IBAction)addButtonAction:(UIBarButtonItem *)sender {
    [self showCreateAlbumAlert];
}

- (IBAction)editButtonAction:(UIBarButtonItem *)sender {
    if ([self.tableView isEditing]) {
        self.tableView.editing = NO;
        sender.image = [UIImage imageNamed:@"icon-edit"];
        if (_reSequence) {
            _reSequence = NO;
            [[XPSQLiteManager sharedSQLiteManager] resortAlbums:self.userAlbums];
        }
    } else {
        self.tableView.editing = YES;
        sender.image = [UIImage imageNamed:@"icon-done"];
    }
}

#pragma mark - Private

/**
 显示创建相册名称的弹窗
 */
- (void)showCreateAlbumAlert {
    GHPopupEditView *popupView = [[GHPopupEditView alloc] init];
    [popupView setTitle:NSLocalizedString(@"Please enter the album name", nil)];
    [popupView setPlaceholderString:NSLocalizedString(@"Album name", nil)];
    [popupView setVerifyHandler:^(NSString *text) {
        NSString *albumName = [text trim];
        if (albumName.length == 0) {
            return NSLocalizedString(@"Album name can not be empty", nil);
        }
        return @"";
    }];
    @weakify(self);
    [popupView setCompletionHandler:^(NSString *text) {
        @strongify(self);
        NSString *name = [text trim];
        XPSQLiteManager *manager = [XPSQLiteManager sharedSQLiteManager];
        XPAlbumModel *album = [manager createAlbumWithName:name];
        if (nil == album) return;
        [self.userAlbums addObject:album];
        [self.tableView reloadData];
    }];
    [popupView show];
}


@end
