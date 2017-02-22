//
//  YGPayPlatformItem.m
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayPlatformItem.h"

NSString * PayPlatformType(YGPaymentPlatform platform){
    switch (platform) {
        case YGPaymentPlatformInApp:    return @"";         break;
        case YGPaymentPlatformWechat:   return @"wechatapp";break;
        case YGPaymentPlatformAlipay:   return @"aliapp";   break;
        case YGPaymentPlatformUnionpay: return @"upmppay";  break;
        case YGPaymentPlatformApplePay: return @"applepay"; break;
        case YGPaymentPlatformYunGao:   return @"yungao";   break;/*TODO*/
    }
    return @"";
}

@implementation YGPayPlatformItem

+ (instancetype)itemWithPlatform:(YGPaymentPlatform)platform
{
    YGPayPlatformItem *item = [YGPayPlatformItem new];
    item.platform = platform;
    switch (platform) {
        case YGPaymentPlatformInApp:break;
        case YGPaymentPlatformWechat:{
            item.iconName = @"bg_pay_wechat";
            item.title = @"微信支付";
            item.desc = @"推荐开通了微信支付的用户使用";
        }   break;
        case YGPaymentPlatformAlipay:{
            item.iconName = @"bg_pay_alipay";
            item.title = @"支付宝支付";
            item.desc = @"推荐开通了支付宝支付的用户使用";
        }   break;
        case YGPaymentPlatformUnionpay:{
            item.iconName = @"bg_pay_unionpay";
            item.title = @"银联手机支付";
            item.desc = @"支持储蓄卡和信用卡，无需开通网银";
        }   break;
        case YGPaymentPlatformApplePay:{
            item.iconName = @"bg_pay_applepay";
            item.title = @"Apple Pay";
            item.desc = @"Apple专属 安全支付";
            item.decorateImageName = @"bg_pay_applepay_union";
        }   break;
        case YGPaymentPlatformYunGao:{
            item.iconName = @"bg_pay_yungao";
            item.title = @"云高垫付";
            item.desc = @"需在打完球后把垫付金额充值至您的账户";
        }   break;
    }
    return item;
}

+ (NSArray<YGPayPlatformItem *> *)itemsWithPlatforms:(NSArray<NSNumber *> *)platforms
{
    NSMutableArray *items = [NSMutableArray array];
    for (NSNumber *aPlatform in platforms) {
        [items addObject:[self itemWithPlatform:aPlatform.integerValue]];
    }
    return items;
}

@end
