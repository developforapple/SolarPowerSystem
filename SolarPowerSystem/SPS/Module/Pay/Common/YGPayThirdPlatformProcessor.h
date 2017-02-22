//
//  YGPayThirdPlatformProcessor.h
//  Golf
//
//  Created by bo wang on 2016/12/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGPayThirdPlatform.h"

FOUNDATION_EXTERN NSString *const kAlipayScheme;
FOUNDATION_EXTERN NSString *const kUnionPayScheme;

@class PayResp;
@class YGPaymentResult;

@protocol YGPayProcess <NSObject>
@required
- (void)didReceivedThirdPayPlatformResult:(YGPaymentResult *)result platform:(YGPayThirdPlatform)platform;
@end

@interface YGPayThirdPlatformProcessor : NSObject

// 默认debugMode为NO
+ (void)setDebugMode:(BOOL)debugMode;

@property (weak, nonatomic) id<YGPayProcess> receiver;
@property (weak, nonatomic) UIViewController *viewCtrl;

// 调起第三方支付。payInfo为服务端返回的支付信息
- (void)pay:(id)payInfo platform:(YGPayThirdPlatform)platform;

// 处理支付宝支付和银联支付
+ (BOOL)handleOpenURL:(NSURL *)URL;
// 处理微信支付
+ (void)handleWechatResp:(PayResp *)resp;

@end
