//
//  CoachDataTableViewCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachDataTableViewCell.h"

@interface CoachDataTableViewCell()

@property (nonatomic,weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderTotalLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderNumLabel;
@property (nonatomic,weak) IBOutlet UILabel *teachingNumLabel;

@end

@implementation CoachDataTableViewCell

- (void)setRpt:(DataReport *)rpt{
    _rpt = rpt;
    if (_rpt) {
        _productNameLabel.text = _rpt.productName.length>0 ? _rpt.productName : @" ";
        _orderTotalLabel.text = [NSString stringWithFormat:@"%d",_rpt.orderAmount];
        _orderNumLabel.text = [NSString stringWithFormat:@"%d",_rpt.orderCount];
        _teachingNumLabel.text = [NSString stringWithFormat:@"%d",_rpt.teachCount];
    }
}

@end
