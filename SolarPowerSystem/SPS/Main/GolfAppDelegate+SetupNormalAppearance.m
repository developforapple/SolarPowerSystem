//
//  GolfAppDelegate+SetupNormalAppearance.m
//  Golf
//
//  Created by liangqing on 16/8/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "GolfAppDelegate+SetupNormalAppearance.h"
#import "UIKit+yg_IBInspectable.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <WeiboSDK.h>
#import "WXApi.h"
#import "YYTextView.h"

@implementation GolfAppDelegate (SetupNormalAppearance)
#pragma mark - Application Setupf
- (void)setupNormalAppearance{
    UIColor *naviTintColor = MainTintColor;
    
//    self.window.tintColor = naviTintColor;
    
    // Normal
//    [[UIWindow appearance] setTintColor:naviTintColor];
    
    // 导航栏内的统一样式
    [[UINavigationBar appearance] setTintColor:naviTintColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:naviTintColor}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:naviTintColor} forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:MainHighlightColor} forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:MainHighlightColor} forState:UIControlStateNormal];
    [[UISegmentedControl appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:MainHighlightColor];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:naviTintColor forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:MainHighlightColor forState:UIControlStateHighlighted];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:MainHighlightColor forState:UIControlStateSelected];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:naviTintColor];
    
    [[UILabel appearanceWhenContainedIn:[UINavigationBar class], nil] setTextColor:naviTintColor];
    
    // 不显示默认的返回按钮
    //    UIImage *backButtonImage = [[UIImage imageNamed:@"ic_nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    [[UINavigationBar appearance] setBackIndicatorImage:nil];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:nil];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, -64.f) forBarMetrics:UIBarMetricsDefault];
    
    if ([[UITabBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
        [[UITabBar appearance] setTranslucent:YES]; //iOS7下会Crash
    }
    [[UITabBar appearance] setTintColor:MainHighlightColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:MainHighlightColor} forState:UIControlStateSelected];
    
    // TextField
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont systemFontOfSize:13]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:MainTintColor];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:MainHighlightColor];
    
    [[UITextField appearance] setTintColor:MainHighlightColor];     //光标颜色
    [[UITextView appearance] setTintColor:MainHighlightColor];      //光标颜色
    
    // 控制器的统一样式，在 UIKit+yg_IBInspectable.h 内 UIViewController 类别下进行设置
    
    // HUD
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:.7]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setMinimumDismissTimeInterval:1.4];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] registerTextFieldViewClass:[YYTextView class] didBeginEditingNotificationName:YYTextViewTextDidBeginEditingNotification didEndEditingNotificationName:YYTextViewTextDidEndEditingNotification];
    
//    if (!kProductionEnvironment) {
//        [[IQKeyboardManager sharedManager] setEnableDebugging:YES];
//    }
}

- (void)registThirdTools{
    
    [MobClick setCrashReportEnabled:YES];
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    UMConfigInstance.appKey = kUMengAppKey;
    UMConfigInstance.ePolicy = BATCH;
    [MobClick startWithConfigure:UMConfigInstance];
    
    //微博
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:kWeiboAppKey];
    
    //微信
    [WXApi registerApp:kWechatAppKey];
}



@end
