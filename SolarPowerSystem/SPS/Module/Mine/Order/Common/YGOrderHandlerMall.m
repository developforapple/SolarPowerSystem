//
//  YGOrderHandlerMall.m
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandlerMall.h"
#import "YGMallOrderModel.h"
#import "YGMallOrderViewCtrl.h"
#import "YGPayViewCtrl.h"
#import "YGMallCartViewCtrl.h"
#import "YGMallOrderRefundReasonViewCtrl.h"
#import "YGMallOrderReviewListViewCtrl.h"
#import "YGMallOrderReviewEditViewCtrl.h"

#import "YGMallViewCtrl.h"
#import "YG_MallCommodityViewCtrl.h"
#import "YGOrderManagerViewCtrl.h"
#import "YGOrderListViewCtrl.h"

@implementation YGOrderHandlerMall

+ (NSString *)actionTitleString:(YGOrderMallAction)actionType
{
    NSString *str;
    switch (actionType) {
        case YGOrderMallAction_Base:break;
        case YGOrderMallAction_Pay:str = @"立即支付";break;
        case YGOrderMallAction_Refund:str = @"申请退款";break;
        case YGOrderMallAction_Delete:break;
        case YGOrderMallAction_Rebuy:str = @"再次购买";break;
        case YGOrderMallAction_Review:str = @"立即评价";break;
        case YGOrderMallAction_Received:str = @"确认收货";break;
        case YGOrderMallAction_CancelRefund:str = @"取消申请";break;
    }
    return str;
}

- (void)handleAction:(YGOrderMallAction)actionType
{
    switch (actionType) {
        case YGOrderMallAction_Base:break;
        case YGOrderMallAction_Pay:{[self pay];}break;
        case YGOrderMallAction_Refund:{[self createRefund];}break;
        case YGOrderMallAction_Delete:{[self deleteOrder];}break;
        case YGOrderMallAction_Rebuy:{[self buyAgain];}break;
        case YGOrderMallAction_Review:{[self review];}break;
        case YGOrderMallAction_Received:{[self confirmReceived];}break;
        case YGOrderMallAction_CancelRefund:{[self createCancelRefund];}break;
    }
}

#pragma mark - ----- Create -----
- (void)create
{
    CheckOrderClass(YGMallOrderModel);
    
    if (order.tempStatus != YGMallOrderStatusCreating) {
        return;
    }
    
    if (order.link_phone.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请填写手机号码"];
    }else if (![Utilities phoneNumMatch:order.link_phone]){
        [SVProgressHUD showInfoWithStatus:@"手机号码格式不正确"];
    }else if (![order isVirtualOrder] && order.link_man.length == 0){
        [SVProgressHUD showInfoWithStatus:@"请填写联系人"];
    }else if (![order isVirtualOrder] && order.address.length == 0){
        [SVProgressHUD showInfoWithStatus:@"请填写收货地址"];
    }else{
        [[LoginManager sharedManager] loginIfNeed:self.viewCtrl doSomething:^(id data) {
            [self submitOrderToService];
        }];
    }
}

- (void)submitOrderToService
{
    YGPostBuriedPoint(YGMallPointSubmitOrder);
    [SVProgressHUD show];
    NSDictionary *submitData = [self.order prepareSubmitData];
    [ServerService submitCommodityOrder:submitData callBack:^(BaseService *BS) {
        [SVProgressHUD dismiss];
        if (BS.success) {
            NSDictionary *orderInfo = (NSDictionary *)BS.data;
            NSInteger orderStatus = [orderInfo[@"order_state"] integerValue];
            NSInteger orderId = [orderInfo[@"order_id"] integerValue];
            [(YGMallOrderModel *)self.order setOrder_id:orderId];
            if (orderStatus == YGMallOrderStatusUnpaid) {
                //未支付
                [self prepareToPay:orderInfo];
            }
            [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
        }
    } failure:^(id error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - ----- Pay -----
- (void)prepareToPay:(NSDictionary *)data
{
    YGMallOrderModel *order = self.order;
    order.order_state = order.tempStatus = YGMallOrderStatusUnpaid;
    
    [self pay];
}

- (void)pay
{
    CheckOrderClass(YGMallOrderModel);
    
    if (order.order_state != YGMallOrderStatusUnpaid) return;
    
    ygweakify(self);
    YGPayment *payment = [[YGPayment alloc] initWithScene:YGPaymentSceneMall orderId:order.order_id payAmount:[order needToPayAmount]/100];
    YGPayViewCtrl *payVC = [YGPayViewCtrl instanceFromStoryboard];
    payVC.payment = payment;
    payVC.handler = self;
    [payVC setPayCallback:^(YGPayStatus status, YGPayment *thePayment) {
        ygstrongify(self);
        [self payment:thePayment didCompleted:status == YGPayStatusSuccess];
    }];
    [payVC setShowOrderAction:^(NSInteger orderId) {
        ygstrongify(self);
        [self showOrderAfterPayment];
    }];
    [payVC setBackHomeAction:^{
        ygstrongify(self);
        [self backHomeAfterPayment];
    }];
    [self.viewCtrl.navigationController pushViewController:payVC animated:YES];
}

- (void)payment:(YGPayment *)payment didCompleted:(BOOL)success
{
    CheckOrderClass(YGMallOrderModel);
    if (success) {
        order.order_state = order.tempStatus = YGMallOrderStatusPaid;
        [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
    }
}

#pragma mark - ----- Cancel -----
- (void)cancel
{
    CheckOrderClass(YGMallOrderModel);
    if (order.order_state != YGMallOrderStatusUnpaid) return;
    [self showAlert:@"确定要取消订单吗？" message:@"" cancel:@"算了" done:@"确定" doneHandler:^(UIAlertAction *action) {
        [self doCancelOrder];
    }];
}

- (void)doCancelOrder
{
    CheckOrderClass(YGMallOrderModel);
    if (order.order_state != YGMallOrderStatusUnpaid) return;
    
    YGPostBuriedPoint(YGMallPointCancelOrder);
    [SVProgressHUD show];
    [ServerService operateOrder:order.order_id operation:1 desc:nil callBack:^(id obj) {
        [self orderDidCanceled:obj];
        [SVProgressHUD showSuccessWithStatus:@"订单已取消"];
    } failure:^(id error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)orderDidCanceled:(NSDictionary *)info
{
    if (!info || ![info isKindOfClass:[NSDictionary class]]) return;
    
    CheckOrderClass(YGMallOrderModel);
    order.order_state = order.tempStatus = (YGMallOrderStatus)[info[@"order_state"] integerValue];
    [self postOrderDidChangedNotification];
}

#pragma mark - ----- Refund -----

- (void)selectRefundReason:(void (^)(NSString *reason))callback
{
    CheckOrderClass(YGMallOrderModel);
    if ([order canApplyRefund]) {
        YGMallOrderRefundReasonViewCtrl *vc = [YGMallOrderRefundReasonViewCtrl instanceFromStoryboard];
        vc.reason = order.return_memo;
        [vc setDidSelectedReason:callback];
        [vc show];
    }
}

- (void)createRefund
{
    CheckOrderClass(YGMallOrderModel);
    if ([order canApplyRefund]) {
        if (order.opera_status == 0) {
            //单独退款
            ygweakify(self);
            [self selectRefundReason:^(NSString *reason) {
                ygstrongify(self);
                order.return_memo = reason;
                [self applyRefund];
            }];
        }else{
            //使用父订单退款
            NSInteger parentOrderId = order.parentOrderId;
            YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
            vc.orderId = parentOrderId;
            vc.isApplyRefund = YES;
            
            NSMutableArray *vcs = [NSMutableArray arrayWithArray:[self.viewCtrl.navigationController viewControllers]];
            while ([[vcs lastObject] isKindOfClass:[YGMallOrderViewCtrl class]]) {
                [vcs removeLastObject];
            }
            [vcs addObject:vc];
            [self.viewCtrl.navigationController setViewControllers:vcs animated:YES];
        }
    }
}

- (void)applyRefund
{
    CheckOrderClass(YGMallOrderModel);
    
    if (![order canApplyRefund]) return;
    
    if (order.return_memo.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择退款原因"];
        return;
    }
    
    [self showAlert:@"确认提交退款申请？" message:@"退款申请提交以后，卖家会在7天内进行确认，确认完即可完成退款。" cancel:@"取消" done:@"提交申请" doneHandler:^(UIAlertAction *action) {
        [self doApplyRefund];
    }];
}

- (void)doApplyRefund
{
    CheckOrderClass(YGMallOrderModel);
    
    [SVProgressHUD show];
    [ServerService operateOrder:order.order_id operation:2 desc:order.return_memo callBack:^(id obj) {
        [SVProgressHUD showSuccessWithStatus:@"退款申请已提交，等待卖家确认"];
        
        if (!obj || ![obj isKindOfClass:[NSDictionary class]]) return;
        NSDictionary *data = obj;
        
        YGMallOrderStatus status = (YGMallOrderStatus)[data[@"order_state"] integerValue];
        order.order_state = order.tempStatus = status;
        [self postOrderDidChangedNotification];
    } failure:^(id error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)createCancelRefund
{
    CheckOrderClass(YGMallOrderModel);
    if (![order canCancelApplyRefund]) return;
    
    if (order.opera_status == 0) {
        //单独取消
        [self cancelRefund];
    }else{
        //使用父订单取消
        NSInteger parentOrderId = order.parentOrderId;
        YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
        vc.orderId = parentOrderId;
        vc.isApplyRefund = YES;
        
        NSMutableArray *vcs = [NSMutableArray arrayWithArray:[self.viewCtrl.navigationController viewControllers]];
        [vcs removeLastObject];
        [vcs addObject:vc];
        [self.viewCtrl.navigationController setViewControllers:vcs animated:YES];
    }
}

- (void)cancelRefund
{
    CheckOrderClass(YGMallOrderModel);
    if (![order canCancelApplyRefund]) return;
    
    [self showAlert:@"确认取消退款申请？" message:@"" cancel:@"再想想" done:@"确定" doneHandler:^(UIAlertAction *action) {
        [self doCancelApplyRefund];
    }];
}

- (void)doCancelApplyRefund
{
    CheckOrderClass(YGMallOrderModel);
    
    [SVProgressHUD show];
    [ServerService operateOrder:order.order_id operation:5 desc:nil callBack:^(id obj) {
        [SVProgressHUD showSuccessWithStatus:@"退款申请已取消"];
        
        if (!obj || ![obj isKindOfClass:[NSDictionary class]]) return;
        NSDictionary *data = obj;
        
        YGMallOrderStatus status = (YGMallOrderStatus)[data[@"order_state"] integerValue];
        order.order_state = order.tempStatus = status;
        [self postOrderDidChangedNotification];
    } failure:^(id error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - ----- Received -----
- (void)confirmReceived
{
    CheckOrderClass(YGMallOrderModel);
    if (order.order_state != YGMallOrderStatusShipped) return;
    [self showAlert:@"确定已收到货物？" message:@"" cancel:@"取消" done:@"已收到" doneHandler:^(UIAlertAction *action) {
        [self doConfirmReceived];
    }];
}

- (void)doConfirmReceived
{
    CheckOrderClass(YGMallOrderModel);
    [SVProgressHUD show];
    [ServerService operateOrder:order.order_id operation:3 desc:nil callBack:^(id obj) {
        [SVProgressHUD showSuccessWithStatus:@"操作完成"];
        if (!obj || ![obj isKindOfClass:[NSDictionary class]]) return;
        NSDictionary *data = obj;
        YGMallOrderStatus status = (YGMallOrderStatus)[data[@"order_state"] integerValue];
        order.order_state = order.tempStatus = status;
        [self postOrderDidChangedNotification];
    } failure:^(id error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - ----- Delete -----
- (void)deleteOrder
{
    CheckOrderClass(YGMallOrderModel);
    if ([order canDeleteOrder]) {
        [self showAlert:@"删除后不可恢复，\n确定要删除吗？" message:@"" cancel:@"算了" done:@"确定" doneHandler:^(UIAlertAction *action) {
            [SVProgressHUD show];
            [ServerService deleteMallOrder:order.order_id callBack:^(id obj) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                [self postOrderDidDeletedNotification];
            } failure:^(id error) {
                [SVProgressHUD dismiss];
            }];
        }];
    }
}

#pragma mark - ----- Buy Again -----
- (void)buyAgain
{
    //再次购买
    CheckOrderClass(YGMallOrderModel);
    
    NSMutableArray *cids = [NSMutableArray array];
    NSMutableArray *skuids = [NSMutableArray array];
    NSMutableArray *quantities = [NSMutableArray array];
    
    NSArray *commodities = [order commodityList];
    for (YGMallOrderCommodity *commodity in commodities) {
        [cids addObject:@(commodity.commodity_id)];
        [skuids addObject:@(commodity.sku_id)];
        [quantities addObject:@(commodity.quantity)];
    }
    
    NSString *cidStr = [cids componentsJoinedByString:@","];
    NSString *skuStr = [skuids componentsJoinedByString:@","];
    NSString *quantityStr = [quantities componentsJoinedByString:@","];
    [SVProgressHUD show];
    [ServerService shoppingCartMaintain:[[LoginManager sharedManager] getSessionId] operation:1 commodityIds:cidStr specIds:skuStr quantitys:quantityStr success:^(NSArray *list) {
        if (list.count > 0) {
            [self didAddedToCart:list];
        }
        [SVProgressHUD dismiss];
    } failure:^(id error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)didAddedToCart:(NSArray<NSDictionary *> *)list
{
    NSMutableSet *set = [NSMutableSet set];
    for (NSDictionary *commodityInfo in list) {
        NSString *info = [NSString stringWithFormat:@"%@-%@",commodityInfo[@"commodity_id"],commodityInfo[@"spec_id"]];
        [set addObject:info];
    }
    
    //打开购物车
    YGMallCartViewCtrl *vc = [YGMallCartViewCtrl instanceFromStoryboard];
    vc.defaultSelectionInfo = set;
    [self.viewCtrl.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ----- Review -----
- (void)review
{
    CheckOrderClass(YGMallOrderModel);
    if (order.order_state == YGMallOrderStatusReceived) {
        
        ygweakify(self);
        if ([order isMultiCommodityOrder]) {
            YGMallOrderReviewListViewCtrl *vc = [YGMallOrderReviewListViewCtrl instanceFromStoryboard];
            vc.orderId = order.order_id;
            [vc setDidReviewedOrder:^(NSInteger orderId) {
                ygstrongify(self);
                if (orderId == order.order_id) {
                    [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
                }
            }];
            [self.viewCtrl.navigationController pushViewController:vc animated:YES];
        }else{
            NSArray *commodities = [order commodityList];
            YGMallOrderReviewEditViewCtrl *vc = [YGMallOrderReviewEditViewCtrl instanceFromStoryboard];
            vc.commodity = [commodities firstObject];
            vc.orderId = order.order_id;
            [vc setDidReviewedCommodity:^(NSInteger orderId, NSInteger cid) {
                ygstrongify(self);
                if (orderId == order.order_id && [order unreviewedCommodityAmount] == 0) {
                    [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
                }
            }];
            [self.viewCtrl.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - ----- Payment Completed -----

- (void)showOrderAfterPayment
{
    CheckOrderClass(YGMallOrderModel);
    
    NSArray *vcs = [self.viewCtrl.navigationController viewControllers];
    
    NSInteger myAllOrderIdx = NSNotFound;
    NSInteger orderListIdx = NSNotFound;
    
    for (NSInteger i = 0; i<vcs.count; i++) {
        UIViewController *vc = vcs[i];
        if ([vc isKindOfClass:[YGOrderManagerViewCtrl class]] && myAllOrderIdx == NSNotFound){
            myAllOrderIdx = i;
        }else if ([vc isKindOfClass:[YGOrderListViewCtrl class]] && orderListIdx == NSNotFound){
            orderListIdx = i;
        }
    }
    
    if (myAllOrderIdx != NSNotFound) {
        if (orderListIdx != NSNotFound) {
            [self.viewCtrl.navigationController popToViewController:vcs[orderListIdx] animated:YES];
        }else{
            YGOrderListViewCtrl *vc = [YGOrderListViewCtrl instanceFromStoryboard];
            vc.orderType = YGOrderTypeMall;
            NSArray *tmp = [vcs subarrayWithRange:NSMakeRange(0, myAllOrderIdx+1)];
            NSArray *newVCs = [tmp arrayByAddingObject:vc];
            [self.viewCtrl.navigationController setViewControllers:newVCs animated:YES];
        }
    }else{
        YGOrderListViewCtrl *vc = [YGOrderListViewCtrl instanceFromStoryboard];
        vc.orderType = YGOrderTypeMall;
        UITabBarController *tabBarCtrl = [GolfAppDelegate shareAppDelegate].tabBarController;
        UINavigationController *navi = [GolfAppDelegate shareAppDelegate].tabBarController.nav_5;
        [tabBarCtrl setSelectedViewController:navi];
        [navi pushViewController:vc animated:YES];
        [self.viewCtrl.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)backHomeAfterPayment
{
    CheckOrderClass(YGMallOrderModel);
    
    NSArray *vcs = [self.viewCtrl.navigationController viewControllers];
    
    YGMallViewCtrl *mallRootVC;
    YGOrderManagerViewCtrl *myAllOrderVC;
    
    for (__kindof UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[YGMallViewCtrl class]] && !mallRootVC) {
            mallRootVC = vc;
        }else if ([vc isKindOfClass:[YGOrderManagerViewCtrl class]] && !myAllOrderVC){
            myAllOrderVC = vc;
        }
    }
    if (mallRootVC) {
        [self.viewCtrl.navigationController popToViewController:mallRootVC animated:YES];
    }else if(myAllOrderVC){
        [self.viewCtrl.navigationController popToViewController:myAllOrderVC animated:YES];
    }else{
        [self.viewCtrl.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
