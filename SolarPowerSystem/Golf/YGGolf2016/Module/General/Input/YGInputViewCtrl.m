//
//  YGInputViewCtrl.m
//  Golf
//
//  Created by Main on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGInputViewCtrl.h"

@interface YGInputViewCtrl ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (strong, nonatomic) IBOutlet UIView *viewTextFieldContainer;
@property (strong, nonatomic) IBOutlet UIView *viewTextViewContainer;


@end

@implementation YGInputViewCtrl



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self rightButtonAction:@"保存"];
    
    if (self.isTextField) {
        self.tableView.tableHeaderView = self.viewTextFieldContainer;
        self.textField.placeholder = self.placeHolderText;
        self.textField.text = self.defaultText;
        [self.textField becomeFirstResponder];
        self.textField.delegate = self;
        [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }else{
        self.tableView.tableHeaderView = self.viewTextViewContainer;
        self.textView.text = self.defaultText;
        self.textView.placeholderText = self.placeHolderText;
        [self textViewDidChange:self.textView];
    }
    [self.tableView setContentInset:(UIEdgeInsetsMake(20, 0, 0, 0))];
}

- (void)textFieldDidChange:(UITextField *)textField{
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > self.maxLength) {
                textField.text = [toBeString substringToIndex:self.maxLength];
            }
        }
    } else {
        if (toBeString.length > self.maxLength) {
            textField.text = [toBeString substringToIndex:self.maxLength];
        }
    }
    if ([textField.text stringByTrim].length > self.maxLength) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"您输入的内容超过%d个字符，请重新输入！",self.maxLength]];
    }
}

- (void)textViewDidChange:(YYTextView *)textView
{
    NSString  *text = textView.text;
    NSInteger count = text.length;
    
    if (count > self.maxLength)
    {
        //截取到最大位置的字符
        [textView setText:[text substringToIndex:self.maxLength]];
    }
    
    //不让显示负数 口口日
    self.labelCount.text = [NSString stringWithFormat:@"%ld",MAX(0,self.maxLength - count)];
}


- (void)doRightNavAction{
    NSString *text = nil;
    if (self.isTextField) {
        text = self.textField.text;
    }else{
        text = self.textView.text;
    }
    if ([text stringByTrim].length > self.maxLength) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"您输入的内容超过%d个字符，请重新输入！",self.maxLength]];
        return;
    }
    if(self.blockReturn){
        self.blockReturn(text);
    }
    [self back];
}




#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UITableViewCell new];
}
@end
