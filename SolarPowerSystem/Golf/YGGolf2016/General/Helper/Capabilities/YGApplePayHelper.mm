//
//  YGApplePayHelper.m
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGApplePayHelper.h"
#import <PassKit/PassKit.h>

@implementation YGApplePayHelper

+ (BOOL)isApplePayAvailable
{
    return  [PKPaymentAuthorizationViewController class] &&
            [PKPaymentAuthorizationViewController canMakePayments];
}

+ (BOOL)isSupportUnionPay
{
    return NO;
//    return  [self isApplePayAvailable] && iOSLater(9.2f) && [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkChinaUnionPay]];
}

@end

