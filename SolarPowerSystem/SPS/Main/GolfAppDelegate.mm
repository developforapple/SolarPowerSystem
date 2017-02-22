//
//  GolfAppDelegate.m
//  Golf
//
//  Created by Dejohn Dong on 11-11-14.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import "GolfAppDelegate.h"
#import "YGWebBrowser.h"

#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>
#import "WXApi.h"
#import <WeiboSDK.h>
#import "GolfAppDelegate+SetupNormalAppearance.h"
#import "YGRemoteNotificationHelper.h"

static NSString * const kGolfPlus = @"GolfPlus";

@interface GolfAppDelegate () <WXApiDelegate, CLLocationManagerDelegate,UINavigationControllerDelegate,WeiboSDKDelegate>
{
    CLLocationManager * _locationManage;
}
@end

@implementation GolfAppDelegate{
    
}

#pragma mark - Application Launching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self reach];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 设置应用全局外观
    [self setupNormalAppearance];
    // 注册友盟、微信等
    [self registThirdTools];
    
    // 处理可能的通知内容
    [self setupRemoteNotification:launchOptions];
    
    self.tabBarController = [YGTabBarController defaultController];
    
    float currVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ScanTheGuidPicture"] floatValue] < currVersion) {
        [[NSUserDefaults standardUserDefaults] setObject:@(currVersion) forKey:@"ScanTheGuidPicture"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WillFriendsRemind"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        /**
         引导页
         */
//        GuideViewController *guideVC = [[GuideViewController alloc] init];
//        self.window.rootViewController = guideVC;
    }else{
        [self.window setRootViewController:self.tabBarController];
        [self startRemoteNotification];
    }
   
    [self.window makeKeyAndVisible];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self setInitPramas];

    //监测HTTP服务器错误及异常
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(solveHttpError:) name:@"checkHttpError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessed:) name:@"LOGIN_SUCCESSED" object:nil];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {//lyf 加
    if (_tabBarController.nav_3) {
        [self.tabBarController changeReadyToSend];
    } else {
        [self.tabBarController getYaoCurrent];
    }
    
}

- (NSMutableDictionary *)dictionaryWithObject:(id)object dictionary:(NSMutableDictionary *)dict key:(NSString *)key{
    [dict setObject:object forKey:key];
    return dict;
}

-(void)loginSuccessed:(NSNotification *)ns{
    
    [self refreshBadgeValue];
    [self deviceInfoUpload];
}

- (void)deviceInfoUpload{
    
}


#pragma mark - 通知处理
// 已在 YGNotification 类别中实现了通知相关的代理。不要在其他地方再实现。

- (void)setupRemoteNotification:(NSDictionary *)launchOptions
{
    [[YGRemoteNotificationHelper shared] setDeviceTokenDidReceivedCompletionHandler:^(NSString *str) {
        [self deviceInfoUpload];
    }];
    [[YGRemoteNotificationHelper shared] setDidReceiveRemoteNotificationHandler:^(NSDictionary *userInfo) {
        [self handleRemoteNotification:userInfo];
    }];
    [[YGRemoteNotificationHelper shared] setDidReceiveLocalNotificationHandler:^(UILocalNotification *noti) {
        [self handleLocalNotification:noti];
    }];
    [[YGRemoteNotificationHelper shared] setup:launchOptions];
}

- (void)startRemoteNotification
{
    [[YGRemoteNotificationHelper shared] registerNotificationType:YGNotificationTypeAll];
}

// 处理远程通知
- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (msg != nil) {
        NSString *dataType = [userInfo objectForKey:@"data_type"];
        NSString *subType = [userInfo objectForKey:@"sub_type"];
        NSInteger dataId = 0;
        if ([userInfo objectForKey:@"data_id"]) {
            dataId = [[userInfo objectForKey:@"data_id"] integerValue];
        }
        
        NSString *dataExtra = nil;
        if ([userInfo objectForKey:@"data_extra"]) {
            dataExtra = [userInfo objectForKey:@"data_extra"];
        }
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {//app在后台不执行下面代码
            return;
        }
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            
            
        }
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
            
        }
    }
}

- (void)handlePushNotificationCancel:(NSDictionary *)userInfo {
    NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (msg) {
        if (userInfo) {
            NSString *dataType = [userInfo objectForKey:@"data_type"];
            if (Equal(dataType, @"friend")) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWFOOLOWED" object:nil];
            }
        }
    }
}

- (void)handlePushNotification:(NSDictionary *)userInfo{
    NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (msg) {
        [self handlePushControllerWithData:userInfo];
    }
}

- (void)handlePushControllerWithData:(NSDictionary *)data{
    
}


- (void)handleLocalNotification:(UILocalNotification *)notification
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.tabBarController.selectedIndex = 0;
    NSDictionary *notificateDic = [notification userInfo];
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    
}

- (void)setInitPramas{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[array objectAtIndex:0] stringByAppendingPathComponent:@"CoachParasData"];
    if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    // 百度移动统计
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = NO;
    statTracker.channelId = @"Cydia";
    statTracker.sessionResumeInterval = 30;
    statTracker.logSendInterval = 1;
    [statTracker startWithAppId:@"266972f376"];
    
    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *version = [NSString stringWithFormat:@"%@,%@",osVersion,appVersion];
    NSString *customUserAgent = [userAgent stringByAppendingFormat:@" golfplus/%@", version];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_2) {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManage startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //定位成功发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatgeLocations" object:nil];
}

+ (GolfAppDelegate *)shareAppDelegate{
    return (GolfAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

#pragma mark - default Application Methods

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNewsCount" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"\n ===> 程序进入后台 !");
}
 
-(void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma mark - 检测网络连接
- (void)reach
{
    self.networkReachabilityStatus = AFNetworkReachabilityStatusReachableViaWiFi;
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.networkReachabilityStatus = status;
        NSLog(@"网络发生了变化%tu",status);
        if (self.networkReachabilityStatus <= 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNetworkReachabilityStatusUnknown" object:nil];
        }else{

        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(BOOL)networkReachability{
    if (self.networkReachabilityStatus <= 0) {
        [SVProgressHUD showInfoWithStatus:@"当前网络不可用"];
        return NO;
    }
    return YES;
}
@end

