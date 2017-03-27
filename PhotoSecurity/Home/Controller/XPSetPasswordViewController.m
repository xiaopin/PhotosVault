//
//  XPSetPasswordViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/3.
//  Copyright © 2017年 xiaopin. All rights reserved.
//  首次使用时需设置密码

#import "XPSetPasswordViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface XPSetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation XPSetPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)setPasswordButtonAction:(UIButton *)sender {
    NSString *pwd = [self.passwordTextField.text trim];
    NSString *confirmPwd = [self.confirmPasswordTextField.text trim];
    if (0 == pwd.length) {
        return [self.passwordTextField shake];
    }
    if (0 == confirmPwd.length) {
        return [self.confirmPasswordTextField shake];
    }
    if (XPPasswordMinimalLength > pwd.length) {
        [self.passwordTextField becomeFirstResponder];
        [XPProgressHUD showToast:NSLocalizedString(@"Password length is at least 6 characters", nil)];
        return;
    }
    if (![pwd isEqualToString:confirmPwd]) {
        [XPProgressHUD showToast:NSLocalizedString(@"The password entered twice is inconsistent", nil)];
        return;
    }
    // 存储密码
    [XPPasswordTool storagePassword:pwd];
    
    // TODO:检测设备是否支持TouchID
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL isSupportTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
    if (isSupportTouchID && nil == error) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil) reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                // TouchID验证成功,将TouchID功能标记为开启状态
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:XPTouchEnableStateKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                NSLog(@"%@", error);
                switch (error.code) {
                    case LAErrorSystemCancel:
                        break;
                    case LAErrorUserCancel:
                        NSLog(@"用户取消");
                        break;
                    case LAErrorPasscodeNotSet:
                        NSLog(@"TouchID未设置密码，需要先设置密码");
                        break;
                    case LAErrorAuthenticationFailed:
                        NSLog(@"认证失败");
                        break;
                    default:
                        break;
                }
            }
        }];
    }
    NSLog(@"%@", error.userInfo[NSLocalizedDescriptionKey]);
    
    // 跳转到首页
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - StatusBar Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
