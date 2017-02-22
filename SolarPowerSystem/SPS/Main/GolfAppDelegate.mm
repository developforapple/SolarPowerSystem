//
//  GolfAppDelegate.m
//  Golf
//
//  Created by Dejohn Dong on 11-11-14.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import "GolfAppDelegate.h"
#import "ClubListViewController.h"
#import "PayOnlineViewController.h"
#import "YGWebBrowser.h"
#import "BaiduMobStat.h"
#import "YGIntroViewCtrl.h"
#import "YG_MallCommodityViewCtrl.h"
#import "OpenUDID.h"
#import "YGMallOrderViewCtrl.h"
#import "YGMallCommodityListContainer.h"
#import "RegexKitLite.h"
#import "ClubOrderViewController.h"
#import "HttpErroCodeModel.h"
#import "TeachHomeTableViewController.h"
#import "PublicCourseDetailController.h"
#import "PublicCourseHomeController.h"
#import "ChooseCoachListController.h"
#import "CoachTableViewController.h"
#import "CourseDetailController.h"
#import "CourseSchoolTableViewController.h"
#import "CCAlertView.h"
#import "YGProfileViewCtrl.h"
#import "Player.h"
#import "YGMallViewCtrl.h"
#import "YGPackageDetailViewCtrl.h"
#import "TeachingOrderListViewController.h"
#import "TrendsViewController.h"
#import "TrendsDetailsViewController.h"
#import "TopicDetailsViewController.h"
#import "TeachingOrderDetailViewController.h"
#import <BeaconAPI_Base/BeaconBaseInterface.h>
#import "ClubMainViewController.h"
#import "TrendsMessageViewController.h"
#import "FriendsMainViewController.h"
#import "CoachDetailsViewController.h"
#import "TopicHelp.h"
#import <AlipaySDK/AlipaySDK.h>
#import "YGMallHotSellListViewCtrl.h"
#import "TogetherViewController.h"
#import "IMConnect.h"
#import "ReadyToSendViewController.h"
#import "YQDetailViewController.h"
#import "IMCore.h"
#import "YQNewMessagePopView.h"
#import "IMNotificationDefine.h"
#import "InvitationDetailViewController.h"
#import "GetYQSound.h"
#import "IMMessages.h"
#import "IMSession.h"
#import "IMUserInfo.h"
#import "JSQSystemSoundPlayer.h"
#import "JSQSystemSoundPlayer+JSQMessages.h"
#import "WKDChatViewController.h"
#import "YGArticleDetailViewCtrl.h"         //图文视频详情
#import "YGArticleImagesDetailViewCtrl.h"   //多图详情
#import "YGArticleAlbumDetailViewCtrl.h"    //专题详情
#import "IMCardInfo.h"
#import "YGCapabilityHelper.h"
#import "NewFriendsViewController.h"
#import "GuideViewController.h"//第一次启动引导页
#import "GolfAppDelegate+SetupNormalAppearance.h"
#import "IMLog.h"
#import "YGCouponListViewCtrl.h"
#import "YGRemoteNotificationHelper.h"
#import "YGPayThirdPlatformProcessor.h"
#import "FootprintMainViewController.h"
#import "TrendsMainViewController.h"
#import "YGMineViewCtrl.h"
#import "YGLoginViewCtrl.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "IndexViewController.h"
#import "SpecialOfferListViewController.h"

#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>
#import <MagicalRecord/MagicalRecord.h>
#import <PINCache/PINCache.h>

#import "YGTeachingArchiveCourseDetailViewCtrl.h" // 课程详情
#import "YGTeachingArchiveLessonDetailViewCtrl.h" // 课时详情

#import "YGPackageOrderDetailViewCtr.h"
#import "YGBaseNavigationController.h"


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
    
//    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose]; //test
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kGolfPlus];
    
    self.tabBarController = [YGTabBarController defaultController];
    [self passedValue];
    
    float currVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ScanTheGuidPicture"] floatValue] < currVersion) {
        self.isFirstEnterApp = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@(currVersion) forKey:@"ScanTheGuidPicture"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WillFriendsRemind"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        /**
         引导页
         */
        GuideViewController *guideVC = [[GuideViewController alloc] init];
        self.window.rootViewController = guideVC;
    }else{
        [self.window setRootViewController:self.tabBarController];
        [self startRemoteNotification];
    }
   
    [self.window makeKeyAndVisible];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self setInitPramas];
    
    [_home locationToTeetimeMainVc:self.yungaoUrlStr];
    
    //监测HTTP服务器错误及异常
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(solveHttpError:) name:@"checkHttpError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessed:) name:@"LOGIN_SUCCESSED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage:) name:IMMessageReceivedNotification object:nil];
    /**
     新人专享
     */
    [self addNewPeopleEnjoy];
    
    self.isFirstEnterPush = YES;
    self.remoteNotificationKeyDic = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (self.remoteNotificationKeyDic) {
//        [self handlePushNotification:self.remoteNotificationKeyDic];
//    }
    self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
    
    return YES;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkHttpError" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMMessageReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LOGIN_SUCCESSED" object:nil];
    _locationManage = nil;
}

- (void)passedValue {
    nav_1 = _tabBarController.nav_1;
    nav_2 = _tabBarController.nav_2;
//    nav_3 = _tabBarController.nav_3;
    nav_4 = _tabBarController.nav_4;
    nav_5 = _tabBarController.nav_5;
    self.home = nav_1.viewControllers.firstObject;
    self.trendsMainViewController = nav_2.viewControllers.firstObject;
    self.accountCenter = nav_5.viewControllers.firstObject;
    _currentController = _home;
}

-(void)refreshBadgeValue{
    if (!self.remoteNotificationKeyDic) {//点击APP图标进入程序
        [[API shareInstance] unReadPushMsgWithType:0 success:^(AckBean *data) {
            int unReadYQPushMsg = [[[data.success extraMap] valueForKey:@"unReadPushMsg"] intValue];
            if (unReadYQPushMsg == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHaveNewYQMsg:NO];
                });
            }else if (unReadYQPushMsg == 1){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHaveNewYQMsg:YES];
                });
            }
        } failure:^(Error *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isHaveNewYQMsg:NO];
            });
        }];
    }
}

-(UIView *)badgeYQView{
    if (_badgeYQView == nil) {
        _badgeYQView = [[UIView alloc] initWithFrame:CGRectMake(Device_Width - Device_Width / 5 * 0.281  - Device_Width / 5 * 2, 4, 9, 9)];
        _badgeYQView.backgroundColor = [UIColor redColor];
        _badgeYQView.layer.cornerRadius = 4.5;
        _badgeYQView.layer.masksToBounds = YES;
        [self.tabBarController.tabBar addSubview:_badgeYQView];
    }
    return _badgeYQView;
}

-(void)isHaveNewYQMsg:(BOOL) hasNewYQMsg{
    self.badgeYQView.hidden = ! hasNewYQMsg;
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
    [self loginIMEngine:ns];
    [self refreshBadgeValue];
    [self deviceInfoUpload];
    
    NSString *value = [[PINCache sharedCache] objectForKey:[NSString stringWithFormat:@"reloadSessions:%d",[LoginManager sharedManager].session.memberId]];
    if (value.length == 0 || value == nil) {
        [IMSession MR_truncateAll];
        [IMMessages MR_truncateAll];
    }
    [[IMLog shareInstance] createFile];
}

- (void)loginIMEngine:(NSNotification *)obj{
    
    NSDictionary *signInfo = obj.object;
    
    if ([signInfo[IMUsername] length] > 0) {
        [[PINCache sharedCache] setObject:signInfo[IMUsername] forKey:IMUsername];
    }
    if ([signInfo[IMPassword] length] > 0) {
        [[PINCache sharedCache] setObject:signInfo[IMPassword] forKey:IMPassword];
    }
    [self _loginIMEngine];
}

- (void)deviceInfoUpload{
    // 上传设备唯一标识 lq  加 登陆成功
    [[API shareInstance] deviceUpSuccess:^(id data) { } failure:^(NSException *error) {  }];
    
    
    NSString *globalSavedToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
    
    if (globalSavedToken && globalSavedToken.length > 0 && [LoginManager sharedManager].loginState == YES) {
        
        UIDevice *device = [[UIDevice alloc] init];
        NSString *model = device.model;      //获取设备的类别
        NSString *systemName = device.systemName;   //获取当前运行的系统
        NSString *systemVersion = device.systemVersion;//获取当前系统的版本
        
        [ServerService deviceInfoWithSessionId:[LoginManager sharedManager].getSessionId
                                   deviceToken:globalSavedToken
                                     longitude:[LoginManager sharedManager].currLongitude
                                      latitude:[LoginManager sharedManager].currLatitude
                                    deviceName:model
                                        osName:systemName
                                     osVersion:[systemVersion stringByAppendingFormat:@",%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] success:^(id data) {
                                         NSLog(@"deviceInfoWithSessionId:%@  globalSavedToken:%@",data,globalSavedToken);

                                     } failure:^(id error) {
                                         NSLog(@"deviceInfoWithSessionId 调用失败");
                                     }];
    }
    
}

-(void)_loginIMEngine{
    if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
        [[LoginManager sharedManager] autoLoginInBackground:self success:^(BOOL flag) {
            if (flag) {
                [self autoLoginIM];
            }
        } failure:^(HttpErroCodeModel *error) {
            NSLog(@"%@",error);
            if (error && error.code == 100002) { // 手机号未注册
                [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                    [self autoLoginIM];
                }];
            }
        }];
    }else{
        [self autoLoginIM];
    }
}

- (void)autoLoginIM{
    [IMCore shareInstance].currentIMLoginMemberId = [LoginManager sharedManager].session.memberId;
    if (![[IMCore shareInstance] isLogin]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[IMCore shareInstance] autoLoginWithCompletion:^(id data) {
                NSLog(@"有账号密码--%@",[data boolValue] ? @"登录IM成功了":@"IM登录失败");
            }];
        });
        
    }else{
        NSLog(@"没有登录成功IM");
    }
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
        
        if (Equal(dataType, @"topic")){
            /* subtype 定义
             1. 话题详情
             2. 话题列表
             3. 话题消息
             */
            if (![subType isEqualToString:@"5"]) {
                int count = [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMsgCount;
                count ++;
                [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMsgCount = count;
                self.trendsMainViewController.badgeNumber=count;
            }
            self.memberID = userInfo[@"data_extra"];
        }else if (Equal(dataType, @"footprint")){
            int count = [GolfAppDelegate shareAppDelegate].systemParamInfo.footprintMsgCount;
            count ++;
            [GolfAppDelegate shareAppDelegate].systemParamInfo.footprintMsgCount = count;
            _myfootPrint.badgeNum = count;
        }else if (Equal(dataType, @"account")){
            int count = [GolfAppDelegate shareAppDelegate].systemParamInfo.accountMsgCount;
            count ++;
            _accountCenter.badgeImage.hidden = YES;
            [GolfAppDelegate shareAppDelegate].systemParamInfo.accountMsgCount = count;
            _accountCenter.badgeNum = count + [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEW_FOLLOWED_COUNT"] intValue] + [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];
        }else if (Equal(dataType, @"yaoball")){//收到约球推送
            if (!_tabBarController.nav_3) {
                [self isHaveNewYQMsg:YES];
            }else{
                [self isHaveNewYQMsg:NO];
            }
        }else if (Equal(dataType, @"golfim")){
            self.msgCount = self.msgCount + 1;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = self.msgCount;
        });
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {//app在后台不执行下面代码
            return;
        }
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            
            if (!self.currentController) {
                self.currentController = self.naviController.viewControllers.lastObject;
            }
            
            self.notificationUseInfo = userInfo;
            if ([userInfo valueForKeyPath:@"msgId"]) { //如果有msgId表示是聊天的推送消息，自动忽略掉。
                return;
            }
            
            if (Equal(dataType, @"yaoball")) {//收到约球邀请
                NSInteger subType = [[userInfo objectForKey:@"sub_type"] integerValue];
                NSString *joinPeople = [userInfo objectForKey:@"data_extra"];
                NSArray *joinArr = [joinPeople componentsSeparatedByString:@";"];
                NSArray *peopleArr;
                NSMutableArray *totalArr = [NSMutableArray array];
                for (NSString *people in joinArr) {
                    peopleArr = [people componentsSeparatedByString:@"|"];
                    [totalArr addObject:peopleArr];
                }
                NSString *memberID;
                for (NSArray *arr in totalArr) {
                    if (memberID == nil) {
                        memberID = [NSString stringWithFormat:@"%@",arr.lastObject];
                    }else{
                        memberID = [NSString stringWithFormat:@"%@,%@",memberID,arr.lastObject];
                        memberID = [memberID substringFromIndex:1];
                    }
                }
                
                if(_tabBarController.nav_3){
                    if (subType == 1) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyReceiveList" object:userInfo];
                    }else if (subType == 2){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshOngoingYQList" object:nil];
                    }
                    [[GetYQSound shareGetYQSound] systemShake];//震动
                    [[API shareInstance] unReadPushMsgWithType:1 success:nil failure:nil];
                    return;
                }
                
                [YQNewMessagePopView showHeaderImages:totalArr firstMember:memberID subType:subType onClick:^{
                    if (subType == 1) {
                        InvitationDetailViewController *vc = [InvitationDetailViewController instanceFromStoryboard];
                        vc.yaoId = (int)dataId;
                        vc.isFromFisrtView = YES;
                        [self.currentController pushViewController:vc hide:YES];
                        
                        [[API shareInstance] unReadPushMsgWithType:1 success:nil failure:nil];
                        self.badgeYQView.hidden = YES;
                        
                    }else if (subType == 2){
                        [self.tabBarController tabBarDidTappedMiddleButton];
                    }
                }];
                return;
            }
            if ([dataType isEqualToString:@"golfim"]) {
                [self handlePushNotification:userInfo];
                return;
            }
            __weak typeof(self) weakSelf = self;
            
            CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"推送消息" message:msg];
            [alert addButtonWithTitle:@"忽略" block:^(){
                [weakSelf handlePushNotificationCancel:weakSelf.notificationUseInfo];
            }];
            [alert addButtonWithTitle:@"查看" block:^(){
                [weakSelf handlePushNotification:weakSelf.notificationUseInfo];
                self.isClickAlerView = YES;
            }];
            [alert show];
            
        }
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
            if (self.isFirstEnterPush) {
                [self handlePushNotification:userInfo];
                self.isFirstEnterPush = NO;
            }
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

- (void)toInvitationDetailViewControllerByYaoId:(int)yaoId{
    InvitationDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"TogetherLYF" bundle:nil]instantiateViewControllerWithIdentifier:@"InvitationDetailViewController"];
    viewController.yaoId = yaoId;
    viewController.isFromFisrtView = YES;
    [self.currentController.navigationController pushViewController:viewController animated:YES];
    [[API shareInstance] unReadPushMsgWithType:1 success:nil failure:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.badgeYQView.hidden = YES;
    });
}

- (void)handlePushControllerWithData:(NSDictionary *)data{
    if (data) {
        if ([data valueForKeyPath:@"msgId"]) { //表示是聊天推送消息，进入私信列表
            if (nav_4) {
                [self.tabBarController setSelectedViewController:nav_4];
            }
            return;
        }
        if (!self.currentController) {
            self.currentController = self.naviController.viewControllers.lastObject;
        }
        
        NSString *dataType = [data objectForKey:@"data_type"];
        NSInteger subType = [[data objectForKey:@"sub_type"] integerValue];
        int dataId = 0;
        if ([data objectForKey:@"data_id"]) {
            dataId = [[data objectForKey:@"data_id"] intValue];
        }
        NSString *dataExtra = nil;
        if ([data objectForKey:@"data_extra"]) {
            dataExtra = [data objectForKey:@"data_extra"];
        }
        
        ActivityModel *model = [data objectForKey:@"data_model"];
        
        if (Equal(dataType, @"") && model) {
            YGWebBrowser *activityMain = [YGWebBrowser instanceFromStoryboard];
//            ActivityMainViewController *activityMain = [[ActivityMainViewController alloc] initWithNibName:@"ActivityMainViewController" bundle:nil];
            activityMain.title = @"活动详情";
            activityMain.activityModel = model;
            activityMain.activityId = model.activityId;
            activityMain.hidesBottomBarWhenPushed = YES;
            [self.currentController pushViewController:activityMain title:@"活动详情" hide:YES];
        }else if (Equal(dataType, @"order")) {
            NSInteger orderState = [dataExtra integerValue];
            if(orderState == 6) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNewsCount" object:nil];
            }
            if (subType == 1) { // 1： 订场订单
                ClubOrderViewController *clubOrder = [[ClubOrderViewController alloc] init];
                clubOrder.title = [NSString stringWithFormat:@"订单%d",dataId];
                clubOrder.orderId = dataId;
                clubOrder.hidesBottomBarWhenPushed = YES;
                [[GolfAppDelegate shareAppDelegate].naviController pushViewController:clubOrder animated:YES];
            }else if (subType == 2){ // 2： 商品订单
                
                YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
                vc.orderId = dataId;
                [[GolfAppDelegate shareAppDelegate].naviController pushViewController:vc animated:YES];
                
            }else if (subType == 3){ // 3.教学订单
                [self.currentController pushWithStoryboard:@"Teach" title:[NSString stringWithFormat:@"订单%d",dataId] identifier:@"TeachingOrderDetailViewController" completion:^(BaseNavController *controller) {
                    TeachingOrderDetailViewController *vc = (TeachingOrderDetailViewController *)controller;
                    vc.orderId = dataId;
                    vc.blockReturn = ^(id data){
                        [self.currentController.navigationController popViewControllerAnimated:YES];
                    };
                }];
            }else if (subType == 4){
                //旅行套餐
                YGPackageOrderDetailViewCtr *vc = [YGPackageOrderDetailViewCtr instanceFromStoryboard];
                vc.orderId = dataId;
                [self.currentController.navigationController pushViewController:vc animated:YES];
            }
        }else if (Equal(dataType, @"teetime")){
            NSDate *tomorrow = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
            NSString *date = [Utilities stringwithDate:tomorrow];
            NSString *time = @"07:30";
            if (dataExtra) {
                if ([dataExtra isMatchedByRegex:KDateFormatterYmd]) {
                    date = dataExtra;
                }else if ([dataExtra isMatchedByRegex:KDateFormatterYmdhm]){
                    NSArray *array = [dataExtra componentsSeparatedByString:@" "];
                    if (array && array.count==2) {
                        date = [[dataExtra componentsSeparatedByString:@" "] objectAtIndex:0];
                        time = [[dataExtra componentsSeparatedByString:@" "] objectAtIndex:1];
                    }
                }else if ([dataExtra isMatchedByRegex:KDateFormatterYmdhms]){
                    NSArray *array = [dataExtra componentsSeparatedByString:@" "];
                    if (array && array.count==2) {
                        date = [[dataExtra componentsSeparatedByString:@" "] objectAtIndex:0];
                        time = [[dataExtra componentsSeparatedByString:@" "] objectAtIndex:1];
                        time = [time substringToIndex:5];
                    }
                }
            }
            ConditionModel *nextCondition = [[ConditionModel alloc] init];
            nextCondition.clubId = dataId;
            nextCondition.date = date;
            nextCondition.time = time;
            if (subType == 1) {
                [self.currentController pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                    ClubMainViewController *vc = (ClubMainViewController*)controller;
                    vc.cm = nextCondition;
                    vc.agentId = -1;
                }];
            }else if (subType == 2){
                
                YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
                vc.packageId = dataId;
                [[GolfAppDelegate shareAppDelegate].naviController pushViewController:vc animated:YES];
            }else if (subType == 3||subType == 4){
                NSString *title = nil;
                NSString *theDate = [Utilities formatDate:date time:time];
                if (subType == 3) {
                    nextCondition.cityId = 0;
                    nextCondition.provinceId = dataId;
                    nextCondition.cityName = dataExtra;
                    SearchProvinceModel *provinceModel = [SearchProvinceModel getProvinceModelWithProvinceId:dataId];
                    if (provinceModel.provinceName.length>0) {
                        title = [NSString stringWithFormat:@"%@ %@",provinceModel.provinceName,theDate];
                    }else{
                        title = [NSString stringWithFormat:@"%@",theDate];
                    }
                }else{
                    nextCondition.cityId = dataId;
                    nextCondition.provinceId = 0;
                    nextCondition.cityName = dataExtra;
                    SearchCityModel *cityModel = [SearchCityModel getCityModelWithCityId:dataId];
                    if (cityModel.cityName.length>0) {
                        title = [NSString stringWithFormat:@"%@ %@",cityModel.cityName,theDate];
                    }else{
                        title = [NSString stringWithFormat:@"%@",theDate];
                    }
                }
                [self.currentController pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
                    ClubListViewController *vc = (ClubListViewController*)controller;
                    vc.cm = nextCondition;
                }];
            }else if (subType == 5){
                [self.currentController pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubHomeController" completion:^(BaseNavController *controller) {}];
            }else if (subType == 6){
                [self.currentController pushWithStoryboard:@"BookTeetime" title:@"抢购详情" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                    ClubMainViewController *vc = (ClubMainViewController*)controller;
                    vc.rush = YES;
                    vc.spreeId = dataId;
                }];
            }
        }else if (Equal(dataType, @"commodity")){
            if (subType == 1) {
                YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//                vc.commodityId = dataId;
//                vc.auctionId = [dataExtra intValue];
                vc.cid = dataId;
                [self.currentController.navigationController pushViewController:vc animated:YES];
            }else if (subType == 2){
                [self pushToCommodityWithType:subType dataId:dataId extro:dataExtra controller:self.currentController];
            }else if (subType == 3){
                [self pushToCommodityWithType:3 dataId:dataId extro:dataExtra controller:self.currentController];
            }else if (subType == 4){
                YGMallViewCtrl *vc = [YGMallViewCtrl instanceFromStoryboard];
                [self.currentController.navigationController pushViewController:vc animated:YES];
            }else if (subType == 5){
                NSString *title = nil;
                if (dataExtra.length>0) {
                    title = dataExtra;
                }else{
                    title = @"主题列表";
                }
                YGMallHotSellListViewCtrl *vc = [YGMallHotSellListViewCtrl instanceFromStoryboard];
                vc.title = title;
                vc.themeId = dataId;
                [self.currentController.navigationController pushViewController:vc animated:YES];
            }
        }else if (Equal(dataType, @"activity")){
            if (subType == 1) {
                YGWebBrowser *activityMain = [YGWebBrowser instanceFromStoryboard];
//                ActivityMainViewController *activityMain = [[ActivityMainViewController alloc] initWithNibName:@"ActivityMainViewController" bundle:nil];
                activityMain.title = @"活动详情";
                activityMain.activityId = dataId;
                activityMain.hidesBottomBarWhenPushed = YES;
                [[GolfAppDelegate shareAppDelegate].naviController pushViewController:activityMain animated:YES];
            }
        }else if (Equal(dataType, @"account")){
            
            void (^skip)(void) = ^{
                [self.tabBarController setSelectedViewController:nav_5];
                [nav_5 popToRootViewControllerAnimated:NO];
                
                if (subType == 2) {
                    // 我的现金券
                    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.couponTotal) forKey:[NSString stringWithFormat:@"couponTotal-single-%@", [LoginManager sharedManager].session.mobilePhone]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    YGCouponListViewCtrl *vc = [YGCouponListViewCtrl instanceFromStoryboard];
                    [nav_5 pushViewController:vc animated:YES];
                }
            };
            
            if (![LoginManager sharedManager].loginState) {
                [[LoginManager sharedManager] loginWithDelegate:(id<YGLoginViewCtrlDelegate>)self.currentController controller:self.currentController animate:YES blockRetrun:^(id obj) {
                    skip();
                }];
            }else{
                skip();
            }
        }else if (Equal(dataType, @"member")){
            if (![LoginManager sharedManager].loginState) {
                if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
                    [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                        if (flag) {
                            [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"" target:self.currentController];
                        }
                    } failure:^(HttpErroCodeModel *error) {
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                            [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"" target:self.currentController];
                        }];
                    }];
                }else{
                    [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                        [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"" target:self.currentController];
                    }];
                }
            }else{
                [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"" target:self.currentController];
            }
        } else if (Equal(dataType, @"topic")){
            if (subType == 1) { // 动态详情
                [self.currentController pushWithStoryboard:@"Trends" title:@"动态详情" identifier:@"TrendsDetailsViewController" completion:^(BaseNavController *controller) {
                    TrendsDetailsViewController *vc = (TrendsDetailsViewController*)controller;
                    vc.topicId = dataId;
                }];
            }else if (subType == 2){ // 进话题列表
                self.tabBarController.selectedIndex = 1;
                [[GolfAppDelegate shareAppDelegate].naviController popToRootViewControllerAnimated:NO];
                _trendsMainViewController.type = dataId;
            }else if (subType == 3){ // 话题消息
                if ([LoginManager sharedManager].loginState) { 
                    [self.currentController pushWithStoryboard:@"Trends" title:@"消息通知" identifier:@"TrendsMessageViewController" completion:^(BaseNavController *controller) {
                        TrendsMessageViewController *vc = (TrendsMessageViewController *)controller;
                        vc.msgType = dataId;
                    }];
                }else{
                    self.tabBarController.selectedIndex = 1;
                }
            }else if (subType == 4){
                [self.currentController pushWithStoryboard:@"Trends" title:@"话题详情" identifier:@"TopicDetailsViewController" completion:^(BaseNavController *controller) {
                    TopicDetailsViewController *vc = (TopicDetailsViewController*)controller;
                    vc.topicType = 1;
                    vc.tagId = dataId;
                    vc.tagName = dataExtra;
                }];
            }else if (subType == 5){
                self.tabBarController.selectedIndex = 1;
                [[GolfAppDelegate shareAppDelegate].naviController popToRootViewControllerAnimated:NO];
                _trendsMainViewController.type = dataId;
            }
        }else if (Equal(dataType, @"footprint")){//lyf 临时屏蔽 此处需要修改
            if (subType == 1) {
                if (![LoginManager sharedManager].loginState) {
                    if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
                        [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                            if (flag) {
                                [self.currentController pushWithStoryboard:@"Footprint" title:@"足迹" identifier:@"FootprintMainViewController" completion:nil];
                            }
                        } failure:^(HttpErroCodeModel *error) {
                            [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                                [self.currentController pushWithStoryboard:@"Footprint" title:@"足迹" identifier:@"FootprintMainViewController" completion:nil];//加
                            }];
                        }];
//                        [[LoginManager sharedManager] autoLoginInBackground:nil completion:^(BOOL boolen) {
//                            [self.currentController pushWithStoryboard:@"Footprint" title:@"足迹" identifier:@"FootprintMainViewController" completion:nil];
//                        }];
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                            [self.currentController pushWithStoryboard:@"Footprint" title:@"足迹" identifier:@"FootprintMainViewController" completion:nil];//加
                        }];
                    }
                }else{
                    [self.currentController pushWithStoryboard:@"Footprint" title:@"足迹" identifier:@"FootprintMainViewController" completion:nil];//lyf 加
                }
            }
        }else if (Equal(dataType, @"teaching")){
            if (subType == 1) { // 教学首页
                [self.currentController pushWithStoryboard:@"Teach" title:@"" identifier:@"TeachHomeTableViewController"];
            }else if (subType == 2){ // 学院列表
                // 暂无
                [self.currentController pushWithStoryboard:@"Teach" title:@"学院列表" identifier:@"CourseSchoolTableViewController" completion:^(BaseNavController *controller) {
                    CourseSchoolTableViewController *academy = (CourseSchoolTableViewController*)controller;
                    academy.cityId = self.searchCityModel.cityId;
                    academy.hasSearchButton = YES;
                }];
            }else if (subType == 3){ // 公开课列表
                [self.currentController pushWithStoryboard:@"Jiaoxue" title:@"公开课" identifier:@"PublicCourseHomeController" completion:^(BaseNavController *controller) {
                    PublicCourseHomeController *course = (PublicCourseHomeController*)controller;
                    course.cityId = self.searchCityModel.cityId;
                }];
            }else if (subType == 4){ // 教练列表
                [self.currentController pushWithStoryboard:@"Teach" title:@"教练" identifier:@"CoachTableViewController" completion:^(BaseNavController * controller){
                    CoachTableViewController *vc = (CoachTableViewController *)controller;
                    vc.hasSearchButton = YES;
                    vc.useControls = YES;
                    vc.isSearchViewController = NO;
                }];
            }else if (subType == 5){ // 产品详情
                [self.currentController pushWithStoryboard:@"Jiaoxue" title:@"课程详情" identifier:@"CourseDetailController" completion:^(BaseNavController *controller) {
                    CourseDetailController *course = (CourseDetailController*)controller;
                    course.productId = dataId;
                }];
            }else if (subType == 6){ // 选择教练列表
                [self.currentController pushWithStoryboard:@"Jiaoxue" title:@"选择教练" identifier:@"ChooseCoachListController" completion:^(BaseNavController *controller) {
                    ChooseCoachListController *chooseCoachList = (ChooseCoachListController*)controller;
                    chooseCoachList.productId = dataId;
                    chooseCoachList.cityId = self.searchCityModel.cityId;
                }];
            }else if (subType == 7){ // 公开课详情
                [self.currentController pushWithStoryboard:@"Jiaoxue" title:@"公开课详情" identifier:@"PublicCourseDetailController" completion:^(BaseNavController *controller) {
                    PublicCourseDetailController *publicCourseDetail = (PublicCourseDetailController*)controller;
                    publicCourseDetail.publicClassId = dataId;
                }];
            }else if (subType == 8){// 教练详情
                [self.currentController pushWithStoryboard:@"Teach" title:@"教练主页" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
                    CoachDetailsViewController *coachDetails = (CoachDetailsViewController*)controller;
                    coachDetails.coachId = dataId;
                }];
                
            } else if (subType == 9 || subType == 11){ //课程详情（9 教练,11学员）
                
                LoginManager *login = [LoginManager sharedManager];
                if (!login.loginState) {
                    [login loginWithDelegate:nil controller:self.currentController animate:YES blockRetrun:^(id data) {
                        YGTeachingArchiveCourseDetailViewCtrl *vc = [YGTeachingArchiveCourseDetailViewCtrl instanceFromStoryboard];
                        vc.classId = dataId;
                        vc.isCoach = subType==9;
                        [self.currentController.navigationController pushViewController:vc animated:YES];
                    }];
                }else{
                    YGTeachingArchiveCourseDetailViewCtrl *vc = [YGTeachingArchiveCourseDetailViewCtrl instanceFromStoryboard];
                    vc.classId = dataId;
                    vc.isCoach = subType==9;
                    [self.currentController.navigationController pushViewController:vc animated:YES];
                }
                
            } else if (subType == 10 || subType == 12){// 课时详情（10教练,11学员）
                
                LoginManager *login = [LoginManager sharedManager];
                if (!login.loginState) {
                    [login loginWithDelegate:nil controller:self.currentController animate:YES blockRetrun:^(id data) {
                        YGTeachingArchiveLessonDetailViewCtrl *vc = [YGTeachingArchiveLessonDetailViewCtrl instanceFromStoryboard];
                        vc.periodId = dataId;
                        vc.isCoach = subType==10;
                        [self.currentController.navigationController pushViewController:vc animated:YES];
                    }];
                }else{
                    YGTeachingArchiveLessonDetailViewCtrl *vc = [YGTeachingArchiveLessonDetailViewCtrl instanceFromStoryboard];
                    vc.periodId = dataId;
                    vc.isCoach = subType==10;
                    [self.currentController.navigationController pushViewController:vc animated:YES];
                }
            }

        }else if (Equal(dataType, @"common")){
            if (subType == 1) { // 打开个人主页
                if (![LoginManager sharedManager].loginState) {
                    if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
                        [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                            if (flag) {
                                [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"主页" target:self.currentController];
                            }
                        } failure:^(HttpErroCodeModel *error) {
                            [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                                [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"主页" target:self.currentController];
                            }];
                        }];
//                        [[LoginManager sharedManager] autoLoginInBackground:nil completion:^(BOOL boolen) {
//                            [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"主页" target:self.currentController];
//                        }];
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                            [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"主页" target:self.currentController];
                        }];
                    }
                }else{
                    [self.currentController toPersonalHomeControllerByMemberId:dataId displayName:@"主页" target:self.currentController];
                }
            }else if (subType == 2){ // 播放当前视频
                [Player playWithUrl:dataExtra rt:CGRectMake(0, 0, Device_Width, 160) supportSlowed:YES supportCircle:NO vc:self.currentController completion:nil];
            }
        } else if (Equal(dataType, @"friend")) {
            if (subType == 1) {// 朋友加关注
                if (![LoginManager sharedManager].loginState) {
                    if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
                        [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                            if (flag) {
                                [self.currentController pushWithStoryboard:@"Friends" title:@"新的朋友" identifier:@"NewFriendsViewController" completion:^(BaseNavController *controller) {
                                }];
                            }
                        } failure:^(HttpErroCodeModel *error) {
                            [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                                [self.currentController pushWithStoryboard:@"Friends" title:@"新的朋友" identifier:@"NewFriendsViewController" completion:^(BaseNavController *controller) {
                                }];
                            }];
                        }];
//                        [[LoginManager sharedManager] autoLoginInBackground:nil completion:^(BOOL boolen) {
//                            if (boolen) {
//                                [self.currentController pushWithStoryboard:@"Friends" title:@"新的朋友" identifier:@"NewFriendsViewController" completion:^(BaseNavController *controller) {
//                                }];
//                            }
//                        }];
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                            [self.currentController pushWithStoryboard:@"Friends" title:@"新的朋友" identifier:@"NewFriendsViewController" completion:^(BaseNavController *controller) {
                            }];
                        }];
                    }
                }else{

                    NewFriendsViewController *friendVC = [NewFriendsViewController instanceFromStoryboard];
                    [self.naviController pushViewController:friendVC animated:YES];
                }
            }
        }else if (Equal(dataType, @"yaoball")) {
            if (subType == 1) {//收到的约球信息
                if (![LoginManager sharedManager].loginState) {
                    if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
                        [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                            if (flag) {
                                [self toInvitationDetailViewControllerByYaoId:[data[@"data_id"] intValue]];
                            }
                        } failure:^(HttpErroCodeModel *error) {
                            [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                                [self toInvitationDetailViewControllerByYaoId:[data[@"data_id"] intValue]];
                            }];
                        }];
//                        [[LoginManager sharedManager] autoLoginInBackground:nil completion:^(BOOL boolen) {
//                            if (boolen) {
//                                InvitationDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"TogetherLYF" bundle:nil]instantiateViewControllerWithIdentifier:@"InvitationDetailViewController"];
//                                viewController.yaoId = [data[@"data_id"] intValue];
//                                viewController.isFromFisrtView = YES;
//                                [self.currentController.navigationController pushViewController:viewController animated:YES];
//                                [[API shareInstance] unReadPushMsgWithType:1 success:nil failure:nil];
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    self.badgeYQView.hidden = YES;
//                                });
//                            }
//                            
//                        }];
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                            [self toInvitationDetailViewControllerByYaoId:[data[@"data_id"] intValue]];
                        }];
                    }
                }else{
                    [self toInvitationDetailViewControllerByYaoId:[data[@"data_id"] intValue]];
                }
                self.badgeYQView.hidden = YES;
            }else if (subType == 2) {//有人加入约球
                if(_tabBarController.nav_3){
                    [_tabBarController.nav_3 dismissViewControllerAnimated:NO completion:nil];
                }
                if (![LoginManager sharedManager].loginState) {
                    if ([[LoginManager sharedManager] canAutoLoginInBackground]) {
                        [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                            if (flag) {
                                [_tabBarController tabBarDidTappedMiddleButton];
                            }
                        } failure:^(HttpErroCodeModel *error) {
                            [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                                [_tabBarController tabBarDidTappedMiddleButton];
                            }];
                        }];
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:_currentController animate:YES blockRetrun:^(id data) {
                            [_tabBarController tabBarDidTappedMiddleButton];
                        }];
                    }
                }else{
                    [_tabBarController tabBarDidTappedMiddleButton];
                }
                
            } else {//banner跳
                [_tabBarController tabBarDidTappedMiddleButton];
            }

        }else if(Equal(dataType, @"golfim")){
            if (dataId > 0){// && toChatProcessing == NO) {
                toChatProcessing = YES;
                if (![LoginManager sharedManager].loginState) {
                    [[LoginManager sharedManager] autoLoginInBackground:self success:^(BOOL flag) {
                        if (flag) {
                            [self toMineViewController];
                        }
                    } failure:^(HttpErroCodeModel *error) {
                        toChatProcessing = NO;
                    }];
//                    [[LoginManager sharedManager] autoLoginInBackground:self completion:^(BOOL boolen) {
//                        if (boolen) {
//                            [self toMineViewController];
//                        }else{
//                            toChatProcessing = NO;
//                        }
//                    }];
                }else{
                    [self toMineViewController];
                }
            }
        }else if (Equal(dataType, @"yuedu")){
            // 6.6 悦读相关
            if (subType == 1) {
                //文章
                NSInteger extra = dataExtra.intValue;
                if (extra == 1) {
                    //多图
                    YGArticleImagesDetailViewCtrl *vc = [YGArticleImagesDetailViewCtrl instanceFromStoryboard];
                    vc.articleId = @(dataId);
                    [self.currentController pushViewController:vc hide:YES];
                }else{
                    //图文或者视频
                    YGArticleDetailViewCtrl *vc = [YGArticleDetailViewCtrl instanceFromStoryboard];
                    vc.articleId = @(dataId);
                    [self.currentController pushViewController:vc hide:YES];
                }
            }else if (subType == 2){
                //专题
                YGArticleAlbumDetailViewCtrl *vc = [YGArticleAlbumDetailViewCtrl instanceFromStoryboard];
                vc.albumId = @(dataId);
                [self.currentController pushViewController:vc hide:YES];
            }
        }
    }
}


- (void)toMineViewController{
    for (UIViewController *obj in self.currentController.navigationController.viewControllers) {
        if ([obj isKindOfClass:[WKDChatViewController class]]) {
            WKDChatViewController *vc = (WKDChatViewController *)obj;
            [vc backNoAnimated]; //关闭聊天对话框，取消监听
        }
    }
    
    if ([self.tabBarController.nav_5.topViewController isKindOfClass:[FriendsMainViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMSessionValueChangedNotification" object:nil];
        toChatProcessing = NO;
        return;
    }
    
    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedViewController:self.tabBarController.nav_5];
    [self.tabBarController.nav_5 popToRootViewControllerAnimated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        YGMineViewCtrl *vc = (YGMineViewCtrl *)self.tabBarController.nav_5.topViewController;
        if ([vc isKindOfClass:[YGMineViewCtrl class]]) {
            [vc toChatListViewController];
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IMSessionValueChangedNotification" object:nil];
        toChatProcessing = NO;
    });
    
}

- (void)handleLocalNotification:(UILocalNotification *)notification
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.tabBarController.selectedIndex = 0;
    NSDictionary *notificateDic = [notification userInfo];
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    
    NSString *callType = [[notificateDic objectForKey:@"call_type"] description];
    if (Equal(callType, @"commodity")) {
        int commodityId = [[notificateDic objectForKey:@"commodity_id"] intValue];
//        int auctionId = [[notificateDic objectForKey:@"auction_id"] intValue];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *array = [userDefault objectForKey:@"CommodityCallSetting"];
        NSMutableArray *mutArray = [NSMutableArray arrayWithArray:array];
        if (mutArray && mutArray.count > 0) {
            for (int i=0; i<mutArray.count; i++) {
                id Id = [mutArray objectAtIndex:i];
                if ([Id intValue] == commodityId) {
                    [mutArray removeObjectAtIndex:i];
                    [userDefault setObject:mutArray forKey:@"CommodityCallSetting"];
                    break;
                }
            }
        }
        
        NSArray *viewControllers = [[GolfAppDelegate shareAppDelegate].naviController viewControllers];
        YG_MallCommodityViewCtrl *commodityDetail = nil;
        for (BaseNavController *controller in viewControllers) {
            if ([controller isKindOfClass:[YG_MallCommodityViewCtrl class]]) {
                if ([viewControllers indexOfObject:controller] == viewControllers.count-1) {
                    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抢购信息"
                                                                        message:@"您关注的商品即将开抢了，赶紧去抢购吧！"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                }
                commodityDetail = (YG_MallCommodityViewCtrl *)controller;
                [[GolfAppDelegate shareAppDelegate].naviController popToViewController:commodityDetail animated:YES];
                break;
            }
        }
        if (!commodityDetail) {
            [SVProgressHUD showInfoWithStatus:@"您关注的商品即将开抢了"];
            
            YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//            vc.commodityId = commodityId;
//            vc.auctionId = auctionId;
            vc.cid = commodityId;
            [self.currentController.navigationController pushViewController:vc animated:YES];
        }
    }else if (Equal(callType, @"club")){
        int spreeId = [[notificateDic objectForKey:@"spree_id"] intValue];
        int clubId = [[notificateDic objectForKey:@"club_id"] intValue];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *array = [userDefault objectForKey:@"ClubCallSetting"];
        NSMutableArray *mutArray = [NSMutableArray arrayWithArray:array];
        if (mutArray && mutArray.count > 0) {
            for (int i=0; i<mutArray.count; i++) {
                id Id = [mutArray objectAtIndex:i];
                if ([Id intValue] == spreeId) {
                    [mutArray removeObjectAtIndex:i];
                    [userDefault setObject:mutArray forKey:@"ClubCallSetting"];
                    break;
                }
            }
        }
        
        NSArray *viewControllers = [[GolfAppDelegate shareAppDelegate].naviController viewControllers];
        ClubMainViewController *clubMainController = nil;
        for (BaseNavController *controller in viewControllers) {
            if ([controller isKindOfClass:[ClubMainViewController class]]) {
                clubMainController = (ClubMainViewController*)controller;
                if (clubMainController.rush == YES && clubMainController.csm.spreeId == spreeId) {
                    if ([viewControllers indexOfObject:controller] == viewControllers.count-1) {
                        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抢购信息"
                                                                            message:@"您关注的球场即将开抢了，赶紧去抢购吧！"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
                            [alert show];
                            return;
                        }
                    }
                    [[GolfAppDelegate shareAppDelegate].naviController popToViewController:clubMainController animated:YES];
                    break;
                }else{
                    clubMainController = nil;
                }
            }
        }
        if (!clubMainController) {
            [SVProgressHUD showInfoWithStatus:@"您关注的球场即将开抢了"];
            [self.currentController pushWithStoryboard:@"BookTeetime" title:@"抢购详情" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                ClubMainViewController *vc = (ClubMainViewController*)controller;
                vc.rush = YES;
                vc.spreeId = spreeId;
                vc.clubId = clubId;
                vc.agentId = -1;
            }];
        }
    }
}

- (void)pushToCommodityWithType:(NSInteger)aType dataId:(int)aDataId extro:(NSString*)extro controller:(__kindof UIViewController *)controller{
    // aType : 1. 商品详情 2.商品分类列表 3.品牌分类列表 4.商品抢购列表
    
    YGMallCommodityListContainer *vc = [[YGMallCommodityListContainer alloc] init];
    vc.title = @"精选商城";
    if (aDataId == -1) {
        vc.selectIndex = 1;
    }
    
    vc.data = @{@"sub_type":@(aType),@"data_id":@(aDataId),@"extro":extro.length > 0 ? extro : @""};
    [controller.navigationController pushViewController:vc animated:YES];
}

- (void)receiveNewMessage:(NSNotification *)notification{
    id obj = notification.object;
    
    if (!obj) {
        return;
    }
    
    if ([obj isKindOfClass:[TimMBean class]]) {
        [self saveMessagesWithTimMBean:obj];
    }else if([obj isKindOfClass:[TimMBeanList class]]){
        TimMBeanList *list = (TimMBeanList *)obj;
        for (TimMBean *obj in list.timMBeanList) {
            [self saveMessagesWithTimMBean:obj];
        }
    }
}

- (void)saveMessagesWithTimMBean:(TimMBean *)mb{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isRead = [[IMCore shareInstance] isChatingWithMemberId:[mb.fromTid.name intValue]] || [[IMCore shareInstance] isChatingWithMemberId:[mb.toTid.name intValue]];
        [[IMCore shareInstance] saveMessageWithTimMBean:mb isRead:isRead success:^(BOOL success,IMMessages *msg) {
            if (success == YES && [mb.extraMap[@"mute"] boolValue] == NO && ![@"remind" isEqualToString:mb.type] && ![@"reverse" isEqualToString:mb.type] && mb.offline == nil && isRead == NO) {
                [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            }
        }];
    });
}

#pragma mark - 网络请求回调
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array && array.count>0) {
        
        
        if (Equal(flag, @"activity_detail")) {
            ActivityModel *model = [array objectAtIndex:0];
            if (model.activityPage.length>0) {
                YGWebBrowser *activityMain = [YGWebBrowser instanceFromStoryboard];
//                ActivityMainViewController *activityMain = [[ActivityMainViewController alloc] initWithNibName:@"ActivityMainViewController" bundle:nil];
                activityMain.title = @"活动详情";
                activityMain.activityModel = model;
                [[GolfAppDelegate shareAppDelegate].naviController pushViewController:activityMain animated:YES];
            }else{
                ConditionModel *myCondition = [[ConditionModel alloc] init];
                myCondition.date = model.actionDate;
                myCondition.time = model.actionTime;
                if (model.activityAction == 1) {
                    myCondition.clubId = model.actionId;
                    
                    [self.currentController pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                        ClubMainViewController *vc = (ClubMainViewController*)controller;
                        vc.cm = myCondition;
                        vc.agentId = -1;
                    }];
                }else if (model.activityAction == 2){
                    
                    YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
                    vc.packageId = model.actionId;
                    [[GolfAppDelegate shareAppDelegate].naviController pushViewController:vc animated:YES];
                }else if (model.activityAction == 3 || model.activityAction == 4){
                    NSString *title = nil;
                    NSString *date = [Utilities formatDate:model.actionDate time:model.actionTime];
                    if (model.activityAction == 3) {
                        myCondition.cityId = 0;
                        myCondition.provinceId = model.actionId;
                        SearchProvinceModel *provinceModel = [SearchProvinceModel getProvinceModelWithProvinceId:model.actionId];
                        if (provinceModel.provinceName.length>0) {
                            title = [NSString stringWithFormat:@"%@ %@",provinceModel.provinceName,date];
                        }else{
                            title = [NSString stringWithFormat:@"%@",date];
                        }
                    }else{
                        myCondition.cityId = model.actionId;
                        myCondition.provinceId = 0;
                        SearchCityModel *cityModel = [SearchCityModel getCityModelWithCityId:model.actionId];
                        if (cityModel.cityName.length>0) {
                            title = [NSString stringWithFormat:@"%@ %@",cityModel.cityName,date];
                        }else{
                            title = [NSString stringWithFormat:@"%@",date];
                        }
                    }
                    [self.currentController pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
                        ClubListViewController *vc = (ClubListViewController*)controller;
                        vc.cm = myCondition;
                    }];
                }else if (model.activityAction == 5){
                    YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//                    vc.commodityId = model.actionId;
                    vc.cid = model.actionId;
                    [self.currentController.navigationController pushViewController:vc animated:YES];
                }else if (model.activityAction == 6){
                    [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:2 dataId:model.actionId extro:@"" controller:nil];
                }
            }
        }
    }
}


- (void)setInitPramas{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[array objectAtIndex:0] stringByAppendingPathComponent:@"CoachParasData"];
    if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    self.currentCity = @"深圳市";
    
    // 百度移动统计
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = NO;
    statTracker.channelId = @"Cydia";
    statTracker.sessionResumeInterval = 30;
    statTracker.logSendInterval = 1;
    [statTracker startWithAppId:@"266972f376"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _range = [userDefault objectForKey:@"GOLF_SETTING_RANGE"];
    [userDefault synchronize];
    if(_range == nil || [_range intValue] <= 0) {
        _range = @"150";
    }
    _autoLogIn = [userDefault integerForKey:@"GolfSessionAutoLogin"] != 1;
    
    _systemParamInfo = [[SystemParamInfo alloc] init];
    _systemParamInfo.accountMsgCount = [[userDefault objectForKey:@"account_msg_count"] intValue];
    _systemParamInfo.topicMsgCount = [[userDefault objectForKey:@"topic_msg_count"] intValue];
    _systemParamInfo.footprintMsgCount = [[userDefault objectForKey:@"topic_msg_count"] intValue];
    
    NSString *userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *version = [NSString stringWithFormat:@"%@,%@",osVersion,appVersion];
    NSString *customUserAgent = [userAgent stringByAppendingFormat:@" golfplus/%@", version];
    [userDefault registerDefaults:@{@"UserAgent":customUserAgent}];
    
    lastQueryTime = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {//若允许则现在定位，但不显示yaoball的hints，若第一次或者不允许，则等home页处理
        if (!_locationManage) {
            _locationManage = [[CLLocationManager alloc] init];
            _locationManage.desiredAccuracy=kCLLocationAccuracyBest;
            //定位频率,每隔多少米定位一次
            _locationManage.distanceFilter = 10;
            _locationManage.delegate = self;
        }
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            _isFirstLocationShowYaoBallHints = YES;
            [_locationManage startUpdatingLocation];
        }
    }
}

- (void)startUpdateLocation
{
    if([NSDate timeIntervalSinceReferenceDate] >= lastQueryTime + 300) {
        if (!_locationManage) {
            _locationManage = [[CLLocationManager alloc] init];
            _locationManage.desiredAccuracy=kCLLocationAccuracyBest;
            //定位频率,每隔多少米定位一次
            _locationManage.distanceFilter = 10;
            _locationManage.delegate = self;
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusNotDetermined) {
                [_locationManage requestWhenInUseAuthorization];
            }
            else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
                [_locationManage startUpdatingLocation];
            } else {
                CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"提示" message:@"云高需要获取你的位置，以提供更优质的服务。请开启你的定位服务。"];
                [alert addButtonWithTitle:@"知道了" block:nil];
                [alert show];
            }
        } else {
            [_locationManage startUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_2) {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManage startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *currentLocation = [locations lastObject];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             self.addressDictionary = placemark.addressDictionary;
             self.currentCity = placemark.addressDictionary[@"City"];
             self.locality = self.currentCity;
             
         }
     }];
    
    NSCoor coor = wgs2Gcj(currentLocation.coordinate);
    
    [LoginManager sharedManager].currLatitude = coor.latitude;
    [LoginManager sharedManager].currLongitude = coor.longitude;
    [LoginManager sharedManager].positionIsValid = YES;
    if ([self notFirstLogin] && !_isFirstLocationShowYaoBallHints) {//app运行没登录，就提示；登录了，在mainTabBarController中处理
        _isFirstLocationShowYaoBallHints = YES;
        lastQueryTime = [NSDate timeIntervalSinceReferenceDate];
        [self.tabBarController showYaoBallHints];
    }
    [_locationManage stopUpdatingLocation];

    [self deviceInfoUpload];
    self.isLocationSuccess = YES;
    
    //定位成功发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatgeLocations" object:nil];
}

+ (GolfAppDelegate *)shareAppDelegate{
    return (GolfAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)pushViewController:(BaseNavController*)viewController WithController:(UIViewController*)controller title:(NSString *)title hide:(BOOL)isHide{
    [viewController pushViewController:controller title:title hide:isHide];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (Equal([url scheme], @"yungaogolf")) {
        self.yungaoUrlStr = [url absoluteString];
        if (self.yungaoUrlStr && self.yungaoUrlStr.length > 0) {
            [self.home locationToTeetimeMainVc:self.yungaoUrlStr];
        }
        return YES;
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
    [IMLog log:@"程序进入后台"];
    [[IMCore shareInstance] logoutWithCompletion:^{
        NSLog(@"\n=====applicationDidEnterBackground===登出IM，注销！");
        [IMLog log:@"applicationDidEnterBackground===登出IM，注销！"];
    }];
    self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.msgCount;
    self.isFirstEnterPush = YES;
}
 
-(void)applicationWillTerminate:(UIApplication *)application{//APP从杀死时调用
    
    self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.msgCount;
    
    [MagicalRecord cleanUp];
    
}

#pragma mark - 演练
#pragma mark - 检测网络连接
- (void)reach
{
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络,不花钱
     */
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    
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

//网络恢复了，提交之前没有完成的计分卡数据到服务器
- (void)submitCardInfo{
    if ([IMCardInfo MR_hasAtLeastOneEntityInContext:[NSManagedObjectContext MR_defaultContext]]) {
        NSArray *arr = [IMCardInfo MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            IMCardInfo *ci = (IMCardInfo *)obj;
            [[API shareInstance] allscoreWithCardInfo:ci.cardInfo success:^(AckBean *data) {
                if (data.success.code == 200) {
                    [[NSManagedObjectContext MR_defaultContext] deleteObject:ci];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
                
            } failure:^(Error *error) {
                
            }];
        }];
    }
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

