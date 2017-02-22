//
//  YGOrderTeachingCell.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderTeachingCell.h"
#import "YGOrderHandlerTeaching.h"

NSString *const kYGOrderTeachingCell = @"YGOrderTeachingCell";

@interface YGOrderTeachingCell ()
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *coachNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *yunbiBtn;
@property (strong, nonatomic) YGOrderHandlerTeaching *handler;
@end

@implementation YGOrderTeachingCell

+ (CGFloat)estimatedRowHeight
{
    return 200.f;
}

- (TeachingOrderModel *)order
{
    id o = [super order];
    if (![o isKindOfClass:[TeachingOrderModel class]]) return nil;
    return o;
}

- (void)configureStatusPanel
{
    [super configureStatusPanel];
    
    TeachingOrderModel *order = [self order];
    
    NSString *price;
    switch (order.orderState) {
        case YGTeachingOrderStatusTypeWaitPay:{
            self.statusLabel.text = @"待付款";
            self.statusLabel.textColor = kYGStatusOrangeColor;
            price = [NSString stringWithFormat:@"待付款:￥%d",order.price];
        }   break;
        case YGTeachingOrderStatusTypeExpired:{
            self.statusLabel.text = @"已过期";
            self.statusLabel.textColor = kYGStatusGrayColor;
            price = [NSString stringWithFormat:@"实付款:￥%d",order.price];
        }   break;
        case YGTeachingOrderStatusTypeCanceled:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusGrayColor;
            price = [NSString stringWithFormat:@"订单总计:￥%d",order.price];
        }   break;
        case YGTeachingOrderStatusTypeTeaching:{
            self.statusLabel.text = @"教学中";
            self.statusLabel.textColor = kYGStatusBlueColor;
            price = [NSString stringWithFormat:@"实付款:￥%d",order.price];
        }   break;
        case YGTeachingOrderStatusTypeCompleted:{
            self.statusLabel.text = @"交易完成";
            self.statusLabel.textColor = kYGStatusBlueColor;
            price = [NSString stringWithFormat:@"实付款:￥%d",order.price];
        }   break;
    }
    self.priceTitleLabel.text = price;
    self.subPriceTitleLabel.text= nil;
    
    BOOL yunbi = order.giveYunbi>0;
    self.yunbiBtn.hidden = !yunbi;
    if (yunbi) {
        [self.yunbiBtn setTitle:[NSString stringWithFormat:@"返%d",order.giveYunbi] forState:UIControlStateNormal];
    }
    self.subPricePanelVisible = yunbi;
}

- (void)configureContentPanel
{
    [super configureContentPanel];
    TeachingOrderModel *order = [self order];
    self.classNameLabel.text = order.productName;
    self.orderTimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",order.orderTime];
    self.coachNameLabel.text = order.nickName;
}

- (void)configureActionPanel
{
    [super configureActionPanel];
    
    TeachingOrderModel *order = [self order];
    YGOrderTeachingAction actionType = YGOrderTeachingAction_Base;
    switch (order.orderState) {
        case YGTeachingOrderStatusTypeWaitPay:{
            actionType = YGOrderTeachingAction_Pay;
        } break;
        case YGTeachingOrderStatusTypeCanceled:
        case YGTeachingOrderStatusTypeExpired:
        case YGTeachingOrderStatusTypeTeaching:
        case YGTeachingOrderStatusTypeCompleted:{
        }   break;
    }
    BOOL actionPanelVisible = self.inManagerList || actionType!=YGOrderTeachingAction_Base;
    [self setActionPanelVisible:actionPanelVisible];
    if (actionPanelVisible) {
        [self setDeleteBtnVisible:NO];
        self.actionBtn_1.tag = actionType;
        self.actionBtn_1.hidden = actionType==YGOrderTeachingAction_Base;
        [self.actionBtn_1 setTitle:[YGOrderHandlerTeaching actionTitleString:actionType] forState:UIControlStateNormal];
        self.actionBtn_1.selected = actionType==YGOrderTeachingAction_Pay;
        self.actionBtn_1.highlighted = NO;
    }
}

- (void)actionBtn1Action:(UIButton *)btn
{
    [super actionBtn1Action:btn];
    [self.handler handleAction:btn.tag];
}

- (void)deleteBtnAction:(UIButton *)btn
{
    [super deleteBtnAction:btn];
    [self.handler handleAction:YGOrderTeachingAction_Delete];
}

- (YGOrderHandlerTeaching *)handler
{
    if (!_handler || _handler.order != self.order) {
        _handler = [YGOrderHandlerTeaching handlerWithOrder:self.order];
        _handler.viewCtrl = [self viewController];
    }
    return _handler;
}

@end
