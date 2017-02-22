//
//  YGChangePasswordViewCtrl.m
//  Eweek
//
//  Created by user on 13-9-25.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "YGChangePasswordViewCtrl.h"
#import "RegexKitLite.h"
#import "LoginService.h"
#import "UIView+Shake.h"

@interface YGChangePasswordViewCtrl ()

@end

@implementation YGChangePasswordViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    
    UITextInputMode *tim = [[UITextInputMode activeInputModes] firstObject];
    if ([[tim primaryLanguage] isEqualToString:@"emoji"]) {
        return NO;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString * beString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([_tfOldPwd isEqual:textField])
    {
        if ([beString length] > 16) {
            textField.text = [toBeString substringToIndex:16];
            return NO;
        }
    }
    if ([_tfNewPwd isEqual:textField])
    {
        if ([beString length] > 16) {
            textField.text = [toBeString substringToIndex:16];
            return NO;
        }
    }
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_tfOldPwd == textField) {
        [_tfNewPwd becomeFirstResponder];
    }else{
        [self sureAction:nil];
    }
	return YES;
}

- (IBAction)sureAction:(id)sender
{
    [_tfOldPwd resignFirstResponder];
    [_tfNewPwd resignFirstResponder];
    
    NSString *password = @"^.{6,16}$";
    if (![_tfOldPwd.text isMatchedByRegex:password]) {
        [SVProgressHUD showInfoWithStatus:@"旧密码输入不正确"];
        [_tfOldPwd shake:5 withDelta:10];
        [_tfOldPwd becomeFirstResponder];
    }else if (([_tfOldPwd.text isMatchedByRegex:password]) && (![_tfNewPwd.text isMatchedByRegex:password])) {
        [SVProgressHUD showInfoWithStatus:@"请输入6至16位新密码"];
        [_tfNewPwd shake:5 withDelta:10];
        [_tfNewPwd becomeFirstResponder];
    }else {
        oldPwdString = _tfOldPwd.text;
        newPwdString = _tfNewPwd.text;
        [self changePasswordAction];
    }
}

- (void)changePasswordAction
{
    [LoginService passwordModify:[[LoginManager sharedManager] getSessionId] withOldPassword:oldPwdString withNewPassword:newPwdString success:^(BOOL boolen) {
        if (boolen) {
            [[NSUserDefaults standardUserDefaults] setObject:newPwdString forKey:KGolfUserPassword];
            [SVProgressHUD showSuccessWithStatus:@"密码修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(id error) {
//        [SVProgressHUD showErrorWithStatus:@"密码修改失败"];lyf 屏蔽 系统统一弹出提示框
    }];
}

@end
