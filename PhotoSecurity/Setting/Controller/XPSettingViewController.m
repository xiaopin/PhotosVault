//
//  XPSettingViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/20.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPSettingViewController.h"
#import "XPSettingCell.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface XPSettingViewController ()

@end

@implementation XPSettingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    // iOS>=10.3 通过摇一摇功能切换App图标
    UIApplication *application = [UIApplication sharedApplication];
    if (isOperatingSystemAtLeastVersion(10, 3, 0) && [application supportsAlternateIcons]) {
        [application setApplicationSupportsShakeToEdit:YES];
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.text = [NSString stringWithFormat:@"\n\n\t%@\n", NSLocalizedString(@"We have now provided by shaking random replacement application icon function, shake the phone try it", nil)];
        label.textColor = [UIColor colorWithR:226.0 g:69.0 b:75.0];
        label.font = [UIFont systemFontOfSize:15.0];
        [label sizeToFit];
        self.tableView.tableFooterView = label;
        // 要使用摇一摇功能,必须将当前控制器设置为第一响应者
        [self becomeFirstResponder];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView.tableFooterView sizeToFit];
}

- (void)dealloc {
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    XPSettingCell *settingCell = (XPSettingCell *)cell;
    if (0 == indexPath.section) {
        [settingCell.stateSwitch setHidden:NO];
        [settingCell.stateSwitch setOn:isEnableTouchID()];
        [settingCell.stateSwitch addTarget:self
                                    action:@selector(stateSwitchAction:)
                          forControlEvents:UIControlEventValueChanged];
        [settingCell.titleLabel setText:NSLocalizedString(@"Fingerprints are unlocked", nil)];
    } else if (1 == indexPath.section) {
        [settingCell.titleLabel setText:NSLocalizedString(@"Change Password", nil)];
        [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else if (2 == indexPath.section) {
        [settingCell.titleLabel setText:NSLocalizedString(@"FTP Service", nil)];
        [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (1 == indexPath.section) {
        [self performSegueWithIdentifier:@"ChangePasswordSegue" sender:nil];
    } else if (2 == indexPath.section) {
        [self performSegueWithIdentifier:@"FTPSegue" sender:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (0 == section) {
        return NSLocalizedString(@"After opening, you can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil);
    }
    if (2 == section) {
        return NSLocalizedString(@"After opening, you can quickly copy the photos through the FTP server", nil);
    }
    return nil;
}

#pragma mark - Shake

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // 摇一摇结束,随机更换一个新的App图标
    UIApplication *application = [UIApplication sharedApplication];
    if (event.subtype == UIEventSubtypeMotionShake &&
        isOperatingSystemAtLeastVersion(10, 3, 0) &&
        [application supportsAlternateIcons]) {
        int random = arc4random_uniform(1000)%3;
        NSString *iconName = nil; // nil表示使用原来的图标
        switch (random) {
            case 1:
                iconName = iPad() ? @"AppAlternateIconiPad" : @"AppAlternateIcon";
                break;
            case 2:
                iconName = iPad() ? @"AppAlternateIconiPad2" : @"AppAlternateIcon2";
                break;
            default:
                break;
        }
        NSString *alternateIconName = [application alternateIconName];
        if ((nil==alternateIconName && nil==iconName) ||
            (alternateIconName && [alternateIconName isEqualToString:iconName])) {
            [XPProgressHUD showFailureHUD:NSLocalizedString(@"Random icons are identical to existing icons and need not be replaced", nil) toView:self.view];
            return;
        }
        [application setAlternateIconName:iconName completionHandler:nil];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
}

#pragma mark - Actions

- (void)stateSwitchAction:(UISwitch *)sender {
    XPSettingCell *cell = (XPSettingCell *)sender.superview.superview;
    if (isEnableTouchID()) { // 已开启,则关闭指纹解锁
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Make sure you want to turn off Touch ID?", nil) message:NSLocalizedString(@"", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [cell.stateSwitch setOn:YES];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [cell.stateSwitch setOn:NO];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:XPTouchEnableStateKey];
            [userDefaults synchronize];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        @weakify(self);
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        BOOL isAvailable = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        if (!isAvailable) {
            [cell.stateSwitch setOn:NO];
            [XPProgressHUD showFailureHUD:error.localizedDescription toView:self.view];
            return;
        }
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil) reply:^(BOOL success, NSError * _Nullable error) {
            @strongify(self);
            if (!success) {
                [XPProgressHUD showFailureHUD:error.localizedDescription toView:self.view];
                return;
            }
            [cell.stateSwitch setOn:YES];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:XPTouchEnableStateKey];
            [userDefaults synchronize];
        }];
    }
}


@end
