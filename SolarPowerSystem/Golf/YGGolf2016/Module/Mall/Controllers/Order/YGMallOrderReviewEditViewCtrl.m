//
//  YGMallOrderReviewEditViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderReviewEditViewCtrl.h"
#import <YYText/YYText.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YGMallOrderModel.h"

#define kMaxWordCount 200

@interface YGMallOrderReviewEditViewCtrl ()
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIButton *midBtn;
@property (weak, nonatomic) IBOutlet UIButton *lowBtn;
@property (weak, nonatomic) IBOutlet UILabel *wordCounterLabel;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@end

@implementation YGMallOrderReviewEditViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RACSignal *signal = [self.inputTextView.rac_textSignal
                         map:^id(NSString *value) {
                             return @(value.length);
                         }];
    RAC(self.wordCounterLabel,textColor) = [signal
                                            map:^id(NSNumber *value) {
                                                return value.integerValue>kMaxWordCount?[UIColor redColor]:RGBColor(91, 91, 91, 1);
                                            }];
    RAC(self.wordCounterLabel,text) = [signal
                                       map:^id(NSNumber *value) {
                                           return [@(kMaxWordCount-value.integerValue) stringValue];
                                       }];
    RAC(self.submitBtn,enabled) = [signal
                                   map:^id(NSNumber *value) {
                                       return @(value.integerValue<=kMaxWordCount && value.integerValue>0);
                                   }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.inputTextView becomeFirstResponder];
}

- (IBAction)rankBtnAction:(UIButton *)btn
{
    self.goodBtn.selected = btn==self.goodBtn;
    self.midBtn.selected = btn==self.midBtn;
    self.lowBtn.selected = btn==self.lowBtn;
}

- (IBAction)submit:(id)sender
{
    [self.inputTextView endEditing:YES];
    
    NSString *text = self.inputTextView.text;
    if (text.length > kMaxWordCount) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"字数不能超过%d字",kMaxWordCount]];
    }else if(text.length == 0){
        [SVProgressHUD showInfoWithStatus:@"请填写评价内容"];
    }else{
        NSInteger level = [self rankLevel];
        if (level == 0) {
            [SVProgressHUD showInfoWithStatus:@"请选择一个评分"];
        }else{
            [self doSubmit:text level:level];
        }
    }
}

- (void)doSubmit:(NSString *)text level:(NSInteger)level
{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES];
    }else{
        [SVProgressHUD show];
        [ServerService addMallOrderReview:self.orderId commodity:self.commodity.commodity_id level:level content:text callBack:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:@"提交成功"];
            self.commodity.comment_status = YES;
            if (self.didReviewedCommodity) {
                self.didReviewedCommodity(self.orderId,self.commodity.commodity_id);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(id error) {
            [SVProgressHUD dismiss];
        }];
    }
}

- (NSInteger)rankLevel
{
    if (self.goodBtn.selected) {
        return 1;
    }
    if (self.midBtn.selected) {
        return 2;
    }
    if (self.lowBtn.selected) {
        return 3;
    }
    return 0;
}

@end
