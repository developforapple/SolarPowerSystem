//
//  YGBindingListPhoneCell.m
//  Golf
//
//  Created by liangqing on 16/9/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBindingListPhoneCell.h"
#import "YGBindingPhoneViewCtrl.h"
#import "CCAlertView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@implementation YGBindingListPhoneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if ([LoginManager sharedManager].session.mobilePhone.length > 0 && [LoginManager sharedManager].session.mobilePhone) {//如果有mobilePhone表示已绑定手机号
        [self exchangePhoneBinding];
    }else{
        [self phoneBinding];
    }
    
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ChangeBindingSuccess" object:nil] subscribeNext:^(NSNotification *notification) {
        ygstrongify(self);
        self.labelPhone.text = [NSString stringWithFormat:@"手机号 (%@)",[LoginManager sharedManager].session.mobilePhone];
        [self exchangePhoneBinding];
    }];
}

/**
 换绑按钮设置
 */
- (void)exchangePhoneBinding{
    self.labelPhone.text = [NSString stringWithFormat:@"手机号 (%@)",[LoginManager sharedManager].session.mobilePhone];
    [self.buttonBinding setTitle:@"换绑" forState:0];
    self.buttonBinding.backgroundColor = [UIColor whiteColor];
    [self.buttonBinding setTitleColor:[UIColor colorWithHexString:@"249df3"] forState:0];
    self.buttonBinding.layer.cornerRadius = 5;
    self.buttonBinding.layer.borderWidth = 0.5;
    self.buttonBinding.layer.borderColor = [UIColor colorWithHexString:@"249df3"].CGColor;
    [self.buttonBinding removeTarget:self action:@selector(bindingPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBinding addTarget:self action:@selector(exchangeBinding) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBinding setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.buttonBinding setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.buttonBinding setImage:nil forState:0];
}

/**
 绑定换绑按钮设置
 */
- (void)phoneBinding{
    self.labelPhone.text = [NSString stringWithFormat:@"手机号"];
    [self.buttonBinding setTitle:@"绑定" forState:0];
    [self.buttonBinding setTitleColor:[UIColor whiteColor] forState:0];
    [self.buttonBinding setImage:[UIImage imageNamed:@"plus"] forState:0];
    self.buttonBinding.backgroundColor = [UIColor colorWithHexString:@"249df3"];
    self.buttonBinding.layer.cornerRadius = 5;
    [self.buttonBinding removeTarget:self action:@selector(exchangeBinding) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBinding addTarget:self action:@selector(bindingPhone) forControlEvents:UIControlEventTouchUpInside];
}

/**
 换绑
 */
- (void)exchangeBinding{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"手机账户换绑" message:@"更换手机号后现手机号将不能作为登录方式登录该账户，确定换绑新手机号？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    ygweakify(self);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"换绑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ygstrongify(self);
        YGBindingPhoneViewCtrl *vc = [YGBindingPhoneViewCtrl instanceFromStoryboard];
        vc.isExchangePhoneBinding = YES;
        [self.controller.navigationController pushViewController:vc animated:YES];
    }];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self.controller presentViewController:alert animated:YES completion:nil];
}

/**
 绑定
 */
- (void)bindingPhone{
    
    YGBindingPhoneViewCtrl *vc = [YGBindingPhoneViewCtrl instanceFromStoryboard];
    [self.controller.navigationController pushViewController:vc animated:YES];
}

@end
