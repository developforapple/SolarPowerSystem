//
//  YGMallOrderRefundReasonViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderRefundReasonViewCtrl.h"

@interface YGMallOrderRefundReasonViewCtrl () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *pickerViewPanel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) NSArray<NSString *> *reasonList;

@end

@implementation YGMallOrderRefundReasonViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bottomConstraint.constant = -260.f;
    
    self.reasonList = @[@"不想要了",
                        @"商品质量有问题",
                        @"其他原因",
                        @"重复下单/误下单",
                        @"商品买错规格/尺码"];
    
}

- (void)show
{
    [super show];
    
    NSInteger idx = [self.reasonList indexOfObject:self.reason];
    if (idx != NSNotFound) {
        [self.pickerView selectRow:idx inComponent:0 animated:YES];
    }
    
    [UIView animateWithDuration:.4f animations:^{
        self.bottomConstraint.constant = 0.f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:.2f animations:^{
        self.bottomConstraint.constant = -CGRectGetHeight(self.pickerViewPanel.frame);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [super dismiss];
    }];
}

- (IBAction)cancelActioj:(id)sender
{
    [self dismiss];
}

- (IBAction)doneAction:(id)sender
{
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    if (self.didSelectedReason) {
        self.didSelectedReason(self.reasonList[row]);
    }
    [self dismiss];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.reasonList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.reasonList[row];
}
@end
