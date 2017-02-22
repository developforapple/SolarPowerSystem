//
//  YGPayThirdPlatformProcessor.m
//  Golf
//
//  Created by bo wang on 2016/12/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayThirdPlatformProcessor.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UPPaymentControl.h"
#import "UPAPayPlugin.h"
#import "UPAPayPluginDelegate.h"
#import "YGPaymentResult.h"
#import "WXApi.h"

static BOOL kDebugMode = NO;

static NSString *const kYGMerchantIdentifier = @"merchant.com.cgit.golf";

static NSString *const kYGPayAlipayNotification = @"ALiPayCallBack";
static NSString *const kYGPayWechatNotification = @"WXCallBack";
static NSString *const kYGPayUnionPayNotification = @"UPPayCallback";//unionpayCallback
static NSString *const kYGPayApplePayNotification = @"ApplePayCallback";

NSString *const kAlipayScheme = @"golfaliapp";
NSString *const kUnionPayScheme = @"golfunionpay";

@interface YGPayThirdPlatformProcessor () <UPAPayPluginDelegate>
@end

@implementation YGPayThirdPlatformProcessor

+ (void)setDebugMode:(BOOL)debugMode
{
    kDebugMode = debugMode;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_alipayCallback:) name:kYGPayAlipayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_wechatCallback:) name:kYGPayWechatNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_uppayCallback:) name:kYGPayUnionPayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applePayCallback:) name:kYGPayApplePayNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIViewController *)viewCtrl
{
    if (!_viewCtrl) {
        return [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return _viewCtrl;
}

- (void)_alipayCallback:(NSNotification *)noti
{
    NSDictionary *result = noti.object;
    [self handlePayResult:result platform:YGPayThirdPlatformAlipay];
}

- (void)_wechatCallback:(NSNotification *)noti
{
    PayResp *resp = noti.object;
    [self handlePayResult:resp platform:YGPayThirdPlatformWechat];
}

- (void)_uppayCallback:(NSNotification *)noti
{
    NSString *code = noti.object;
    NSDictionary *info = noti.userInfo;
    [self handlePayResult:code platform:YGPayThirdPlatformUPPay];
}

- (void)_applePayCallback:(NSNotification *)noti
{
    UPPayResult *result = noti.object;
    [self handlePayResult:result platform:YGPayThirdPlatformApplePay];
}

- (void)handlePayResult:(id)result platform:(YGPayThirdPlatform)platform
{
    YGPaymentResult *theResult;
    switch (platform) {
        case YGPayThirdPlatformWechat:{
            theResult = [YGPaymentResult wechatResult:result];
        }   break;
        case YGPayThirdPlatformAlipay:{
            theResult = [YGPaymentResult alipayResult:result];
        }   break;
        case YGPayThirdPlatformUPPay:{
            theResult = [YGPaymentResult unionpayResult:result];
        }   break;
        case YGPayThirdPlatformApplePay:{
            theResult = [YGPaymentResult applepayResult:result];
        }   break;
    }
    
    if ([self.receiver respondsToSelector:@selector(didReceivedThirdPayPlatformResult:platform:)]) {
        [self.receiver didReceivedThirdPayPlatformResult:theResult platform:platform];
    }
}

- (void)pay:(id)payInfo platform:(YGPayThirdPlatform)platform
{
    switch (platform) {
        case YGPayThirdPlatformWechat:{
            NSDictionary *info = payInfo;
            if (!info || ![info isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            PayReq *req = [[PayReq alloc] init];
            req.partnerId = info[@"partnerid"];
            req.prepayId = info[@"prepayid"];
            req.package = info[@"package"];
            req.nonceStr = info[@"noncestr"];
            req.timeStamp = (UInt32)[info[@"timestamp"] integerValue];
            req.sign = info[@"sign"];
            [WXApi sendReq:req];
            
        }   break;
        case YGPayThirdPlatformAlipay:{
            
            NSString *info = payInfo;
            if (!info || ![info isKindOfClass:[NSString class]]) {
                return;
            }
        
            NSString *xml = [info stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            [[AlipaySDK defaultService] payOrder:xml fromScheme:@"golfaliapp" callback:^(NSDictionary *resultDic) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYGPayAlipayNotification object:resultDic userInfo:nil];
            }];
            
        }   break;
        case YGPayThirdPlatformUPPay:{
            
            NSString *info = payInfo;
            if (!info || ![info isKindOfClass:[NSString class]]) {
                return;
            }
            
            [[UPPaymentControl defaultControl] startPay:info fromScheme:kUnionPayScheme mode:kDebugMode?@"01":@"00" viewController:self.viewCtrl];
            
        }   break;
        case YGPayThirdPlatformApplePay:{
            
            //TEST
            NSURL* url = [NSURL URLWithString:@"http://101.231.204.84:8091/sim/getacptn"];
            NSString *xml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            //TEST
//            NSString *xml = self.payment.payModel.payXML;
            if ([xml isKindOfClass:[NSString class]]) {
                [UPAPayPlugin startPay:xml mode:kDebugMode?@"01":@"00" viewController:self.viewCtrl delegate:self andAPMechantID:kYGMerchantIdentifier];
            }
            
        }   break;
    }
}

- (void)UPAPayPluginResult:(UPPayResult *) payResult
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kYGPayApplePayNotification object:payResult userInfo:nil];
}

+ (BOOL)handleOpenURL:(NSURL *)URL
{
    NSString *scheme = URL.scheme;
    if ([scheme isEqualToString:kAlipayScheme]) {
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:URL standbyCallback:^(NSDictionary *resultDic) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYGPayAlipayNotification object:resultDic userInfo:nil];
            
        }];
        
        return YES;
    }else if ([scheme isEqualToString:kUnionPayScheme]){
        
        [[UPPaymentControl defaultControl] handlePaymentResult:URL completeBlock:^(NSString *code, NSDictionary *data) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYGPayUnionPayNotification object:code userInfo:data];
            
        }];
        
        return YES;
    }else{
        return NO;
    }
}

+ (void)handleWechatResp:(PayResp *)resp
{
    if (!resp || ![resp isKindOfClass:[PayResp class]]) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:kYGPayWechatNotification object:resp userInfo:nil];
}

@end
