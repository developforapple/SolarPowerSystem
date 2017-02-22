//
//  YGTeachBookingOrderTableViewCell.m
//  Golf
//
//  Created by bo wang on 16/9/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderTeachBookingCell.h"
#import "YGThrift+Teaching.h"

#import "PayOnlineViewController.h"
#import "YGOrderHandlerTeachBooking.h"

NSString  *const kYGOrderTeachBookingCell = @"YGOrderTeachBookingCell";

@interface YGOrderTeachBookingCell ()
@property (weak, nonatomic) IBOutlet UIButton *yunbiBtn;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderSpecLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (strong, nonatomic) YGOrderHandlerTeachBooking *handler;
@end

@implementation YGOrderTeachBookingCell

- (VirtualCourseOrderBean *)order
{
    id o = [super order];
    if (![o isKindOfClass:[VirtualCourseOrderBean class]]) return nil;
    return o;
}

- (void)configureStatusPanel
{
    [super configureStatusPanel];
    
    VirtualCourseOrderBean *order = [self order];
    NSInteger price = order.price/100;
    enum OrderStatus status = order.orderStatus;
    switch (status) {
        case OrderStatus_WAIT_PAY:{
            self.statusLabel.text = @"待付款";
            self.statusLabel.textColor = kYGStatusOrangeColor;
            self.priceTitleLabel.text = [NSString stringWithFormat:@"待付款:￥%ld",(long)price];
        }   break;
        case OrderStatus_WAIT_COMPLETE:{
            self.statusLabel.text = @"待使用";
            self.statusLabel.textColor = kYGStatusOrangeColor;
            self.priceTitleLabel.text = [NSString stringWithFormat:@"实付款:￥%ld",(long)price];
        }   break;
        case OrderStatus_COMPLETED:{
            self.statusLabel.text = @"交易成功";
            self.statusLabel.textColor = kYGStatusBlueColor;
            self.priceTitleLabel.text = [NSString stringWithFormat:@"实付款:￥%ld",(long)price];
        }   break;
        case OrderStatus_CLOSED:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusGrayColor;
            self.priceTitleLabel.text = [NSString stringWithFormat:@"订单总计:￥%ld",(long)price];
        }   break;
        case OrderStatus_RETURNED:{
            self.statusLabel.text = @"已退款";
            self.statusLabel.textColor = kYGStatusRedColor;
            self.priceTitleLabel.text = [NSString stringWithFormat:@"已退款:￥%ld",(long)price];
        }   break;
    }
    [self setSubPricePanelVisible:NO];
}

- (void)configureContentPanel
{
    [super configureContentPanel];
    
    VirtualCourseOrderBean *order = [self order];
    NSInteger specCount = order.seatSpecList.count;
    self.courseNameLabel.text = order.courseTitle;
    self.orderSpecLabel.text = [NSString stringWithFormat:@"预定打位：%ld",(long)specCount];
    self.orderTimeLabel.text = [NSString stringWithFormat:@"打球时间：%@",[order orderTimeDescInOrderListCell]];
}

- (void)configureActionPanel
{
    [super configureActionPanel];
    
    VirtualCourseOrderBean *order = [self order];
    enum OrderStatus status = order.orderStatus;
    
    YGOrderTeachBookingAction actionType = YGOrderTeachBookingAction_Base;
    switch (status) {
        case OrderStatus_WAIT_PAY:{
            actionType = YGOrderTeachBookingAction_Pay;
        }   break;
        case OrderStatus_CLOSED:
        case OrderStatus_RETURNED:
        case OrderStatus_COMPLETED:
        case OrderStatus_WAIT_COMPLETE:break;
    }
    BOOL actionPanelVisible = self.inManagerList || actionType!=YGOrderTeachBookingAction_Base;
    [self setActionPanelVisible:actionPanelVisible];
    if (actionPanelVisible) {
        [self setDeleteBtnVisible:NO];
        self.actionBtn_1.tag = actionType;
        self.actionBtn_1.hidden = actionType==YGOrderTeachBookingAction_Base;
        [self.actionBtn_1 setTitle:[YGOrderHandlerTeachBooking actionTitleString:actionType] forState:UIControlStateNormal];
        self.actionBtn_1.selected = actionType==YGOrderTeachBookingAction_Pay;
        self.actionBtn_1.highlighted = NO;
    }
}

- (YGOrderHandlerTeachBooking *)handler
{
    if (!_handler || _handler.order != self.order) {
        _handler = [YGOrderHandlerTeachBooking handlerWithOrder:self.order];
        _handler.viewCtrl = [self viewController];
    }
    return _handler;
}

- (void)actionBtn1Action:(UIButton *)btn
{
    [super actionBtn1Action:btn];
    [self.handler handleAction:btn.tag];
}

@end
