//
//  YGOrderHandler.m
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandler.h"
#import "YGOrderCommon.h"
#import "YGTeachBookingOrderViewCtrl.h"
#import "YGMallOrderViewCtrl.h"
#import "ClubOrderViewController.h"
#import "TeachingOrderDetailViewController.h"
#import "YGPackageOrderDetailViewCtr.h"

@interface YGOrderHandler ()
@property (strong, readwrite, nonatomic) id order;
@end

@implementation YGOrderHandler

+ (instancetype)handlerWithOrder:(id)order
{
    if (!order) return nil;
    
    YGOrderHandler *handler = [[[self class] alloc] init];
    handler.order = order;
    handler.viewCtrl = [[GolfAppDelegate shareAppDelegate].tabBarController selectedViewController];
    return handler;
}

- (void)postOrderDidChangedNotification
{
    [self postOrderDidChangedNotification:nil];
}

- (void)postOrderDidChangedNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    dict[kYGOrderNotificationTypeKey] = @(typeOfOrder(self.order));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kYGOrderDidChangedNotification object:self.order userInfo:dict];
}

- (void)postOrderDidDeletedNotification
{
    [self postOrderDidDeletedNotification:nil];
}

- (void)postOrderDidDeletedNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    dict[kYGOrderNotificationTypeKey] = @(typeOfOrder(self.order));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kYGOrderDidDeletedNotification object:self.order userInfo:dict];
}

- (void)create{}
- (void)pay{}
- (void)deleteOrder{}

- (void)showOrderAfterPayment{}
- (void)backHomeAfterPayment{}

+ (void)showOrderDetail:(id<YGOrderModel>)order
       fromNaviViewCtrl:(UINavigationController *)navi
{
    if (!order || !navi) return;
    
    YGOrderType type = typeOfOrder(order);
    switch (type) {
        case YGOrderTypeCourse:{
            OrderModel *om = order;
            if ([order isKindOfClass:[TravelPackageOrder class]] || om.orderType == 3) {
                //旅行套餐订单
                YGPackageOrderDetailViewCtr *vc = [YGPackageOrderDetailViewCtr instanceFromStoryboard];
                vc.orderId = [order gp_orderId];
                [navi pushViewController:vc animated:YES];
            }else{
                ClubOrderViewController *clubOrder = [[ClubOrderViewController alloc] init];
                clubOrder.orderId = [order gp_orderId];
                clubOrder.isBackUp = YES;
                clubOrder.isInMineVC = YES;
                clubOrder.title = [NSString stringWithFormat:@"订单%ld",(long)[order gp_orderId]];
                [navi pushViewController:clubOrder animated:YES];
            }
            
        }   break;
        case YGOrderTypeMall:{
            YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
            vc.orderId = [order gp_orderId];
            [navi pushViewController:vc animated:YES];
        }   break;
        case YGOrderTypeTeaching:{
            NSInteger orderid = [order gp_orderId];
            
            TeachingOrderDetailViewController *vc = [TeachingOrderDetailViewController instanceFromStoryboard];
            vc.title = [NSString stringWithFormat:@"订单%ld",(long)orderid];
            vc.hidesBottomBarWhenPushed = YES;
            vc.orderId = orderid;
            vc.isCoach = NO;
            [navi pushViewController:vc animated:YES];
            
        }   break;
        case YGOrderTypeTeachBooking:{
            VirtualCourseOrderBean *theOrder = (VirtualCourseOrderBean *)order;
            YGTeachBookingOrderViewCtrl *vc = [YGTeachBookingOrderViewCtrl instanceFromStoryboard];
            vc.order = theOrder;
            [navi pushViewController:vc animated:YES];
        }   break;
    }
}

#pragma mark - ----- Alert -----
- (void)showAlert:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel done:(NSString *)done doneHandler:(void (^)(UIAlertAction *action))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if (done) {
        [alert addAction:[UIAlertAction actionWithTitle:done style:UIAlertActionStyleDestructive handler:handler]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:cancel?:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self.viewCtrl presentViewController:alert animated:YES completion:nil];
}

@end

NSString *const kYGOrderDidDeletedNotification = @"YGOrderDidDeletedNotification";
NSString *const kYGOrderDidChangedNotification = @"YGOrderDidChangedNotification";

NSString *const kYGOrderNotificationTypeKey = @"YGOrderNotificationTypeKey";
NSString *const kYGOrderNotificationNeedRequestKey = @"YGOrderNotificationNeedRequestKey";
