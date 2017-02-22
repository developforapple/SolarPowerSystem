//
//  YGApplePayHelper.h
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGApplePayHelper : NSObject

// ApplePay 是否可用
@property (class, readonly, getter=isApplePayAvailable, nonatomic) BOOL applePayAvailable;
// ApplePay 银联支付是否可用
@property (class, readonly, getter=isSupportUnionPay, nonatomic) BOOL supportUnionPay;

@end
