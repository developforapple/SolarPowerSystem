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

@interface GolfAppDelegate () <WXApiDelegate, CLLocationManagerDelegate,UINavigationControllerDelegate,WeiboSDKDelegate,YGLoginViewCtrlDelegate>
{
    CLLocationManager * _locationManage;
}
@end

@implementation GolfAppDelegate{
    BOOL firstBecomeActive; //注意：应用程序在启动时，在调用了 applicationDidFinishLaunching 方法之后也会调用 applicationDidBecomeActive 方法，所以你要确保你的代码能够分清复原与启动，避免出现逻辑上的bug。所以这里标记一下
    BOOL toChatProcessing;//当前正在进入聊天对话框的处理
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
    [self passedValue];
    
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
    if (Equal([url scheme], @"yungaogolf")) {
        
    }
    else if (Equal([url scheme], @"wb2911809260")) {
        return  [WeiboSDK handleOpenURL:url delegate:self];
    }else if (Equal([url scheme], @"wxb4f02e0ddf46579a")){
        return  [WXApi handleOpenURL:url delegate:self];
    }else if ([YGPayThirdPlatformProcessor handleOpenURL:url]){
        return YES;
    }else if (Equal([url scheme], @"iosamap")){
        // ******************
        return NO;
    }else if (Equal([url scheme], @"baidumap")){
        // ******************
        return NO;
    }else if (Equal([url scheme], @"golfapi")){
        NSDictionary *data = [Utilities webInterfaceToDic:url prefix:@"golfapi://?"];
        [self handlePushControllerWithData:data];
        return YES;
    }else{
        return NO;
    }
}

-(void) onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {
            SendAuthResp *r = (SendAuthResp*)resp;
            NSString *code = r.code;
            if (code.length>0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AccessTokenCode" object:code];
            }
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        NSString *strMsg = nil;
        
        if (self.type > 0) {
            if (resp.errCode == 0) {
                // 数据上报采集点
                if (self.type == 1) {
                    [[BaiduMobStat defaultStat] logEvent:@"sharePublicClass1" eventLabel:@"公开课查看分享"];
                    [MobClick event:@"sharePublicClass1" label:@"公开课查看分享"];
                }else if (self.type == 2){
                    [[BaiduMobStat defaultStat] logEvent:@"sharePublicClass2" eventLabel:@"公开课报名分享"];
                    [MobClick event:@"sharePublicClass2" label:@"公开课报名分享"];
                }
            }
        }
        self.type = 0;
        BOOL have = NO;
        switch (resp.errCode) {
            case 0:
                have = YES;
                strMsg = _isInviteNewUser ? @"已邀请" : @"分享成功";
                break;
            case -1:
                have = NO;
                strMsg = _isInviteNewUser ? @"邀请失败" : @"分享失败";
                break;
            case -2:
                have = NO;
                strMsg = _isInviteNewUser ? @"取消邀请" : @"您已取消分享";
                break;
            case -3:
                have = NO;
                strMsg = _isInviteNewUser ? @"邀请失败" : @"分享失败";
                break;
            case -4:
                //strMsg = @"信息分享未取得授权";
                break;
            case -5:
                //strMsg = @"不支持分享功能";
                break;
                
            default:
                break;
        }
        
        NSDictionary *dictionary;
        if (resp.errCode==0) {
            dictionary=[NSDictionary dictionaryWithObject:@([[NSUserDefaults standardUserDefaults]integerForKey:@"reqScene"]) forKey:@"flag"];
        }else{
            dictionary=[NSDictionary dictionaryWithObject:@0 forKey:@"flag"];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"topicShareOver" object:dictionary];
        
        if (strMsg) {
            if (_isInviteNewUser) {
                _isInviteNewUser = NO;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"inviteNewUserInAddressBookFriends" object:@{@"flag":@(resp.errCode + 1)}];
            }
            if (have) {
                [SVProgressHUD showSuccessWithStatus:strMsg];
            }else{
                [SVProgressHUD showInfoWithStatus:strMsg];
            }
        }
    }else if ([resp isKindOfClass:[PayResp class]]){
        [YGPayThirdPlatformProcessor handleWechatResp:(PayResp *)resp];
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    //NSLog(@"idReceiveWeiboRequest ");
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSString *strMsg = nil;
    BOOL have = NO;
    switch (response.statusCode) {
        case 0:
            have = YES;
            strMsg = _isInviteNewUser ? @"已邀请" : @"分享成功";
            break;
        case -1:
            have = NO;
            strMsg = _isInviteNewUser ? @"取消邀请" : @"您已取消分享";
            break;
        case -2:
            have = NO;
            strMsg = _isInviteNewUser ? @"邀请失败" : @"分享失败";
            break;
        case -3:
            //strMsg = @"信息分享未取得授权";
            break;
        case -4:
            //strMsg = @"不支持分享功能";
            break;
            
        default:
            break;
    }
    
    NSDictionary *dictionary;
    if (response.statusCode==0) {
        dictionary=[NSDictionary dictionaryWithObject:@3 forKey:@"flag"];
    }else{
        dictionary=[NSDictionary dictionaryWithObject:@0 forKey:@"flag"];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"topicShareOver" object:dictionary];
    
    if (strMsg) {
        if (_isInviteNewUser) {
            _isInviteNewUser = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"inviteNewUserInAddressBookFriends" object:@{@"flag":@(response.statusCode + 1)}];
        }
        if (have) {
            [SVProgressHUD showSuccessWithStatus:strMsg];
        }else{
            [SVProgressHUD showInfoWithStatus:strMsg];
        }
    }
}

#pragma mark - HTTP Error Solve Methods

/* 异常code
 100001	请求参数不正确
 100002	处理请求异常
 100003	用户session已过期，重新登录
 100004	用户已经被禁用
 100005 账号未登录
 100006	账号已在别处登录
 100007	用户名或密码错误
 100008	其他错误，可根据返回消息提示
 */

- (void)solveHttpError:(NSNotification *)notification{
    HttpErroCodeModel *model = (HttpErroCodeModel *)[notification object];
    
    if ([model.errorMsg isEqualToString:@"获取城市天气预报失败"] && model.code == 100008) { //天气预报获取失败就不用再提示了。获取不到没有什么的，不需要弹框告诉用户。
        return;
    }
    
    if (model.code == 100005 || model.code == 100006){
        if(!_isShowAlert){
            if (model && model.errorMsg.length > 0) {
                [self checkPasswordLogin:model];
            }
        }
    }else if(model.code == 100003){
        [self checkPasswordLogin:model];
    }else if (model.code == 100008 || model.code == 100010 || model.code == 100002 || model.code == 100007){//lyf 加了100002 100007 从第一个情况拆了出来，因为需要提示
        CCAlertView *alt = [[CCAlertView alloc] initWithTitle:@"提示" message:model.errorMsg];
        [alt addButtonWithTitle:@"确定" block:^{
            if (model.code == 100007) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGolfUserPassword];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[LoginManager sharedManager] loginWithDelegate:(id<YGLoginViewCtrlDelegate>)self.currentController controller:self.currentController animate:YES];
            }
        }];
        [alt show];

    }
}

- (void)checkPasswordLogin:(HttpErroCodeModel *)model{
    _isShowAlert = YES;
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(changeTheIsShowAlert) userInfo:nil repeats:NO];
    [MobClick profileSignOff];
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:KGolfUserPassword];
    if ((phoneNum.length && phoneNum > 0) && (password.length > 0 && password)) {
        [self autoLoginWithPhone:phoneNum andPassword:password];
    }else{
        [LoginManager sharedManager].loginState = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LoginManager sharedManager] loginWithDelegate:(id<YGLoginViewCtrlDelegate>)self.currentController controller:self.currentController animate:YES blockRetrun:^(id a) {
                _isShowAlert = NO;
            } cancelReturn:^(id a) {
                _isShowAlert = NO;
            }];
        });
    }
}

- (void)changeTheIsShowAlert {
    _isShowAlert = NO;
}

- (void)autoLoginWithPhone:(NSString *)phoneNum andPassword:(NSString *)password{
    [LoginManager sharedManager].loginState = NO;
    
    NSString *osName = [[UIDevice currentDevice] systemName];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    LoginParamsModel *model = [[LoginParamsModel alloc] init];
    model.phoneNum = phoneNum;
    model.password = password;
    model.deviceName = [[UIDevice currentDevice] name];
    model.osName = osName;
    model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
    model.imeiNum = [OpenUDID value];
    model.latitude = [LoginManager sharedManager].currLatitude;
    model.longitude = [LoginManager sharedManager].currLongitude;
    model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
    
    [LoginService publicLogin:model needLoading:NO success:^(UserSessionModel *session) {
        if(session && ![session.sessionId isEqualToString:@""]){
            NSLog(@"###################自动登录了###################");
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
            if (dic) {
                NSString *openId = dic[@"openid"];
                NSString *unionId = dic[@"unionid"];
                NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
                
                [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
            }
            [LoginManager sharedManager].session = session;
            [LoginManager sharedManager].loginState = YES;
            _isShowAlert = NO;
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].session.headImage]
                                                            options:SDWebImageLowPriority
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                              if (image != nil) {
                                                                  [LoginManager sharedManager].session.imageHead = image;
                                                              }
                                                          }];
            
            [[NSUserDefaults standardUserDefaults] setObject:session.sessionId forKey:@"GolfSessionID"];
            [[NSUserDefaults standardUserDefaults] setObject:@(session.memberId) forKey:@"GolfUserID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //lyf 加
            if (_tabBarController.isClickedMiddleButton) {
                [_tabBarController tabBarDidTappedMiddleButton];
            } else {
                [[LoginManager sharedManager] loginWithDelegate:(id<YGLoginViewCtrlDelegate>)self.currentController controller:self.currentController animate:YES];
            }
        }else{
            _isShowAlert = NO;
        }
    } failure:^(id error) {
        _isShowAlert = NO;
    }];
    
}


- (void)alert:(NSString *)title message:(NSString *)message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
    alertView.tag = 10001;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [alertView show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [self handlePushNotification:self.notificationUseInfo];
        }
    }else if (alertView.tag == 10001){
        if (buttonIndex == 0) {
            _isShowAlert = NO;
        }
    }else if(alertView.tag == 10002){
        if (buttonIndex == 0) {
            _isShowAlert = NO;
            BaseNavController *controller = [[GolfAppDelegate shareAppDelegate].naviController.viewControllers lastObject];
            [[LoginManager sharedManager] loginWithDelegate:self controller:controller animate:YES];
        }
    }
}

- (void)showInstruction:(NSString*)url title:(NSString*)title WithController:(UIViewController*)controller{
    YGIntroViewCtrl *instruction = [[YGIntroViewCtrl alloc] init];
    instruction.title = title;
    instruction.isPressentModelView = YES;
    [instruction loadWebViewWithUrl:url];
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:instruction];
    [controller presentViewController:nav animated:YES completion:nil];
}

#pragma mark - default Application Methods

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNewsCount" object:nil];
    NSLog(@"\n ===> 程序重新激活 !");
    if (firstBecomeActive) {
        [self _loginIMEngine];
    }else{
        firstBecomeActive = YES;
    }
    [self refreshBadgeValue];//刷新约球红点
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"\n ===> 程序进入后台 !");
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.msgCount;
    self.isFirstEnterPush = YES;
}
 
-(void)applicationWillTerminate:(UIApplication *)application{//APP从杀死时调用
    
    self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.msgCount;
}

#pragma mark - 演练
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
            [[IMCore shareInstance] closeIm];
        }else{
            [self _loginIMEngine];
            
            //需要登录成功状态才可以提交记分卡数据
            if ([LoginManager sharedManager].loginState) {
                [self submitCardInfo];
            }
            
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (BOOL)notFirstLogin {//lyf 加 app运行没登录
    if (![LoginManager sharedManager].loginState) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if ((([userDefault objectForKey:KGolfSessionPhone] == nil || [userDefault objectForKey:KGolfUserPassword] == nil) && groupData.length <= 0) || ![GolfAppDelegate shareAppDelegate].autoLogIn) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)networkReachability{
    if (self.networkReachabilityStatus <= 0) {
        [SVProgressHUD showInfoWithStatus:@"当前网络不可用"];
        return NO;
    }
    return YES;
}
@end

