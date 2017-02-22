//
//  YGOrderHandlerTeaching.m
//  Golf
//
//  Created by bo wang on 2016/12/15.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandlerTeaching.h"
#import "PayOnlineViewController.h"

@implementation YGOrderHandlerTeaching

+ (NSString *)actionTitleString:(YGOrderTeachingAction)actionType
{
    NSString *str;
    switch (actionType) {
        case YGOrderTeachingAction_Base:break;
        case YGOrderTeachingAction_Pay:str = @"立即支付";break;
        case YGOrderTeachingAction_Delete:break;
    }
    return str;
}

- (void)handleAction:(YGOrderTeachingAction)actionType
{
    switch (actionType) {
        case YGOrderTeachingAction_Base:break;
        case YGOrderTeachingAction_Pay:{
            [self pay];
        }   break;
        case YGOrderTeachingAction_Delete:{
            [self deleteOrder];
        }   break;
    }
}

- (void)pay
{
    CheckOrderClass(TeachingOrderModel);
    if (order.orderState != YGTeachingOrderStatusTypeWaitPay) return;
    
    ygweakify(self);
    PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
    payOnline.payTotal = order.price;
    payOnline.orderTotal = order.price;
    payOnline.orderId = order.orderId;
    payOnline.waitPayFlag = 3;
    payOnline.productId = order.productId;
    payOnline.academyId = order.academyId;
    payOnline.classType = order.classType;
    payOnline.classHour = order.classHour;
    payOnline.blockReturn = ^(id data){
        ygstrongify(self);
        order.orderState = YGTeachingOrderStatusTypeTeaching;
        [self postOrderDidChangedNotification:@{kYGOrderNotificationNeedRequestKey:@YES}];
        [self.viewCtrl.navigationController popToViewController:self.viewCtrl animated:YES];
    };
    payOnline.title = @"在线支付";
    payOnline.hidesBottomBarWhenPushed = YES;
    [self.viewCtrl.navigationController pushViewController:payOnline animated:YES];
}

- (void)deleteOrder
{
    
}

@end
