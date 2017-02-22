//
//  CoachOrderListCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/3.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachOrderListCell.h"

@interface CoachOrderListCell()

@property (nonatomic,weak) IBOutlet UILabel *orderTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderTimeLabel;
@property (nonatomic,weak) IBOutlet UIImageView *headImageView;
@property (nonatomic,weak) IBOutlet UILabel *memberNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderPriceLabel;
@property (nonatomic,weak) IBOutlet UILabel *orderStatusLabel;

@end

@implementation CoachOrderListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_headImageView radius:11 bordLineWidth:0 borderColor:[UIColor whiteColor]];
}

- (void)setOrderModel:(TeachingOrderModel*)orderModel{
    _orderModel = orderModel;
    if (_orderModel) {
        if (_orderTitleLabel) {
            _orderTitleLabel.text = _orderModel.productName.length>0 ? _orderModel.productName : @"";
        }
        _memberNameLabel.text = _orderModel.nickName.length>0 ? _orderModel.nickName : @"";
        _orderPriceLabel.text = [NSString stringWithFormat:@"¥%d",_orderModel.price];
        _orderTimeLabel.text = _orderModel.orderTime.length>0 ? _orderModel.orderTime : @"";
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:_orderModel.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];

        
        switch (_orderModel.orderState) {
            case 1:
                _orderStatusLabel.textColor = [UIColor colorWithRed:85/255.0 green:192/255.0 blue:234/255.0 alpha:1.0];
                _orderStatusLabel.text = @"教学中";
                break;
            case 2:
                _orderStatusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                _orderStatusLabel.text = @"已完成";
                break;
            case 3:
                _orderStatusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                _orderStatusLabel.text = @"已过期";
                break;
            case 4:
                _orderStatusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                _orderStatusLabel.text = @"已取消";
                break;
            case 6: //待付款
                _orderStatusLabel.textColor = [UIColor colorWithRed:85/255.0 green:192/255.0 blue:234/255.0 alpha:1.0];
                _orderStatusLabel.text = @"待付款";
                break;
            default:
                break;
        }
    }
}

@end
