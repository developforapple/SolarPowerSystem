//
//  YGMallOrderMemoEditViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderMemoEditViewCtrl.h"
#import "IQTextView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YGMallOrderModel.h"

#define kWordNumber 50

@interface YGMallOrderMemoEditViewCtrl ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet IQTextView *textView;
@end

@implementation YGMallOrderMemoEditViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self rightButtonAction:@"提交"];
    
    self.textView.placeholder = [NSString stringWithFormat:@"在此输入您的留言（%d字以内）",kWordNumber];
    self.textView.text = self.order.user_memo;
    self.textView.textColor = RGBColor(51, 51, 51, 1);
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.textAlignment = NSTextAlignmentJustified;
    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    RAC(self.textView,textColor) = [self.textView.rac_textSignal
                                    map:^id(NSString *value) {
                                        return value.length>kWordNumber?[UIColor redColor]:RGBColor(74, 74, 74, 1);
                                    }];
    
    [self.textView becomeFirstResponder];
}

- (void)doRightNavAction
{
    [self.textView endEditing:YES];
    NSString *text = self.textView.text;
    if (text.length > kWordNumber) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"留言不得超过%d个字",kWordNumber]];
    }else{
        [self doMemoEdit];
    }
}

- (void)doMemoEdit
{
    if (self.order.user_memo && self.textView.text && [self.order.user_memo isEqualToString:self.textView.text]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.order.tempStatus == YGMallOrderStatusCreating) {
        self.order.user_memo = self.textView.text;
        if (self.memoDidChanged) {
            self.memoDidChanged(self.order);
        }
    }else{
        //向服务器提交
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改后的留言将覆盖之前的留言，确定修改吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self submitMemoEdit];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)submitMemoEdit
{
    NSString *text = self.textView.text;
    
    [ServerService editMallOrderMemo:self.order.order_id memo:text callBack:^(id obj) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        self.order.user_memo = text;
        if (self.memoDidChanged) {
            self.memoDidChanged(self.order);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];
}

@end
