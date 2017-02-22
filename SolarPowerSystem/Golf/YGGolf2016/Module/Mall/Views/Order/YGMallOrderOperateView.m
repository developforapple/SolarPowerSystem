//
//  YGMallOrderOperateView.m
//  Golf
//
//  Created by bo wang on 2016/10/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderOperateView.h"
#import "YGOrderHandlerMall.h"
#import "CustomerServiceViewCtrl.h"

#define kInvisibleBtnTag (-1)

@interface YGMallOrderOperateView ()
@property (strong, nonatomic) YGOrderHandlerMall *handler;
@end

@implementation YGMallOrderOperateView

- (void)configureWithOrder:(YGMallOrderModel *)order
{
    _order = order;
    
    void (^setupBtn)(UIButton *,BOOL, NSString *,BOOL,NSUInteger) = ^(UIButton *btn,BOOL hidden, NSString *title,BOOL highlight,NSUInteger tag){
        if (!hidden) {
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:highlight?[UIColor whiteColor]:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];
            btn.backgroundColor = highlight?MainHighlightColor:[UIColor whiteColor];
            btn.layer.borderColor = highlight?NULL:[RGBColor(230, 230, 230, 1) CGColor];
            btn.layer.borderWidth = highlight?0.f:.5f;
            btn.layer.cornerRadius = 2.f;
            btn.layer.masksToBounds = YES;
        }
        btn.tag = tag;
        btn.hidden = hidden;
    };
    
    YGMallOrderStatus status = self.order.order_state;
    
    // 父订单不显示 删除订单、申请退款、取消申请退款 这三个按钮
    BOOL isParentOrder = self.order.orderType == 2;
    
    if (isParentOrder) {
        if (status == YGMallOrderStatusUnpaid) {
            setupBtn(self.rightBtn, NO, @"立即支付", YES,   YGMallOrderOperatePay);
            setupBtn(self.middleBtn,NO, @"联系客服", NO,    YGMallOrderOperateService);
            setupBtn(self.leftBtn,  NO, @"取消订单", NO,    YGMallOrderOperateCancel);
        }else{
            setupBtn(self.rightBtn, NO, @"联系客服", NO,    YGMallOrderOperateService);
            setupBtn(self.middleBtn,YES, @"", NO,    kInvisibleBtnTag);
            setupBtn(self.leftBtn,  YES, @"", NO,    kInvisibleBtnTag);
        }
    }else{
        switch (status) {
            case YGMallOrderStatusUnpaid:{//待支付
                setupBtn(self.rightBtn, NO, @"立即支付", YES,   YGMallOrderOperatePay);
                setupBtn(self.middleBtn,NO, @"联系客服", NO,    YGMallOrderOperateService);
                setupBtn(self.leftBtn,  NO, @"取消订单", NO,    YGMallOrderOperateCancel);
            }   break;
            case YGMallOrderStatusPaid:{//等待发货
                setupBtn(self.rightBtn, NO, @"申请退款", NO,    YGMallOrderOperateApplyRefund);
                setupBtn(self.middleBtn,NO, @"联系客服", NO,    YGMallOrderOperateService);
                setupBtn(self.leftBtn,  YES, @"", NO,    kInvisibleBtnTag);
            }   break;
            case YGMallOrderStatusShipped:{//已发货
                setupBtn(self.rightBtn, NO, @"确认收货", YES,   YGMallOrderOperateReceived);
                setupBtn(self.middleBtn,NO, @"申请退款", NO,    YGMallOrderOperateApplyRefund);
                setupBtn(self.leftBtn,  YES,@" ",       NO,    kInvisibleBtnTag);
            }   break;
            case YGMallOrderStatusReceived:{//交易成功 待评价
                setupBtn(self.rightBtn, NO, @"立即评价", YES,   YGMallOrderOperateReview);
                setupBtn(self.middleBtn,NO, @"联系客服", NO,    YGMallOrderOperateService);
                setupBtn(self.leftBtn,  NO, @"删除订单", NO,    YGMallOrderOperateDelete);
            }   break;
            case YGMallOrderStatusReviewed:{// 已评价
                setupBtn(self.rightBtn, NO, @"联系客服", NO,   YGMallOrderOperateService);
                setupBtn(self.middleBtn,NO, @"删除订单", NO,    YGMallOrderOperateDelete);
                setupBtn(self.leftBtn,  YES,@"",      NO,    kInvisibleBtnTag);
            }   break;
            case YGMallOrderStatusClosed:{//订单已关闭
                setupBtn(self.rightBtn, NO, @"再次购买", YES,   YGMallOrderOperateBuyAgain);
                setupBtn(self.middleBtn,NO, @"联系客服", NO,    YGMallOrderOperateService);
                setupBtn(self.leftBtn,  NO, @"删除订单", NO,    YGMallOrderOperateDelete);
            }   break;
            case YGMallOrderStatusApplyRefund:{//已申请退款
                setupBtn(self.rightBtn, NO, @"取消申请", NO,    YGMallOrderOperateCancelRefund);
                setupBtn(self.middleBtn,NO, @"联系客服", NO,    YGMallOrderOperateService);
                setupBtn(self.leftBtn,  YES,@"", NO,    kInvisibleBtnTag);
            }   break;
            case YGMallOrderStatusRefunded:{//已退款
                setupBtn(self.rightBtn, NO, @"联系客服", NO,    YGMallOrderOperateService);
                setupBtn(self.middleBtn,NO, @"删除订单", NO,    YGMallOrderOperateDelete);
                setupBtn(self.leftBtn,  YES,@"", NO,    kInvisibleBtnTag);
            }   break;
            case YGMallOrderStatusCreating:break;
            case YGMallOrderStatusCreatingRefund:break;
        }
    }
}

- (IBAction)btnAction:(UIButton *)btn
{
    if (btn.tag == kInvisibleBtnTag) return;
    
    if (self.willOperateOrder) {
        self.willOperateOrder(self.order,(YGMallOrderOperate)btn.tag);
    }

    YGMallOrderOperate operate = btn.tag;
    switch (operate) {
        case YGMallOrderOperateCancel:      [self.handler cancel];  break;
        case YGMallOrderOperatePay:         [self.handler pay];     break;
        case YGMallOrderOperateService:     [CustomerServiceViewCtrl show]; break;
        case YGMallOrderOperateApplyRefund: [self.handler createRefund];    break;
        case YGMallOrderOperateCancelRefund:[self.handler createCancelRefund];break;
        case YGMallOrderOperateReceived:    [self.handler confirmReceived]; break;
        case YGMallOrderOperateDelete:      [self.handler deleteOrder];     break;
        case YGMallOrderOperateReview:      [self.handler review];    break;
        case YGMallOrderOperateBuyAgain:    [self.handler buyAgain];  break;
    }
}

- (YGOrderHandlerMall *)handler
{
    if (!_handler) {
        _handler = [YGOrderHandlerMall handlerWithOrder:self.order];
        _handler.viewCtrl = [self viewController];
    }
    return _handler;
}

@end
