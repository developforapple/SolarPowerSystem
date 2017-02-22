//
//  YGPaymentResult.h
//  Golf
//
//  Created by bo wang on 2016/10/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YGPayStatus) {
    YGPayStatusSuccess = 0,
    YGPayStatusFailed = 1,
    YGPayStatusCanceled = 2,
};

@class UPPayResult;
@class BaseResp;

@interface YGPaymentResult : NSObject

@property (strong, nonatomic) id originData;

@property (copy, nonatomic) NSString *sessionId;
@property (assign, nonatomic) NSInteger tranId;
@property (assign, nonatomic) YGPayStatus status; //0成功 1失败 2取消

@property (strong, nonatomic) NSArray *awardCoupon;//奖励的现金券
@property (strong, nonatomic) AwardModel *awardRedPackt; //奖励的红包

+ (instancetype)wechatResult:(BaseResp *)resp;
+ (instancetype)alipayResult:(NSDictionary *)result;
+ (instancetype)unionpayResult:(NSString *)result;
+ (instancetype)applepayResult:(UPPayResult *)result;

@end


typedef NS_ENUM(NSUInteger, AlipayStatus) {
    AlipayStatusSuccess = 9000,     //成功
    AlipayStatusPaying = 8000,      //正在支付
    AlipayStatusFailed = 4000,      //失败
    AlipayStatusCanceled = 6001,    //用户取消
    AlipayStatusNetworkErr = 6002,  //网络错误
};

FOUNDATION_EXTERN NSString * AliPayResultMessage(AlipayStatus status);
