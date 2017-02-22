//
//  YGMallOrderStatusView.m
//  Golf
//
//  Created by bo wang on 2016/10/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderStatusView.h"

@implementation YGMallOrderStatusView

- (void)configureWithOrder:(YGMallOrderModel *)order
{
    _order = order;
    
    BOOL isCreatingRefund = order.tempStatus == YGMallOrderStatusCreatingRefund;

    self.orderNumberLabel.text = [NSString stringWithFormat:@"%@%ld",isCreatingRefund?@"父订单号：":@"订单号：",(long)order.order_id];
    self.orderTimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",order.order_time];
    
    switch (order.tempStatus) {
        case YGMallOrderStatusUnpaid:{
            self.statusLabel.text = @"等待支付";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_uncompleted"];
        }   break;
        case YGMallOrderStatusPaid:{
            self.statusLabel.text = @"等待发货";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_uncompleted"];
        }   break;
        case YGMallOrderStatusShipped:{
            self.statusLabel.text = @"等待确认收货";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_uncompleted"];
        }   break;
        case YGMallOrderStatusReceived:{
            self.statusLabel.text = @"交易成功";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_completed"];
        }   break;
        case YGMallOrderStatusReviewed:{
            self.statusLabel.text = @"交易成功";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_completed"];
        }   break;
        case YGMallOrderStatusClosed:{
            self.statusLabel.text = @"订单关闭";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_uncompleted"];
        }   break;
        case YGMallOrderStatusApplyRefund:{
            self.statusLabel.text = @"退款申请中";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_uncompleted"];
        }   break;
        case YGMallOrderStatusRefunded:{
            self.statusLabel.text = @"退款成功";
            self.statusLabel.hidden = NO;
            self.refundLabel.hidden = YES;
            self.cancelRefundLabel.hidden = YES;
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_refunded"];
        }   break;
        case YGMallOrderStatusCreating:{
            // 不显示状态view
        }   break;
        case YGMallOrderStatusCreatingRefund:{
            self.statusLabel.hidden = YES;
            self.refundLabel.hidden = ![self.order isCreatingRefund];
            self.cancelRefundLabel.hidden = ![self.order isCreatingCancelRefund];
            self.statusImageView.image = [UIImage imageNamed:@"icon_mall_order_status_applyrefund"];
        }   break;
        default:
            break;
    }
}

@end
