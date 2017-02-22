//
//  YGUserRemarkNameViewCtrl.m
//  Golf
//
//  Created by 梁荣辉 on 2016/9/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGUserRemarkNameViewCtrl.h"
#import "YGUserRemarkCacheHelper.h"

// 最大8个字符
#define kYGUserRemarkNameMaxTextCount  8

@interface YGUserRemarkNameViewCtrl ()<UITextFieldDelegate>

// 输入内容
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation YGUserRemarkNameViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"备注";
    
    [self initUI];
    
    [self initData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)doRightNavAction
{
    [self _submitUserRemark];
}

#pragma mark - 
#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * beString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([beString length] > kYGUserRemarkNameMaxTextCount) {
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > kYGUserRemarkNameMaxTextCount) {
                textField.text = [toBeString substringToIndex:kYGUserRemarkNameMaxTextCount];
            }
        }
    } else {
        if (toBeString.length > kYGUserRemarkNameMaxTextCount) {
            textField.text = [toBeString substringToIndex:kYGUserRemarkNameMaxTextCount];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self _submitUserRemark];
    return YES;
}

#pragma mark - 
#pragma mark - private method

/**
 * 初始化视图
 */
-(void) initUI
{
    self.textField.delegate = self;
    NSString *textName = (self.remarkName && self.remarkName.length > 0) ? self.remarkName : self.nickName;
    self.textField.text = textName;
    [self.textField becomeFirstResponder];
    
    [self rightButtonAction:@"保存"];
}

/**
 * 初始化数据
 */
-(void) initData
{
    
}

/**
 * 提交备注名称
 */
-(void) _submitUserRemark
{
    NSString *newRemarkName = self.textField.text;
    newRemarkName =  [newRemarkName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([newRemarkName length] > kYGUserRemarkNameMaxTextCount) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"备注名称最多%d字符",kYGUserRemarkNameMaxTextCount]];
        return;
    }
    
    [self.view endEditing:YES];
    
    if ((newRemarkName.length == 0 || self.nickName.length == 0) && [newRemarkName isEqualToString:self.nickName]) {
        if (self.userRemarkBlock) {
            self.userRemarkBlock(newRemarkName);
        }
        [self back];
        
        return;
    }
    
    [[YGUserRemarkCacheHelper shared] updateUserRemarkName:newRemarkName.length > 0 ? newRemarkName : self.nickName memberId:self.memberId];
    
    ygweakify(self)
    [ServerService userFollowAddWithSessionId:[[LoginManager sharedManager] getSessionId] toMemberId:self.memberId nameRemark:newRemarkName operation:3 success:^(id dic) {
        ygstrongify(self)
        if ([dic objectForKey:@"is_followed"]) {
            NSString *alertString = @"备注名修改成功";
            [SVProgressHUD showSuccessWithStatus:alertString];
        }
        
        if (self.userRemarkBlock) {
            self.userRemarkBlock(newRemarkName);
        }
        
        [self back];
        
    } failure:^(id error) {
         [SVProgressHUD showSuccessWithStatus:@"备注名修改失败"];
    }];
    
}

- (void)dealloc
{
    self.textField = nil;
    self.userRemarkBlock = nil;
    self.remarkName = nil;
    
}

@end
