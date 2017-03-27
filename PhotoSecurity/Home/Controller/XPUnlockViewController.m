//
//  XPUnlockViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/6.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPUnlockViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface XPUnlockViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation XPUnlockViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotificationAction:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self prepareEnterPassword];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self unlockButtonAction:nil];
    return YES;
}

#pragma mark - Actions

- (IBAction)unlockButtonAction:(UIButton *)sender {
    NSString *password = [self.passwordTextField.text trim];
    if (XPPasswordMinimalLength > password.length) {
        return [self.passwordTextField shake];
    }
    if (![XPPasswordTool verifyPassword:password]) {
        // TODO:密码错误,是否有必要限制每天的密码输入错误次数
        [XPProgressHUD showToast:NSLocalizedString(@"Password is wrong, please try again.", nil)];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillEnterForegroundNotificationAction:(NSNotification *)sender {
    [self prepareEnterPassword];
}

#pragma mark - Private

- (void)prepareEnterPassword {
    if (isEnableTouchID()) {
        @weakify(self);
        LAContext *context = [[LAContext alloc] init];
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Unlock access to locked feature", nil) reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if (success) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return;
                }
                switch (error.code) {
                    case LAErrorUserCancel:
                    case LAErrorUserFallback:
                    case LAErrorTouchIDLockout:
                    case LAErrorAuthenticationFailed:
                        [self.passwordTextField becomeFirstResponder];
                        break;
                    default:
                        break;
                }
            });
        }];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
}

#pragma mark - StatusBar Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
