//
//  GolfAppDelegate.h
//  Golf
//
//  Created by 黄希望 on 11-11-14.
//  Copyright (c) 2012年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemParamInfo.h"
#import "YGTabBarController.h"
#import "AFNetworking.h"

@class BaseNavController;
@class SpecialOfferListViewController;
@class IndexViewController;
@class YGLoginViewCtrl;
@class YGMineViewCtrl;
@class FootprintMainViewController;
@class TrendsMainViewController;
@class SearchCityModel;

#define KUpmpPayMode @"00"

#define KDefaultTimeInterGab  1000000.f

#define YGAppDelegate [GolfAppDelegate shareAppDelegate]

@interface GolfAppDelegate : UIResponder <UIApplicationDelegate>{
    UIActivityIndicatorView *_acitityIndictorView;
    __weak UINavigationController *nav_1;
    __weak UINavigationController *nav_2;
    __weak UINavigationController *nav_4;
    __weak UINavigationController *nav_5;
    UIButton *_btnDone;
    
    //判断AlertView是否已经显
    BOOL _isShowAlert;
    
    //搜索范围
    NSString *_range;
    NSString *_token;
    BOOL _autoLogIn;
    BOOL _isLoadDeviceInfo;
    
    NSString *_yungaoUrlStr;
    
    NSTimeInterval lastQueryTime;
}
@property(nonatomic,assign) BOOL loginViewShowed;
@property(nonatomic,weak) BaseNavController *currentController;
@property(nonatomic,weak) UINavigationController *naviController;
@property(nonatomic,weak) TrendsMainViewController *trendsMainViewController;
@property(nonatomic,weak) IndexViewController *home;
@property(nonatomic,weak) FootprintMainViewController *myfootPrint;
@property(nonatomic,weak) YGMineViewCtrl *accountCenter;
@property(nonatomic,strong) YGTabBarController *tabBarController;
@property(nonatomic,strong) UIWindow *window;
@property(nonatomic,strong) UIButton *btnDone;
@property(nonatomic,strong) NSDate *selectedDate;
@property(nonatomic) BOOL isShowAlert;
@property(nonatomic,copy) NSString *range;
//@property(nonatomic,copy) NSString *token;
@property(nonatomic,copy) NSString *yungaoUrlStr;
@property(nonatomic) BOOL autoLogIn;
@property(nonatomic) int type;
@property(nonatomic,strong) SystemParamInfo *systemParamInfo;
@property(nonatomic,strong) NSDictionary *notificationUseInfo;
@property(nonatomic) NSInteger lastSelectedIndex;
@property(nonatomic,strong) NSDictionary *emijiDic;
@property(nonatomic,strong) NSString *currentCity;
@property(nonatomic,strong) NSString *locality;
@property(nonatomic,strong) NSDictionary *addressDictionary;
@property(nonatomic,strong) SearchCityModel *searchCityModel;
@property(nonatomic,assign) AFNetworkReachabilityStatus networkReachabilityStatus;
@property(nonatomic,strong) UIView *badgeYQView;
@property(nonatomic) BOOL isInviteNewUser;
@property(nonatomic,strong) NSDictionary *remoteNotificationKeyDic;
@property BOOL isFirstLocationShowYaoBallHints;
@property (nonatomic,assign) int msgCount;//未读私信条数
@property (nonatomic,assign) BOOL isFirstEnterPush;//是否第一次进推送
@property (nonatomic,assign) BOOL isLocationSuccess;//GolfAppDelegate是否定位成功
@property (nonatomic,copy) NSString *memberID;//动态精选推荐用户memberID
@property (nonatomic,assign) BOOL isClickAlerView;//是否是点击推送alertView跳转
@property (nonatomic,assign) BOOL isFirstEnterApp;//是否是第一次进APP

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

