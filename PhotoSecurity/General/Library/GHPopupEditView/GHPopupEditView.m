//
//  GHPopupEditView.m
//  GitHub-iOS
//  https://github.com/xiaopin/GHPopupEditView
//
//  Created by nhope on 2016/11/25.
//  Copyright © 2016年 xiaopin. All rights reserved.
//

#import "GHPopupEditView.h"

@interface GHPopupEditView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation GHPopupEditView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    NSAssert(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone || UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad,
             @"Does not support the platform, only supports iPhone, iPad, iPod.");
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.messageLabel];
        [self.contentView addSubview:self.cancelButton];
        [self.contentView addSubview:self.okButton];
        
        [self registerNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

- (void)setPlaceholderString:(NSString *)placeholder {
    [self.textField setPlaceholder:placeholder];
}

- (void)setDefaultText:(NSString *)text {
    [self.textField setText:text];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    [self.textField setKeyboardType:keyboardType];
}

- (void)setReturnKeyType:(UIReturnKeyType)type {
    [self.textField setReturnKeyType:type];
}

- (void)setOKButtonThemeColor:(UIColor *)color {
    [self.okButton setTitleColor:color forState:UIControlStateNormal];
    [self.okButton.layer setBorderColor:[color CGColor]];
}

- (void)setCancelButtonThemeColor:(UIColor *)color {
    [self.cancelButton setTitleColor:color forState:UIControlStateNormal];
    [self.cancelButton.layer setBorderColor:[color CGColor]];
}

- (void)show {
    [self adjustFrame];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    // Animation
    [self setAlpha:1.0];
    [self setHidden:NO];
    self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.65 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.textField becomeFirstResponder];
    }];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (nil != self.shouldChangeHandler) {
        return self.shouldChangeHandler(textField, range, string);
    }
    return YES;
}

#pragma mark - Actions

- (void)cancelButtonAction:(UIButton *)sender {
    [self hide];
}

- (void)okButtonAction:(UIButton *)sender {
    NSString *text = [self.textField text];
    if (nil != self.verifyHandler) {
        NSString *error = [self.verifyHandler(text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (error && error.length) {
            [self.messageLabel setText:error];
            return;
        }
    }
    if (nil != self.completionHandler) {
        self.completionHandler(text);
    }
    [self hide];
}

/// 屏幕旋转的通知
- (void)screenDidRotationNotification:(NSNotification *)notification {
    [self adjustFrame];
}

/// 键盘frame改变的通知
- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect contentFrame = self.contentView.frame;
    CGFloat remainingHeight = CGRectGetHeight(self.frame) - CGRectGetHeight(keyboardFrame);
    CGFloat contentHeight = CGRectGetHeight(contentFrame);
    
    if (CGRectGetMaxY(contentFrame) < keyboardFrame.origin.y) {
        return;
    }
    if (remainingHeight > contentHeight) {
        contentFrame.origin.y = (remainingHeight-contentHeight)/2;
    } else {
        contentFrame.origin.y = 10.0;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = contentFrame;
    }];
}

/// 键盘消失的通知
- (void)keyboardDidHideNotification:(NSNotification *)notification {
    CGRect contentFrame = self.contentView.frame;
    contentFrame.origin.y = (CGRectGetHeight(self.frame)-CGRectGetHeight(contentFrame))/2;
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = contentFrame;
    }];
}

#pragma mark - Private

- (void)hide {
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)adjustFrame {
    BOOL iPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    CGFloat contentWidth = iPhone ? 300.0 : 500.0;
    CGFloat padding = 10.0;
    
    self.frame = [UIScreen mainScreen].bounds;
    _titleLabel.frame = CGRectMake(padding, padding, contentWidth-padding*2, 20.0);
    _textField.frame = CGRectMake(padding, CGRectGetMaxY(_titleLabel.frame)+padding, contentWidth-padding*2, 40.0);
    _messageLabel.frame = CGRectMake(padding, CGRectGetMaxY(_textField.frame), contentWidth-padding*2, 20.0);
    _cancelButton.frame = CGRectMake(padding, CGRectGetMaxY(_messageLabel.frame), (contentWidth-padding*3)/2, 30.0);
    _okButton.frame = CGRectMake(CGRectGetMaxX(_cancelButton.frame)+padding, CGRectGetMinY(_cancelButton.frame), CGRectGetWidth(_cancelButton.frame), CGRectGetHeight(_cancelButton.frame));
    
    CGFloat contentHeight = CGRectGetMaxY(_okButton.frame)+padding;
    CGFloat contentY = (CGRectGetHeight(self.frame)-contentHeight)/2;
    _contentView.frame = CGRectMake((CGRectGetWidth(self.frame)-contentWidth)/2, contentY, contentWidth, contentHeight);
}

- (void)registerNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(screenDidRotationNotification:)
                          name:UIApplicationDidChangeStatusBarOrientationNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(keyboardDidChangeFrameNotification:)
                          name:UIKeyboardDidChangeFrameNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(keyboardDidHideNotification:)
                          name:UIKeyboardDidHideNotification
                        object:nil];
}

#pragma mark - setter & getter

- (UIView *)contentView {
    if (nil == _contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [_contentView.layer setCornerRadius:4.0];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UITextField *)textField {
    if (nil == _textField) {
        _textField = [[UITextField alloc] init];
        [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_textField setBorderStyle:UITextBorderStyleRoundedRect];
        [_textField setFont:[UIFont systemFontOfSize:14.0]];
        [_textField setReturnKeyType:UIReturnKeyDone];
        [_textField setDelegate:self];
    }
    return _textField;
}

- (UILabel *)messageLabel {
    if (nil == _messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        [_messageLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_messageLabel setTextColor:[UIColor redColor]];
    }
    return _messageLabel;
}

- (UIButton *)cancelButton {
    if (nil == _cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton.layer setCornerRadius:4.0];
        [_cancelButton.layer setBorderWidth:0.5];
        [_cancelButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)okButton {
    if (nil == _okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okButton.layer setCornerRadius:4.0];
        [_okButton.layer setBorderWidth:0.5];
        [_okButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [_okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_okButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [_okButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

@end
