//
//  YGMallOrderStatusView.h
//  Golf
//
//  Created by bo wang on 2016/10/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallOrderModel.h"

/**
 商城确认订单、订单详情、申请退款中，顶部显示订单状态的头部视图
 */
@interface YGMallOrderStatusView : UIView

@property (weak, nonatomic) IBOutlet UIView *statusPanel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *refundLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelRefundLabel;

@property (weak, nonatomic) IBOutlet UIView *infoPanel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@property (strong, readonly, nonatomic) YGMallOrderModel *order;
- (void)configureWithOrder:(YGMallOrderModel *)order;

@end
