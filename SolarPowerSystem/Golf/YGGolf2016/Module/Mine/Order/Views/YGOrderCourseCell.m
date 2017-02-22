//
//  YGOrderCourseCell.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderCourseCell.h"
#import "OrderModel.h"
#import "YGOrderHandlerCourse.h"
#import "YGOrderHandlerTourPackage.h"

NSString *const kYGOrderCourseCell = @"YGOrderCourseCell";

@interface YGOrderCourseCell ()
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPersonCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *payModelBtn;
@property (weak, nonatomic) IBOutlet UIButton *yunbiBtn;
@property (strong, nonatomic) YGOrderHandlerCourse *handler;
@property (strong, nonatomic) YGOrderHandlerTourPackage *packageHandler;
@end

@implementation YGOrderCourseCell

+ (CGFloat)estimatedRowHeight
{
    return 202.f;
}

- (OrderModel *)order
{
    id o = [super order];
    if (![o isKindOfClass:[OrderModel class]]) return nil;
    return o;
}

- (void)configureStatusPanel
{
    [super configureStatusPanel];
    
    OrderModel *order = [self order];
    if (order.orderType == 3) {
        //旅行套餐
        [self configureTourPackageStatusPanel];
        return;
    }
    
    OrderStatusEnum status = order.orderStatus;
    
    NSInteger orderTotal = order.orderTotal;
    NSInteger payTotal = order.payTotal;
    
    switch (status) {
        case OrderStatusNew:{
            self.statusLabel.text = @"待打球";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case OrderStatusSuccess:{
            self.statusLabel.text = @"完成消费";
            self.statusLabel.textColor = kYGStatusBlueColor;
        }   break;
        case OrderStatusNotPresent:{
            self.statusLabel.text = @"未到场";
            self.statusLabel.textColor = kYGStatusGrayColor;
        }   break;
        case OrderStatusCancel:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusGrayColor;
        }   break;
        case OrderStatusWaitEnsure:{
            self.statusLabel.text = @"待确认";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case OrderStatusWaitPay:{
            self.statusLabel.text = @"待付款";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case OrderStatusSendRepeal:{
            self.statusLabel.text = @"订单取消处理中";
            self.statusLabel.textColor = kYGStatusRedColor;
        }   break;
        case OrderStatusRepeal:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusRedColor;
        }   break;
    }
    
    NSString *price,*subPrice;
    
    switch (order.payType) {
        case PayTypeVip://会员球场
        case PayTypeDeposit:{
            //球场现付
            price = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case PayTypeOnline:
        case PayTypeOnlinePart:{
            switch (status) {
                case OrderStatusNew: //待打球
                case OrderStatusWaitEnsure://待确认
                case OrderStatusWaitPay:{//待支付
                    price = [NSString stringWithFormat:@"在线预付:￥%ld",(long)payTotal];
                    subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
                }   break;
                case OrderStatusCancel:{//已取消
                    price = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
                    break;
                }
                case OrderStatusSendRepeal:{//待退款
                    price = [NSString stringWithFormat:@"待退款:￥%ld",(long)payTotal];
                }   break;
                case OrderStatusRepeal:{//已退款
                    price = [NSString stringWithFormat:@"已退款:￥%ld",(long)payTotal];
                }   break;
                case OrderStatusSuccess://已完成
                case OrderStatusNotPresent:{//未到场
                    price = [NSString stringWithFormat:@"订单总计:￥%ld",(long)payTotal];
                }   break;
            }
        }   break;
    }
    
    self.priceTitleLabel.text = price;
    self.subPriceTitleLabel.text = subPrice;
    self.subPriceTitlePanel.horizontalZero_ = subPrice.length == 0;
    
    BOOL hasYunbi = order.yunbi>0;
    self.yunbiBtn.hidden = !hasYunbi;
    if (hasYunbi) {
        [self.yunbiBtn setTitle:[NSString stringWithFormat:@"返%d",order.yunbi] forState:UIControlStateNormal];
    }
    [self setSubPricePanelVisible:subPrice.length!=0||hasYunbi];
}

- (void)configureTourPackageStatusPanel
{
    OrderModel *order = [self order];
    OrderStatusEnum status = order.orderStatus;
    
    NSInteger orderTotal = order.orderTotal;
    NSInteger payTotal = order.payTotal;
    
    switch (status) {
        case OrderStatusNew:{
            self.statusLabel.text = @"支付成功";
            self.statusLabel.textColor = kYGStatusBlueColor;
        }   break;
        case OrderStatusSuccess:{
            self.statusLabel.text = @"交易完成";
            self.statusLabel.textColor = kYGStatusBlueColor;
        }   break;
        case OrderStatusNotPresent:{
            self.statusLabel.text = @"未到场";
            self.statusLabel.textColor = kYGStatusGrayColor;
        }   break;
        case OrderStatusCancel:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusGrayColor;
        }   break;
        case OrderStatusWaitEnsure:{
            self.statusLabel.text = @"待确认";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case OrderStatusWaitPay:{
            self.statusLabel.text = @"待付款";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case OrderStatusSendRepeal:{
            self.statusLabel.text = @"订单取消处理中";
            self.statusLabel.textColor = kYGStatusRedColor;
        }   break;
        case OrderStatusRepeal:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusRedColor;
        }   break;
    }
    
    NSString *price,*subPrice;
    switch (status) {
        case OrderStatusNew:{
            price = [NSString stringWithFormat:@"实付款:￥%d",payTotal];
            subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusSuccess:{
            price = [NSString stringWithFormat:@"实付款:￥%d",payTotal];
            subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusNotPresent:{
            price = [NSString stringWithFormat:@"实付款:￥%d",payTotal];
            subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusCancel:{
            price = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusWaitEnsure:{
            price = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusWaitPay:{
            price = [NSString stringWithFormat:@"待付款:￥%d",payTotal];
            subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusSendRepeal:{
            price = [NSString stringWithFormat:@"实付款:￥%d",payTotal];
            subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
        case OrderStatusRepeal:{
            price = [NSString stringWithFormat:@"待退款:￥%d",payTotal];
            subPrice = [NSString stringWithFormat:@"订单总计:￥%ld",(long)orderTotal];
        }   break;
    }
    
    self.priceTitleLabel.text = price;
    self.subPriceTitleLabel.text = subPrice;
    self.subPriceTitlePanel.horizontalZero_ = subPrice.length == 0;
    
    BOOL hasYunbi = NO;
    self.yunbiBtn.hidden = !hasYunbi;
    [self setSubPricePanelVisible:subPrice.length!=0||hasYunbi];
}

- (void)configureContentPanel
{
    [super configureContentPanel];
    
    OrderModel *order = [self order];
    if (!order) return;
    
    if (order.orderType == 3) {
        [self configureTourPackageContentPanel];
    }else{
        if (order.packageId <= 0) {
            self.courseNameLabel.text = order.clubName;
            self.courseDateLabel.text = [NSString stringWithFormat:@"开球时间：%@ %@",order.teetimeDate,order.teetimeTime];
        }else{
            self.courseNameLabel.text = order.packageName;
            self.courseDateLabel.text = [NSString stringWithFormat:@"到达时间：%@",order.teetimeDate];
        }
        self.orderPersonCountLabel.text = [NSString stringWithFormat:@"订单人数：%d",order.memberNum];
        self.payModelBtn.hidden = NO;
        [self.payModelBtn setTitle:PayTypeString(order.payType) forState:UIControlStateNormal];
    }
}

- (void)configureTourPackageContentPanel
{
    OrderModel *order = [self order];
    if (!order) return;
    
    self.courseNameLabel.text = order.packageName;
    self.courseDateLabel.text = [NSString stringWithFormat:@"出发日期：%@",order.teetimeDate];
    self.orderPersonCountLabel.text = [NSString stringWithFormat:@"出行人数：%d",order.memberNum];
    self.payModelBtn.hidden = YES;
}

- (void)configureActionPanel
{
    [super configureActionPanel];
    
    OrderModel *order = [self order];
    
    if (order.orderType == 3) {
        //旅行套餐
        [self configureTourPackageActionPanel];
        return;
    }
    
    OrderStatusEnum status = order.orderStatus;
    PayTypeEnum payType = order.payType;
    
    BOOL deleteBtnVisible = NO;
    YGOrderCourseAction actionType = YGOrderCourseAction_Base;
    
    switch (payType) {
        case PayTypeVip:
        case PayTypeDeposit:
        case PayTypeOnlinePart:
        case PayTypeOnline:{
            switch (status) {
                case OrderStatusWaitPay:{
                    actionType = YGOrderCourseAction_Pay;
                }   break;
                case OrderStatusSuccess:
                case OrderStatusCancel:
                case OrderStatusNotPresent:{
                    deleteBtnVisible = YES;
                    actionType = YGOrderCourseAction_Rebooking;
                }   break;
                case OrderStatusRepeal:{
                    deleteBtnVisible = YES;
                }break;
                case OrderStatusSendRepeal:{
                    actionType = YGOrderCourseAction_CancelRefund;
                }   break;
                case OrderStatusNew:
                case OrderStatusWaitEnsure:{}break;
            }
        }   break;
    }
    
    // 没有操作按钮，没有删除按钮，没有查看订单列表按钮，就压缩操作区域高度。
    BOOL actionPanelVisible = self.inManagerList || actionType!=YGOrderCourseAction_Base || deleteBtnVisible;
    [self setActionPanelVisible:actionPanelVisible];
    
    if (actionPanelVisible) {
        [self setDeleteBtnVisible:deleteBtnVisible];
        self.actionBtn_1.tag = actionType;
        self.actionBtn_1.hidden = actionType==YGOrderCourseAction_Base;
        [self.actionBtn_1 setTitle:[YGOrderHandlerCourse actionTitleString:actionType] forState:UIControlStateNormal];
        self.actionBtn_1.selected = actionType==YGOrderCourseAction_Pay;
        self.actionBtn_1.highlighted = actionType==YGOrderCourseAction_Rebooking;
    }
}

- (void)configureTourPackageActionPanel
{
    OrderModel *order = [self order];
    OrderStatusEnum status = order.orderStatus;
    PayTypeEnum payType = order.payType;
    
    BOOL deleteBtnVisible = NO;
    YGOrderTourPackageAction actionType = YGOrderTourPackageAction_Base;
    
    switch (status) {
        case OrderStatusWaitPay:{
            actionType = YGOrderTourPackageAction_Pay;
        }   break;
        case OrderStatusSuccess:
        case OrderStatusCancel:
        case OrderStatusNotPresent:{
            deleteBtnVisible = YES;
            actionType = YGOrderTourPackageAction_Rebooking;
        }   break;
        case OrderStatusRepeal:{
            deleteBtnVisible = YES;
        }break;
        case OrderStatusSendRepeal:{
            
        }   break;
        case OrderStatusNew:
        case OrderStatusWaitEnsure:{}break;
    }
    
    // 没有操作按钮，没有删除按钮，没有查看订单列表按钮，就压缩操作区域高度。
    BOOL actionPanelVisible = self.inManagerList || actionType!=YGOrderCourseAction_Base || deleteBtnVisible;
    [self setActionPanelVisible:actionPanelVisible];
    
    if (actionPanelVisible) {
        [self setDeleteBtnVisible:deleteBtnVisible];
        self.actionBtn_1.tag = actionType;
        self.actionBtn_1.hidden = actionType==YGOrderTourPackageAction_Base;
        [self.actionBtn_1 setTitle:[YGOrderHandlerTourPackage actionTitleString:actionType] forState:UIControlStateNormal];
        self.actionBtn_1.selected = actionType==YGOrderTourPackageAction_Pay;
        self.actionBtn_1.highlighted = actionType==YGOrderTourPackageAction_Rebooking;
    }
}

- (void)actionBtn1Action:(UIButton *)sender
{
    [super actionBtn1Action:sender];
    NSInteger action = sender.tag;
    if (self.order.orderType == 3) {
        [self.packageHandler handleAction:action];
    }else{
        [self.handler handleAction:action];
    }
}

- (void)deleteBtnAction:(id)sender
{
    [super deleteBtnAction:sender];
    if (self.order.orderType == 3) {
        [self.packageHandler handleAction:YGOrderTourPackageAction_Delete];
    }else{
        [self.handler handleAction:YGOrderCourseAction_Delete];
    }
}

- (YGOrderHandlerCourse *)handler
{
    if (!_handler || _handler.order != self.order) {
        _handler = [YGOrderHandlerCourse handlerWithOrder:self.order];
        _handler.viewCtrl = [self viewController];
    }
    return _handler;
}

- (YGOrderHandlerTourPackage *)packageHandler
{
    if (!_packageHandler || _packageHandler.oldOrder != self.order) {
        _packageHandler = [YGOrderHandlerTourPackage handlerWithOrder:self.order];
        _packageHandler.viewCtrl = [self viewController];
    }
    return _packageHandler;
}

@end
