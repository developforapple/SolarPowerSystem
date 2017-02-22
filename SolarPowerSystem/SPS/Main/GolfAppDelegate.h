//
//  GolfAppDelegate.h
//  Golf
//
//  Created by 黄希望 on 11-11-14.
//  Copyright (c) 2012年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGTabBarController.h"
#import "AFNetworking.h"

@class BaseNavController;
@class YGLoginViewCtrl;

#define KUpmpPayMode @"00"

#define KDefaultTimeInterGab  1000000.f

#define YGAppDelegate [GolfAppDelegate shareAppDelegate]

@interface GolfAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic,strong) YGTabBarController *tabBarController;
@property(nonatomic,strong) UIWindow *window;

@property(nonatomic,assign) AFNetworkReachabilityStatus networkReachabilityStatus;

+ (GolfAppDelegate *)shareAppDelegate;

- (BOOL)networkReachability;

- (void)alert:(NSString *)title message:(NSString*)message;
//WebView显示
- (void)showInstruction:(NSString*)url title:(NSString*)title WithController:(UIViewController*)controller;

- (void)pushViewController:(BaseNavController*)viewController WithController:(UIViewController*)controller title:(NSString *)title hide:(BOOL)isHide;

- (void)startUpdateLocation;
- (void)startRemoteNotification;

- (void)handlePushControllerWithData:(NSDictionary *)data;

// type://2.普通列表 3.表示品牌列表  data: type=2传类别id type=3 传品牌id extro(现金券名);
- (void)pushToCommodityWithType:(NSInteger)aType dataId:(int)aDataId extro:(NSString*)extro controller:(__kindof UIViewController *)controller;

- (void)refreshBadgeValue;
@end

