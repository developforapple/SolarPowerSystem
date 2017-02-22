//
//  YGPaymentResult.m
//  Golf
//
//  Created by bo wang on 2016/10/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPaymentResult.h"
#import "UPAPayPluginDelegate.h"
#import "WXApi.h"

@implementation YGPaymentResult

+ (instancetype)wechatResult:(BaseResp *)resp
{
    if (!resp || ![resp isKindOfClass:[BaseResp class]])  return nil;
    
    YGPaymentResult *result = [YGPaymentResult new];
    result.originData = resp;
    result.sessionId = [[LoginManager sharedManager] getSessionId];
    
    if (resp.errCode == WXSuccess) {
        result.status = YGPayStatusSuccess;
    }else if (resp.errCode == WXErrCodeUserCancel){
        result.status = YGPayStatusCanceled;
    }else{
        result.status = YGPayStatusFailed;
    }
    return result;
}

+ (instancetype)alipayResult:(NSDictionary *)resultDic
{
    YGPaymentResult *result = [YGPaymentResult new];
    result.originData = resultDic;
    result.sessionId = [[LoginManager sharedManager] getSessionId];
    
    NSInteger alipayStatus = [resultDic[@"resultStatus"] integerValue];
    if (alipayStatus == AlipayStatusSuccess) {
        result.status = YGPayStatusSuccess;
    }else if (alipayStatus == AlipayStatusFailed || alipayStatus == AlipayStatusNetworkErr){
        result.status = YGPayStatusFailed;
    }else if (alipayStatus == AlipayStatusCanceled){
        result.status = YGPayStatusCanceled;
    }
    return result;
}

+ (instancetype)unionpayResult:(NSString *)resultStr
{
    YGPaymentResult *result = [YGPaymentResult new];
    result.originData = resultStr;
    result.sessionId = [[LoginManager sharedManager] getSessionId];
    
    if ([resultStr isEqualToString:@"success"]) {
        result.status = YGPayStatusSuccess;
    }else if ([resultStr isEqualToString:@"cancel"]){
        result.status = YGPayStatusCanceled;
    }else if([resultStr isEqualToString:@"fail"]){
        result.status = YGPayStatusFailed;
    }
    return result;
}

+ (instancetype)applepayResult:(UPPayResult *)payResult
{
    YGPaymentResult *result = [YGPaymentResult new];
    result.originData = payResult;
    result.sessionId = [[LoginManager sharedManager] getSessionId];
    
    switch (payResult.paymentResultStatus) {
        case UPPaymentResultStatusSuccess: result.status = YGPayStatusSuccess;break;
        case UPPaymentResultStatusFailure: result.status = YGPayStatusFailed;break;
        case UPPaymentResultStatusCancel:  result.status = YGPayStatusCanceled;break;
        case UPPaymentResultStatusUnknownCancel:result.status = YGPayStatusCanceled;break;
    }
    return result;
}

@end

NSString * AliPayResultMessage(AlipayStatus status){
    switch (status) {
        case AlipayStatusSuccess:   return @"订单支付成功";   break;
        case AlipayStatusPaying:    return @"正在处理中";    break;
        case AlipayStatusFailed:    return @"订单支付失败";   break;
        case AlipayStatusCanceled:  return @"用户中途取消";   break;
        case AlipayStatusNetworkErr: return @"网络连接出错";  break;
    }
    return nil;
}
