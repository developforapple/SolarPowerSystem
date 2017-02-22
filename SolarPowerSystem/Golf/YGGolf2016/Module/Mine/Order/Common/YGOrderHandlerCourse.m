//
//  YGOrderHandlerCourse.m
//  Golf
//
//  Created by bo wang on 2016/12/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandlerCourse.h"
#import "PayOnlineViewController.h"
#import "ClubMainViewController.h"
#import "YGPackageDetailViewCtrl.h"
#import "YGPackageDetailViewCtrl.h"
#import "YGPayViewCtrl.h"
#import "YGOrderManagerViewCtrl.h"
#import "YGOrderListViewCtrl.h"
#import "YGThrift+TourPackage.h"
#import "YGThriftRequestManager.h"

@implementation YGOrderHandlerCourse

+ (NSString *)actionTitleString:(YGOrderCourseAction)actionType
{
    NSString *str;
    switch (actionType) {
        case YGOrderCourseAction_Base:break;
        case YGOrderCourseAction_Rebooking:str = @"再次预定";break;
        case YGOrderCourseAction_Pay:str = @"立即支付";break;
        case YGOrderCourseAction_CancelRefund:str = @"取消申请";break;
        case YGOrderCourseAction_Delete:break;
    }
    return str;
}

- (void)handleAction:(YGOrderCourseAction)actionType
{
    switch (actionType) {
        case YGOrderCourseAction_Base:break;
        case YGOrderCourseAction_Pay:{
            [self pay];
        }   break;
        case YGOrderCourseAction_Delete:{
            [self deleteOrder];
        }   break;
        case YGOrderCourseAction_CancelRefund:{
            [self cancelRefundApply];
        }   break;
        case YGOrderCourseAction_Rebooking:{
            [self rebooking];
        }   break;
    }
}

- (void)pay
{
    CheckOrderClass(OrderModel);
    if (order.orderStatus != OrderStatusWaitPay) return;
    
    if (order.orderType == 3) {
        // 旅行套餐采用新的支付
        
    }else{
        ygweakify(self);
        UINavigationController *navi = self.viewCtrl.navigationController;
        PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
        payOnline.payTotal = order.payTotal;
        payOnline.orderTotal = order.payTotal;
        payOnline.orderId = order.orderId;
        payOnline.waitPayFlag = 1;
        payOnline.clubId = order.clubId;
        payOnline.title = @"在线支付";
        payOnline.blockReturn = ^(id data){
            ygstrongify(self);
            order.orderStatus = OrderStatusWaitEnsure;
            [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
            [navi popToViewController:self.viewCtrl animated:YES];
        };
        [navi pushViewController:payOnline animated:YES];
    }
}

- (void)deleteOrder
{
    CheckOrderClass(OrderModel);
    if (order.orderStatus == OrderStatusNew ||
        order.orderStatus == OrderStatusWaitEnsure ||
        order.orderStatus == OrderStatusWaitPay ||
        order.orderStatus == OrderStatusSendRepeal) {
        [SVProgressHUD showInfoWithStatus:@"无法删除未完成订单"];
        return;
    }
    [self showAlert:@"删除后不可恢复，\n确定要删除吗？" message:@"" cancel:@"算了" done:@"确定" doneHandler:^(UIAlertAction *action) {
        [SVProgressHUD show];
        [ServerService deleteCourseOrder:order.orderId callBack:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            [self postOrderDidDeletedNotification];
        } failure:^(id error) {
            [SVProgressHUD dismiss];
        }];
    }];
}

- (void)rebooking
{
    CheckOrderClass(OrderModel);
    if (order.orderStatus != OrderStatusCancel && order.orderStatus != OrderStatusSuccess) return;
    
    if (order.orderType == 3) {
        //新的旅行套餐
        YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
        vc.packageId = order.packageId;
        [self.viewCtrl.navigationController pushViewController:vc animated:YES];
        
    }else if (order.packageId==0) {
        ConditionModel *myCondition = [[ConditionModel alloc] init];
        myCondition.date = order.teetimeDate;
        myCondition.time = order.teetimeTime;
        myCondition.clubId = order.clubId;
        
        [self.viewCtrl pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
            ClubMainViewController *vc = (ClubMainViewController*)controller;
            vc.cm = myCondition;
            vc.agentId = -1;
        }];
    }else{
        
        YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
        vc.packageId = order.packageId;
        [self.viewCtrl.navigationController pushViewController:vc animated:YES];
    }
}

- (void)cancelRefundApply
{
    CheckOrderClass(OrderModel);
    if (order.orderStatus != OrderStatusSendRepeal) return;
    
    [self showAlert:@"确定取消申请？" message:@"" cancel:@"再想想" done:@"取消申请" doneHandler:^(UIAlertAction *action) {
        [SVProgressHUD show];
        [ServerService cancelCourseOrderRefund:order.orderId callBack:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:@"撤销申请成功"];
            order.orderStatus = OrderStatusSendRepeal;
            [self postOrderDidChangedNotification];
        } failure:^(HttpErroCodeModel *error) {
            [SVProgressHUD dismiss];
        }];
    }];
}

@end
