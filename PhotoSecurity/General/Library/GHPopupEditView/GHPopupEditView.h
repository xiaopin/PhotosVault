//
//  GHPopupEditView.h
//  GitHub-iOS
//  https://github.com/xiaopin/GHPopupEditView
//
//  Created by nhope on 2016/11/25.
//  Copyright © 2016年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 用户完成输入时的回调
 @param text 用户输入的文本
 */
typedef void(^GHPopupEditViewCompletionHandler)(NSString *text);

/**
 校验用户输入的文本
 @param text 用户输入的文本
 @return 返回空字符串@""即认为校验通过,否则请返回错误信息
 */
typedef NSString*(^GHPopupEditViewVerifyHandler)(NSString *text);

/**
 限制用户输入的字符
 @see UITextFieldDelegate -(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
 @param textField           输入框
 @param range               替换位置
 @param replacementString   替换的文本
 @return 返回NO则不更改文本(放弃用户当前输入的字符)
 */
typedef BOOL(^GHPopupEditViewShouldChangeHandler)(UITextField *textField, NSRange range, NSString *replacementString);


@interface GHPopupEditView : UIView

/// 完成输入时的回调
@property (nonatomic, copy) GHPopupEditViewCompletionHandler completionHandler;
/// 校验用户输入的文本是否合法
@property (nonatomic, copy) GHPopupEditViewVerifyHandler verifyHandler;
/// 限制用户输入的文本
@property (nonatomic, copy) GHPopupEditViewShouldChangeHandler shouldChangeHandler;

/// 设置标题
- (void)setTitle:(NSString *)title;
/// 设置输入框占位字符
- (void)setPlaceholderString:(NSString *)placeholder;
/// 设置输入框默认文本
- (void)setDefaultText:(NSString *)text;
/// 设置键盘类型
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
/// 设置键盘`返回按钮`的类型,默认`UIReturnKeyDone`
- (void)setReturnKeyType:(UIReturnKeyType)type;
/// 设置`确定按钮`的主题色
- (void)setOKButtonThemeColor:(UIColor *)color;
/// 设置`取消按钮`的主题色
- (void)setCancelButtonThemeColor:(UIColor *)color;
/// 显示视图
- (void)show;

@end
