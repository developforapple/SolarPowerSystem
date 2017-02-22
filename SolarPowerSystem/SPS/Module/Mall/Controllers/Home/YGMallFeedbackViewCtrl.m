//
//  YGMallFeedbackViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 12-8-28.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "YGMallFeedbackViewCtrl.h"
#import "GolfService.h"

@interface YGMallFeedbackViewCtrl ()

@end

@implementation YGMallFeedbackViewCtrl
@synthesize isCommodity = _isCommodity;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self rightButtonAction:@"提交"];
    
    if (self.isCommodity) {
        descriptionLabel.hidden = NO;
        holdPlaceLabel.text = @"请输入您想购买的商品，我们将尽快上架";
    }else{
        holdPlaceLabel.text = @"请输入您的意见，我们非常乐于倾听。";
        descriptionLabel.hidden = YES;
    }
    
    scrollView.frame = CGRectMake(0, 0, Device_Width, Device_Height-64.f);
    scrollView.contentSize = CGSizeMake(Device_Width, Device_Height+20.f);
    
    NSString *defaultFeedContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFeedBackContent"];
    textView.text = defaultFeedContent;
    [textView becomeFirstResponder];
    
    if (textView.text.length>0) {
        holdPlaceLabel.hidden = YES;
    }else{
        holdPlaceLabel.hidden = NO;
    }
    
    phoneNumTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    NSString *userPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"FeedBackPhoneNum"];
    if (!userPhoneNum||userPhoneNum.length==0) {
        userPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    }
    if (userPhoneNum&&userPhoneNum.length>0) {
        phoneNumTf.text = userPhoneNum;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSString * beString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([beString length] > 200) {
        textView.text = [toBeString substringToIndex:200];
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)txtView{
    if (txtView.text.length>0) {
        holdPlaceLabel.hidden = YES;
    }else{
        holdPlaceLabel.hidden = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString * beString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    int length = 12;
    
    if ([beString length] > length) {
        textField.text = [toBeString substringToIndex:length];
        return NO;
    }
    return YES;
}

- (void)doLeftNavAction
{
    [super doLeftNavAction];
    
    if (textView.text.length>0) {
        [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"UserFeedBackContent"];
    }
    if (phoneNumTf.text.length>0) {
        [[NSUserDefaults standardUserDefaults] setObject:phoneNumTf.text forKey:@"FeedBackPhoneNum"];
    }
}

- (void)doRightNavAction
{
    [textView resignFirstResponder];
    [phoneNumTf resignFirstResponder];
    
    NSString *errorMsg = nil;
    if ([Utilities isBlankString:textView.text]) {
        errorMsg = self.isCommodity ? @"请输入您想要购买的商品" : @"请输入您的意见";
    }else if ([Utilities isBlankString:phoneNumTf.text]){
        errorMsg = @"请输入手机号码";
    }else if (![Utilities phoneNumMatch:phoneNumTf.text]){
        errorMsg = @"手机号码不正确";
    }
    if (errorMsg) {
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    [self feedBackAction];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FeedBackPhoneNum"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserFeedBackContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self back];
}

- (void)feedBackAction{
    [[ServiceManager serviceManagerInstance] feedBack:phoneNumTf.text withContents:textView.text callBack:^(BOOL boolen) {
        if (boolen) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"提交成功，谢谢您的反馈" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
