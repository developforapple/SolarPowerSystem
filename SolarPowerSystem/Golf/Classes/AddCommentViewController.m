//
//  AddCommentViewController.m
//  Golf
//
//  Created by user on 13-6-5.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "AddCommentViewController.h"
#import "SearchService.h"

@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkStarButtonClick" object:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(starClickAction:) name:@"checkStarButtonClick" object:nil];

    
    
    
    _grassValue = 0;
    _serviceValue = 0;
    _difficultyValue = 0;
    _sceneryValue = 0;
    self.maxLength = 200;
    [wordsNumLabel setText:[NSString stringWithFormat:@"%d",self.maxLength]];
    
    self.textView.placeholderText = @"说点什么吧，人人为我，我为人人";
    [self.textView reloadInputViews];
    
    [_grassView setNib];
    [_serviceView setNib];
    [_difficultyView setNib];
    [_sceneryView setNib];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self rightButtonAction:@"提交"];
}

- (void)doRightNavAction{
    [self.textView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSString *errorMsg = nil;
        if (_difficultyValue<=0) {
            errorMsg = @"请对球场的设计进行评分";
        }else if (_grassValue<=0){
            errorMsg = @"请对球场的草坪进行评分";
        }else if (_sceneryValue<=0){
            errorMsg = @"请对球场的设施进行评分";
        }else if (_serviceValue<=0){
            errorMsg = @"请对球场的服务进行评分";
        }else if (self.textView.text.length == 0){
            errorMsg = @"您没有输入评价内容";
        }else if ([Utilities isBlankString:self.textView.text]){
            errorMsg = @"评价内容不能为空格";
        }else if (self.textView.text.length > self.maxLength){
            errorMsg = @"您输入的文字过长，不能超过200字符";
        }
        
        if (errorMsg) {
            [SVProgressHUD showErrorWithStatus:errorMsg];
            return;
        }
        
        if ([LoginManager sharedManager].loginState == NO) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
                [self submit];
            }];
        }else{
            [self submit];
        }
    });
}


- (void)submit{
    CommentModel *model = [[CommentModel alloc] init];
    model.grassLevel = _grassValue;
    model.serviceLevel = _serviceValue;
    model.difficultyLevel = _difficultyValue;
    model.sceneryLevel = _sceneryValue;
    model.commentContent = self.textView.text;
    
    ygweakify(self)
    [SearchService addClubCommentWithSessionId:[[LoginManager sharedManager] getSessionId] clubId:_userComment.clubId orderId:_userComment.orderId commentModel:model success:^(BOOL boolen) {
        if (boolen) {
            [SVProgressHUD showSuccessWithStatus:@"评论提交成功"];
            if ([_delegate respondsToSelector:@selector(AddCommentSuccessRefreshData)]) {
                [_delegate AddCommentSuccessRefreshData];
            }
            ygstrongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"评论失败"];
    }];
}

- (void)loginButtonPressed:(id)sender{
    [self doRightNavAction];
}


- (void)starClickAction:(NSNotification*)notice{
    NSDictionary *dic = [notice object];
    NSInteger tag = [[dic objectForKey:@"viewtag"] integerValue];
    int value = [[dic objectForKey:@"viewvalue"] intValue];
    
    if (tag==100){
        _grassValue = value;
        [grassStatus setText:[self getStatusText:value]];
    }
    else if (tag==200){
        _serviceValue = value;
        [serviceStatus setText:[self getStatusText:value]];
    }
    else if (tag==300){
        _difficultyValue = value;
        [difficultyStatus setText:[self getStatusText:value]];
    }
    else if (tag==400){
        _sceneryValue = value;
        [sceneryStatus setText:[self getStatusText:value]];
    }
}

- (NSString *)getStatusText:(int)value{
    switch (value) {
        case 1:
            return @"非常差";
            break;
        case 2:
            return @"差";
            break;
        case 3:
            return @"一般";
            break;
        case 4:
            return @"好";
            break;
        case 5:
            return @"非常好";
            break;
            
        default:
            break;
    }
    return nil;
}


- (void)textViewDidChange:(UITextView *)textView{
    NSInteger maxLength = MAX(0, self.maxLength - textView.text.length);
    [wordsNumLabel setText:[NSString stringWithFormat:@"%td",maxLength]];
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (text.length > 0) {
        NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSInteger maxLength = MAX(0, self.maxLength - toBeString.length);
        [wordsNumLabel setText:[NSString stringWithFormat:@"%td",maxLength]];
        if (toBeString.length > self.maxLength) {
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"文字不能超过%d",self.maxLength]];
            return NO;
        }
    }
    return YES;
}


@end
