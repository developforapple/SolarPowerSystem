//
//  CoachDataHead.m
//  Golf
//
//  Created by 黄希望 on 15/6/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachDataHead.h"

@interface CoachDataHead ()

@property (nonatomic,weak) IBOutlet UILabel *orderAmountLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderCountLabel;
@property (nonatomic,weak) IBOutlet UILabel *teachCountLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderAmountTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *noRecordLabel;
@property (nonatomic,weak) IBOutlet UIView *bottomView;

@end

@implementation CoachDataHead

- (void)loadData{
    _orderCountLabel.text = [NSString stringWithFormat:@"%d",_orderCount];
    _teachCountLabel.text = [NSString stringWithFormat:@"%d",_teachCount];
    
    if (_orderTotal+_orderCount+_teachCount==0) {
        _bottomView.hidden = YES;
        _orderAmountTitleLabel.hidden = YES;
        _orderAmountLabel.hidden = YES;
        _noRecordLabel.hidden = NO;
    }else{
        _bottomView.hidden = NO;
        _orderAmountTitleLabel.hidden = NO;
        _orderAmountLabel.hidden = NO;
        _noRecordLabel.hidden = YES;
        if (Device_Width == 414) {
            _orderAmountLabel.font = [UIFont systemFontOfSize:54];
        }else{
            _orderAmountLabel.font = [UIFont systemFontOfSize:50];
        }
        _orderAmountLabel.text = [NSString stringWithFormat:@"%d",_orderTotal];
        _orderAmountLabel.textColor = [UIColor whiteColor];
    }
}

@end
