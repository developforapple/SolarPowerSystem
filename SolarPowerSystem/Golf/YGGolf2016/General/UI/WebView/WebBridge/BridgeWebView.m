//
//  BridgeWebView.m
//  Golf
//
//  Created by 黄希望 on 15-1-7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BridgeWebView.h"
#import "WebViewJavascriptBridge.h"

@interface BridgeWebView ()<YGLoginViewCtrlDelegate>
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (assign, nonatomic) WVJBResponseCallback responseCallBack;

@end

@implementation BridgeWebView

- (void) webviewJavaScriptImplement:(BaseNavController *)aContoller{
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self webViewDelegate:(id)aContoller handler:^(id data, WVJBResponseCallback responseCallback) {
    }];
    
    [_bridge registerHandler:@"user_info" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)data;
            if (dic[@"auto_login"]) {
                int autoLogin = [dic[@"auto_login"] intValue];
                if (autoLogin > 0) {
                    if ([LoginManager sharedManager].loginState) {
                        
                        id callBack = [self param];
                        
                        responseCallback(callBack);
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:self controller:aContoller animate:YES];
                    }
                }
            }
        }
    }];
    
    [_bridge registerHandler:@"execute_task" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:data];
    }];
}

- (void)loginButtonPressed:(id)sender{
    [self reload];
}

- (id)param{
    NSString *osName = [[UIDevice currentDevice] systemName];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic setObject:@([LoginManager sharedManager].session.memberId) forKey:@"member_id"];
    [mutDic setObject:[LoginManager sharedManager].session.mobilePhone forKey:@"mobile_phone"];
    [mutDic setObject:@([LoginManager sharedManager].currLongitude) forKey:@"longitude"];
    [mutDic setObject:@([LoginManager sharedManager].currLatitude) forKey:@"latitude"];
    [mutDic setObject:[osVersion stringByAppendingFormat:@",%@",appVersion] forKey:@"os_version"];
    [mutDic setObject:osName forKey:@"os_name"];
    
    return mutDic;
}

@end
