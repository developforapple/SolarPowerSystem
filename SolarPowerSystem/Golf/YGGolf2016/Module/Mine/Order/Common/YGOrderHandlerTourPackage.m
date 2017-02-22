//
//  YGOrderHandlerTourPackage.m
//  Golf
//
//  Created by bo wang on 2017/2/20.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import "YGOrderHandlerTourPackage.h"
#import "YGThrift+TourPackage.h"
#import "YGThriftRequestManager.h"
#import "OrderService.h"
#import "ServerService.h"
#import "YGPayViewCtrl.h"
#import "YGOrderManagerViewCtrl.h"
#import "YGOrderListViewCtrl.h"
#import "YGPackageDetailViewCtrl.h"

@interface YGOrderHandlerTourPackage ()
@property (assign, nonatomic) BOOL isTrueTourPackageOrder;
@property (strong, nonatomic) TravelPackageOrder *trueOrder;
@end

@implementation YGOrderHandlerTourPackage

+ (NSString *)actionTitleString:(YGOrderTourPackageAction)actionType
{
    NSString *str;
    switch (actionType) {
        case YGOrderTourPackageAction_Base:break;
        case YGOrderTourPackageAction_Pay:str = @"立即支付";break;
        case YGOrderTourPackageAction_Refund:str = @"申请退款";break;
        case YGOrderTourPackageAction_Delete:str = @"删除订单";break;
        case YGOrderTourPackageAction_Cancel:str = @"取消订单";break;
        case YGOrderTourPackageAction_Rebooking:str = @"再次预定";break;
    }
    return str;
}

+ (instancetype)handlerWithOrder:(id)order
{
    if ([order isKindOfClass:[OrderModel class]]) {
        YGOrderHandlerTourPackage *handler = [super handlerWithOrder:[TravelPackageOrder makeSimpleOrderFrom:order]];
        handler.oldOrder = order;
        return handler;
    }else if ([order isKindOfClass:[TravelPackageOrder class]]){
        YGOrderHandlerTourPackage *handler = [super handlerWithOrder:order];
        handler.oldOrder = [order simpleOrderModel];
        return handler;
    }
    return nil;
}

- (void)handleAction:(YGOrderTourPackageAction)actionType
{
    CheckOrderClass(TravelPackageOrder);
    
    switch (actionType) {
        case YGOrderTourPackageAction_Base:
            break;
        case YGOrderTourPackageAction_Cancel:{
            [self showAlert:@"确定要取消订单吗？" message:@"" cancel:@"算了" done:@"确定" doneHandler:^(UIAlertAction *action) {
                [self cancel];
            }];
        }   break;
        case YGOrderTourPackageAction_Refund:{
            [self showAlert:@"确定要取消订单吗？" message:@"" cancel:@"算了" done:@"确定" doneHandler:^(UIAlertAction *action) {
                [self refund];
            }];
        }   break;
        case YGOrderTourPackageAction_Delete:{
            [self showAlert:@"确定要删除订单吗？" message:@"" cancel:@"算了" done:@"确定" doneHandler:^(UIAlertAction *action) {
                [self deleteOrder];
            }];
        }   break;
        case YGOrderTourPackageAction_Pay:{
            [self pay];
        }   break;
        case YGOrderTourPackageAction_Rebooking:{
            [self rebooking];
        }   break;
    }
}

- (void)fetchTourPackageOrder:(void (^)(TravelPackageOrder *order))completon
{
    CheckOrderClass(TravelPackageOrder);
    
    if (self.trueOrder) {
        if (completon) {
            completon(self.trueOrder);
        }
    }else{
        [YGRequest getOrderDetailWithOrderID:order.orderId success:^(BOOL suc, TravelPackageOrderDetail *object) {
            if (suc) {
                self.trueOrder = object.order;
                completon(self.trueOrder);
            }else{
                completon(nil);
            }
        } failure:^(Error *err) {
            completon(nil);
        }];
    }
}

- (void)cancel
{
    CheckOrderClass(TravelPackageOrder);
    if (order.orderStatus == 5 || order.orderStatus == 6){
        //取消订单
        ygweakify(self);
        [OrderService orderCancel:[[LoginManager sharedManager] getSessionId] withOrderId:order.orderId operation:0 success:^(BOOL boolen) {
            ygstrongify(self);
            if (boolen) {
                [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
            }
        } failure:^(id error) {
        }];
    }
}

- (void)refund
{
    CheckOrderClass(TravelPackageOrder);
    if (order.orderStatus == 1){
        //申请退款
        ygweakify(self);
        [OrderService orderCancel:[[LoginManager sharedManager] getSessionId] withOrderId:order.orderId operation:1 success:^(BOOL boolen) {
            ygstrongify(self);
            if (boolen) {
                [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
            }
        } failure:^(id error) {
        }];
    }
}

- (void)deleteOrder
{
    CheckOrderClass(TravelPackageOrder);
    if (order.orderStatus == 1 ||
        order.orderStatus == 5 ||
        order.orderStatus == 6 ||
        order.orderStatus == 7) {
        [SVProgressHUD showInfoWithStatus:@"无法删除未完成订单"];
        return;
    }

    ygweakify(self);
    [ServerService orderDelete:[[LoginManager sharedManager] getSessionId] orderId:order.orderId callBack:^(id obj) {
        ygstrongify(self);
        [self postOrderDidDeletedNotification];
    } failure:^(id error) {
        [SVProgressHUD showInfoWithStatus:@"当前网络不可用"];
    }];
}

- (void)pay
{
    ygweakify(self);
    [self fetchTourPackageOrder:^(TravelPackageOrder *order) {
        ygstrongify(self);
        [self startPay];
    }];
}

- (void)startPay
{
    CheckOrderClass(TravelPackageOrder);
    if (!self.trueOrder) return;
    
    ygweakify(self);
    YGPayment *payment = [[YGPayment alloc] initWithScene:YGPaymentSceneTeetime orderId:self.trueOrder.orderId payAmount: self.trueOrder.price/100];
    YGPayViewCtrl *vc = [YGPayViewCtrl instanceFromStoryboard];
    vc.handler = self;
    vc.payment = payment;
    [vc setPayCallback:^(YGPayStatus status, YGPayment *thePayment) {
        ygstrongify(self);
        [self payment:thePayment didCompleted:status==YGPayStatusSuccess];
    }];
    [vc setShowOrderAction:^(NSInteger orderId) {
        ygstrongify(self);
        [self showOrderAfterPayment];
    }];
    [vc setBackHomeAction:^{
        ygstrongify(self);
        [self backHomeAfterPayment];
    }];
    [self.viewCtrl.navigationController pushViewController:vc animated:YES];
}

- (void)payment:(YGPayment *)payment didCompleted:(BOOL)success
{
    CheckOrderClass(TravelPackageOrder);
    if (success) {
        [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
    }
}

- (void)showOrderAfterPayment
{
    CheckOrderClass(TravelPackageOrder);
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
            vc.orderType = YGOrderTypeCourse;
            NSArray *tmp = [vcs subarrayWithRange:NSMakeRange(0, myAllOrderIdx+1)];
            NSArray *newVCs = [tmp arrayByAddingObject:vc];
            [self.viewCtrl.navigationController setViewControllers:newVCs animated:YES];
        }
    }else{
        YGOrderListViewCtrl *vc = [YGOrderListViewCtrl instanceFromStoryboard];
        vc.orderType = YGOrderTypeCourse;
        UITabBarController *tabBarCtrl = [GolfAppDelegate shareAppDelegate].tabBarController;
        UINavigationController *navi = [GolfAppDelegate shareAppDelegate].tabBarController.nav_5;
        [tabBarCtrl setSelectedViewController:navi];
        [navi pushViewController:vc animated:YES];
        [self.viewCtrl.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)backHomeAfterPayment
{
    CheckOrderClass(TravelPackageOrder);
    NSArray *vcs = [self.viewCtrl.navigationController viewControllers];
    YGOrderManagerViewCtrl *myAllOrderVC;
    for (__kindof UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[YGOrderManagerViewCtrl class]] && !myAllOrderVC){
            myAllOrderVC = vc;
        }
    }
    if(myAllOrderVC){
        [self.viewCtrl.navigationController popToViewController:myAllOrderVC animated:YES];
    }else{
        [self.viewCtrl.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)rebooking
{
    CheckOrderClass(TravelPackageOrder);
    
    YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
    vc.packageId = order.packageId;
    [self.viewCtrl.navigationController pushViewController:vc animated:YES];
}

@end
