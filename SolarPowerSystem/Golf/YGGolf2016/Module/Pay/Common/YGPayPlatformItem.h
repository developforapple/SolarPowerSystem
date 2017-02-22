//
//  YGPayPlatformItem.h
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGPayThirdPlatform.h"

typedef NS_ENUM(NSUInteger, YGPaymentPlatform) {
    YGPaymentPlatformInApp = 0,     //内部
    YGPaymentPlatformWechat = YGPayThirdPlatformWechat,    //微信支付
    YGPaymentPlatformAlipay = YGPayThirdPlatformAlipay,    //支付宝支付
    YGPaymentPlatformUnionpay = YGPayThirdPlatformUPPay,  //银联支付
    YGPaymentPlatformApplePay = YGPayThirdPlatformApplePay,  //ApplePay
    YGPaymentPlatformYunGao = 5,    //云高垫付。作为一种支付方式来展现。
};

/**
 支付平台对应的字符串标识
 @param platform 平台类型
 @return 字符串标识
 */
FOUNDATION_EXTERN NSString *PayPlatformType(YGPaymentPlatform platform);

@interface YGPayPlatformItem : NSObject

@property (assign, nonatomic) YGPaymentPlatform platform;
@property (copy, nonatomic) NSString *iconName; //icon
@property (copy, nonatomic) NSString *title;    //平台名称
@property (copy, nonatomic) NSString *desc;     //描述
@property (copy, nonatomic) NSString *decorateImageName;//右侧icon

@property (assign, nonatomic) BOOL selected;

+ (instancetype)itemWithPlatform:(YGPaymentPlatform)platform;
+ (NSArray<YGPayPlatformItem *> *)itemsWithPlatforms:(NSArray<NSNumber *> *)platforms;


@end
