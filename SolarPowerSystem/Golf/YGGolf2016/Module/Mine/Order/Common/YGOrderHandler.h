//
//  YGOrderHandler.h
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YGOrderModel;

// 订单被删除的通知。provider接收这个通知，做出相应修改。 object为order实例
FOUNDATION_EXTERN NSString *const kYGOrderDidDeletedNotification;
// 订单被更改的通知。provider接收这个通知，做出相应修改。 object为order实例
FOUNDATION_EXTERN NSString *const kYGOrderDidChangedNotification;

// 订单被更改时，如果更改是个父订单，userInfo中这个key对应的值为@YES。
//FOUNDATION_EXTERN NSString *const kYGOrderNotificationParentOrderKey;
// 订单通知中的userInfo key。值为NSNumber，订单类型。
FOUNDATION_EXTERN NSString *const kYGOrderNotificationTypeKey;
// 订单通知中的userInfo key。值为NSNumber，BOOL类型。YES，需要重新请求order数据
FOUNDATION_EXTERN NSString *const kYGOrderNotificationNeedRequestKey;

/*
 处理订单的各种各样的操作。
 */
@interface YGOrderHandler : NSObject

// 生成订单处理器. 使用子类调用进行初始化
+ (instancetype)handlerWithOrder:(id)order NS_REQUIRES_SUPER;

// 订单model
@property (strong, readonly, nonatomic) id order;

// 订单发生操作时所在的控制器。默认为根控制器。如果需要正确的处理跳转，需要修改此属性。
@property (weak, nonatomic) __kindof UIViewController *viewCtrl;


// 发出更新通知. object 为 order
- (void)postOrderDidChangedNotification;
- (void)postOrderDidChangedNotification:(NSDictionary *)userInfo;
// 发出删除通知. object 为 order
- (void)postOrderDidDeletedNotification;
- (void)postOrderDidDeletedNotification:(NSDictionary *)userInfo;

// 预定义的一些操作。
- (void)create;
- (void)pay;
- (void)deleteOrder;

// 预定义的支付完成操作,由子类实现
// 查看订单
- (void)showOrderAfterPayment;
// 返回首页
- (void)backHomeAfterPayment;

// 显示订单详情
+ (void)showOrderDetail:(id<YGOrderModel>)order
       fromNaviViewCtrl:(UINavigationController *)navi;

- (void)showAlert:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel done:(NSString *)done doneHandler:(void (^)(UIAlertAction *action))handler;

@end

#define CheckOrderClass(OrderClass) \
    OrderClass *order = self.order;\
    if(!order || ![order isKindOfClass:[OrderClass class]]) return;
