//
//  YGPayThirdPlatform.h
//  Golf
//
//  Created by bo wang on 2016/12/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGPayThirdPlatform_h
#define YGPayThirdPlatform_h

typedef NS_ENUM(NSUInteger, YGPayThirdPlatform) {
    YGPayThirdPlatformWechat = 1,   //微信支付
    YGPayThirdPlatformAlipay = 2,   //支付宝支付
    YGPayThirdPlatformUPPay = 3,    //银联控件支付
    YGPayThirdPlatformApplePay = 4, //ApplePay
};

#endif /* YGPayThirdPlatform_h */
