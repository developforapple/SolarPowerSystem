//
//  YGOrderHandlerTeachBooking.m
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandlerTeachBooking.h"
#import "YGThrift+Teaching.h"

#import "YGTeachBookingOrderViewCtrl.h"
#import "PayOnlineViewController.h"

@implementation YGOrderHandlerTeachBooking

+ (NSString *)actionTitleString:(YGOrderTeachBookingAction)actionType
{
    NSString *str;
    switch (actionType) {
        case YGOrderTeachBookingAction_Base:break;
        case YGOrderTeachBookingAction_Pay:str = @"立即支付";break;
        case YGOrderTeachBookingAction_Delete:break;
    }
    return str;
}

- (void)handleAction:(YGOrderTeachBookingAction)actionType
{
    switch (actionType) {
        case YGOrderTeachBookingAction_Base:break;
        case YGOrderTeachBookingAction_Pay:{
            [self pay];
        }   break;
        case YGOrderTeachBookingAction_Delete:{
        
        }   break;
    }
}

- (void)pay
{
    CheckOrderClass(VirtualCourseOrderBean);
    
    if (order.orderStatus != OrderStatus_WAIT_PAY) {
        return;
    }
    
    ygweakify(self);
    PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
    payOnline.orderId = order.orderId;
    payOnline.payTotal = order.price/100.f;
    payOnline.orderTotal = order.price/100.f;
    payOnline.waitPayFlag = WaitPayTypeTeachBooking;
    payOnline.academyId = order.courseId;
    payOnline.blockReturn = ^(id data){
        ygstrongify(self);
        order.orderStatus = OrderStatus_WAIT_COMPLETE;
        YGTeachBookingOrderViewCtrl *vc = [YGTeachBookingOrderViewCtrl instanceFromStoryboard];
        vc.order = order;
        [self.viewCtrl.navigationController popToViewController:self.viewCtrl animated:NO];
        [self.viewCtrl.navigationController pushViewController:vc animated:YES];
        
        [self postOrderDidChangedNotification];
    };
    
    payOnline.title = @"在线支付";
    [self.viewCtrl.navigationController pushViewController:payOnline animated:YES];
}

@end
