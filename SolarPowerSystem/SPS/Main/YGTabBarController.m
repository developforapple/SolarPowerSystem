//
//  YGTabBarController.m
//  Golf
//
//  Created by lyf on 16/5/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGTabBarController.h"
#import "GolfTabBar.h"
#import "YGProfileViewCtrl.h"
#import "FriendsMainViewController.h"
#import "YQDetailViewController.h"
#import "ReadyToSendViewController.h"
#import "OngoingAppointmentViewController.h"
#import "TogetherViewController.h"
#import "TheTabBarButton.h"
#import "MiddleBarButtonHintsView.h"
#import "CCAlertView.h"
#import "Reachability.h"
#import "YQDetailViewController.h"
#import "GetYQSound.h"
#import "IMCore.h"
#import "DepositInfoModel.h"
#import "IMNotificationDefine.h"
#import "YGMineViewCtrl.h"
#import "IndexViewController.h"
#import "TrendsMainViewController.h"
#import "FootprintMainViewController.h"
#import <PINCache/PINCache.h>
#import "YGBaseNavigationController.h"

#define TOGETHER_TIPS_ALERTED @"TOGETHER_TIPS_ALERTED"
#define LOCATION_OBJECT_SELECTED @"LOCATION_OBJECT_SELECTED"


@interface YGTabBarController ()<UITabBarControllerDelegate,ServiceManagerDelegate>
@property (strong, nonatomic) GolfTabBar *theTabBar;
@property (strong, nonatomic) YaoBallCurrent *yaoBallCurrent;
@property (strong, nonatomic) MiddleBarButtonHintsView *hintsView;
@property (strong, nonatomic) Location *location;
@property (weak, nonatomic) TogetherViewController *togetherVc;
@property (nonatomic,assign) int msgCount;
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@property (strong, nonatomic) NSTimer *longTimer;

@end

@implementation YGTabBarController

+ (instancetype)defaultController
{
    static YGTabBarController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YGTabBarController alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hereLoginSuccess) name:@"LOGIN_SUCCESSED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshReadyToSend) name:@"refreshOngoingYQList" object:nil];
    
    self.theTabBar = [[GolfTabBar alloc] initWithFrame:self.tabBar.bounds];
    ygweakify(self);
    [self.theTabBar setMiddleBtnTappedAction:^{
        ygstrongify(self);
        [self tabBarDidTappedMiddleButton];
    }];
    [self setValue:_theTabBar forKey:@"tabBar"];

    _nav_1 = [YGBaseNavigationController instanceFromStoryboardWithIdentifier:@"NavIndexViewController"];
    _nav_1.tabBarItem.image = [UIImage imageNamed:@"tab_icon_1"];
    _nav_1.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_icon_11"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    _nav_2 = [YGBaseNavigationController instanceFromStoryboardWithIdentifier:@"NavTrendsMainViewController"];
    _nav_2.tabBarItem.image = [UIImage imageNamed:@"tab_icon_2"];
    _nav_2.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_icon_22"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    //足迹
    _nav_4 = [YGBaseNavigationController instanceFromStoryboardWithIdentifier:@"NavFootprintMainViewController"];
    _nav_4.tabBarItem.image = [UIImage imageNamed:@"tab_icon_4"];
    _nav_4.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_icon_44"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //我的
    _nav_5 = [YGBaseNavigationController instanceFromStoryboardWithIdentifier:@"YGMineNaviCtrl"];
    _nav_5.tabBarItem.image = [UIImage imageNamed:@"tab_icon_5"];
    _nav_5.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_icon_55"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.selectedIndex = 0;
    self.viewControllers = @[_nav_1,_nav_2,_nav_4,_nav_5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hereLogout) name:@"LOGOUTED" object:nil];
    
    [GolfAppDelegate shareAppDelegate].naviController = _nav_1;
    [self loadingTheActivityView];
}

-(void)reloadTableData{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];
        if ([self mineViewAllCount] > 0) {
            ((YGMineViewCtrl *)_nav_5.viewControllers[0]).badgeImage.hidden = YES;;

            _nav_5.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",[self mineViewAllCount]];
        }  else {
            _nav_5.tabBarItem.badgeValue = nil;
            ((YGMineViewCtrl *)_nav_5.viewControllers[0]).badgeImage.hidden = ![self judgeMineViewControllerHaveRedPoint];
        }
    });
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;

    if (array.count > 0 && Equal(flag, @"system_param")) {
        [GolfAppDelegate shareAppDelegate].systemParamInfo = [array objectAtIndex:0];
        
        IndexViewController *indexVC = [[_nav_1 viewControllers] firstObject];
        [indexVC updateSearchKeywords:[[[GolfAppDelegate shareAppDelegate] systemParamInfo] defaultSearchKey]];
        
        NSString *golfClientPhone = [GolfAppDelegate shareAppDelegate].systemParamInfo.servicePhone;
        int topicMsgCount = [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMsgCount;
        int footprintMsgCount = [GolfAppDelegate shareAppDelegate].systemParamInfo.footprintMsgCount;
        int memberFollow = [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMemberFollow;
        
        [[NSUserDefaults standardUserDefaults] setObject:golfClientPhone forKey:@"GolfClientPhone"];
        
        [GolfAppDelegate shareAppDelegate].trendsMainViewController.badgeNumber = topicMsgCount;
        [GolfAppDelegate shareAppDelegate].trendsMainViewController.memberFollow = memberFollow;
        [GolfAppDelegate shareAppDelegate].myfootPrint.badgeNum = footprintMsgCount;

        NSString *sessoinId = ([LoginManager sharedManager].loginState ? [[LoginManager sharedManager] getSessionId]:nil);
        [[ServiceManager serviceManagerWithDelegate:self] userFollowList:sessoinId followType:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:1 pageSize:20];
    }
    
    
    if (Equal(flag, @"deposit_info")) {
        if (array && array.count > 0) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = (int)[LoginManager sharedManager].myDepositInfo.memberLevel;
            YGMineViewCtrl *v = (YGMineViewCtrl *)_nav_5.viewControllers[0];
            if (v.badgeImage == nil) {
                v.badgeImage = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width - Device_Width / 5 * 0.281 , 4, 9, 9)];
                v.badgeImage.backgroundColor = [UIColor redColor];
                [Utilities drawView:v.badgeImage radius:4.5 borderColor:[UIColor redColor]];
                [self.tabBar addSubview:v.badgeImage];
            }
            if ([self judgeMineViewControllerHaveRedPoint] && [self mineViewAllCount] == 0) {
                v.badgeImage.hidden = NO;
            }else{
                v.badgeImage.hidden = YES;
            }
        }
    }
    
    if (Equal(flag, @"user_follow_list")) {
        if (array && array.count > 0) {
            NSDictionary *dic = [array objectAtIndex:0];
            int newFollowedCount = [[dic objectForKey:@"new_followed_count"] intValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(newFollowedCount) forKey:@"NEW_FOLLOWED_COUNT"];
            self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];
            int allCount = [GolfAppDelegate shareAppDelegate].systemParamInfo.accountMsgCount + newFollowedCount + self.msgCount;
            if (allCount > 0) {
                _nav_5.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",allCount];
            } else {
                _nav_5.tabBarItem.badgeValue = nil;
                [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[LoginManager sharedManager].session.sessionId needCount:1];
            }
        }
    }
}

- (BOOL)judgeMineViewControllerHaveRedPoint {
    if ([self judgeDepositInfoIncrease] || [self judgeFriendHaveRedPoint]) {
        return YES;
    }
    return NO;
}

- (BOOL)judgeFriendHaveRedPoint {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"WillFriendsRemind"]) {
        return YES;
    }
    return NO;
}

- (int)mineViewAllCount {
    return self.msgCount + [self sumOfOrderNumber] + [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEW_FOLLOWED_COUNT"] intValue];
}

- (BOOL)judgeDepositInfoIncrease {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSNumber *yunbiBalance = [def objectForKey:[NSString stringWithFormat:@"yunbiBalance-%@", [LoginManager sharedManager].session.mobilePhone]];
    NSNumber *banlance = [def objectForKey:[NSString stringWithFormat:@"banlance-%@", [LoginManager sharedManager].session.mobilePhone]];
    NSNumber *couponTotal = [def objectForKey:[NSString stringWithFormat:@"couponTotal-%@", [LoginManager sharedManager].session.mobilePhone]];
    if (yunbiBalance) {
        if ([LoginManager sharedManager].myDepositInfo.yunbiBalance > [yunbiBalance intValue]) {
            return  YES;
        }
    }
    if (banlance) {
        if ([LoginManager sharedManager].myDepositInfo.banlance > [banlance intValue]) {
            return  YES;
        }
    }
    if (couponTotal) {
        if ([LoginManager sharedManager].myDepositInfo.couponTotal > [couponTotal intValue]) {
            return  YES;
        }
    }
    return NO;
}

- (int)sumOfOrderNumber {
    int count = 0;
    count += [LoginManager sharedManager].myDepositInfo.waitPayCount;
    count += [LoginManager sharedManager].myDepositInfo.waitPayCount2;
    count += [LoginManager sharedManager].myDepositInfo.waitPayCount3;
    count += [LoginManager sharedManager].myDepositInfo.teachingMsgCount;
    return count;
}

- (void)viewWillAppear:(BOOL)animated {//lyf 因为实时性比较强 所以每次获取信息
    [super viewWillAppear:animated];
    if ([LoginManager sharedManager].loginState) {
        [self getYaoCurrent];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self selectedIndexDidChanged];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController
{
    [super setSelectedViewController:selectedViewController];
    [self selectedIndexDidChanged];
}

- (void)selectedIndexDidChanged
{
    [self stopTimer];
    if (self.selectedIndex == 0) {
        [GolfAppDelegate shareAppDelegate].naviController = _nav_1;
    } else if (self.selectedIndex == 1) {
        [GolfAppDelegate shareAppDelegate].naviController = _nav_2;
    }else if (self.selectedIndex == 2){
        [GolfAppDelegate shareAppDelegate].naviController = _nav_4;
    } else if (self.selectedIndex == 3){
        [GolfAppDelegate shareAppDelegate].naviController = _nav_5;
    }
}

#pragma mark -UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (viewController == _nav_4 || viewController == _nav_5) {
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:tabBarController animate:YES blockRetrun:^(id data) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self setSelectedViewController:viewController];
                    //这里是当没有登录的时候，[GolfAppDelegate shareAppDelegate].naviController 需要赋值当前的导航，否则会引发一系列问题
                    if ([viewController isKindOfClass:[UINavigationController class]]) {
                        [GolfAppDelegate shareAppDelegate].naviController = (UINavigationController *)viewController;
                    }else{
                        [GolfAppDelegate shareAppDelegate].naviController = viewController.navigationController;
                    }
                });
            }];
            return NO;
        }
    }
    
    if ( tabBarController.selectedViewController == viewController && viewController == _nav_2) {
        //动态
        TrendsMainViewController *trendsMain = [[(UINavigationController *)viewController viewControllers] firstObject];
        [trendsMain tabbarTapped];
    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self selectedIndexDidChanged];
}

#pragma mark -ClickedTheMiddleButton
- (void)tabBarDidTappedMiddleButton
{
    self.isClickedMiddleButton = YES;
    if (![self canInternet]) {
        [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
        return;
    }
    [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
        [self nowToTogetherViewController];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopTimer];
}

- (void)startLongTimer {
    [_loadingView startAnimating];
    [self.longTimer invalidate];
    self.longTimer = [NSTimer timerWithTimeInterval:4
                                             target:self
                                           selector:@selector(stopTheActivityView)
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.longTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTheActivityView {
    if (self.longTimer.isValid) {
        [SVProgressHUD showInfoWithStatus:@"请求超时"];
    }
    [self stopTimer];
}

- (void)stopTimer {
    [_loadingView stopAnimating];
    [self.longTimer invalidate];
    self.longTimer = nil;
}

- (void)loadingTheActivityView {
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    view.hidesWhenStopped = YES;
    self.loadingView = view;
    [self.view addSubview:view];
    [view stopAnimating];
}

- (void)nowToTogetherViewController {
    YGPostBuriedPoint(YGYueqiuPoint_Home);
    [self startLongTimer];
    self.isClickedMiddleButton = YES;
    [[API shareInstance] yaoCurrentSuccess:^(id data) {
        self.isClickedMiddleButton = NO;
        YaoBallCurrent *current = data;
        UIViewController *topVC = nil;
        
        if (current.unReadCloseYaoid > 0) {//超时关闭有人加
            YQDetailViewController *v = [[UIStoryboard storyboardWithName:@"TogetherLQ" bundle:NULL]instantiateViewControllerWithIdentifier:@"YQDetailViewController"];
            v.yaoId = current.unReadCloseYaoid;
            topVC = v;
        } else if (current.yaoid > 0) {//旧的还没关
            if (current.joincount > 0) {//有人加
                OngoingAppointmentViewController *v = [[UIStoryboard storyboardWithName:@"TogetherLQ" bundle:NULL]instantiateViewControllerWithIdentifier:@"OngoingAppointmentViewController"];
                v.yaoID = current.yaoid;
                topVC = v;
            } else {
                ReadyToSendViewController *v = [[UIStoryboard storyboardWithName:@"TogetherLYF" bundle:NULL]instantiateViewControllerWithIdentifier:@"ReadyToSendViewController"];
                _togetherVc.navigationController.navigationBarHidden = YES;
                v.currentYaoBall = data;
                v.successTag = 1;
                topVC = v;
            }
        }
        YGBaseNavigationController *vc = [[UIStoryboard storyboardWithName:@"TogetherLHQ" bundle:NULL] instantiateViewControllerWithIdentifier:@"NavTogetherViewController"];
        _togetherVc = vc.viewControllers[0];
        if (topVC != nil) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TOGETHER_TIPS_ALERTED];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _togetherVc.topViewController = topVC;
            [_togetherVc addChildViewController:topVC];
            [_togetherVc.view addSubview:topVC.view];
            if (current.unReadCloseYaoid > 0) {
                [_togetherVc leftNavButtonImg:@"fanhui01"];
            }
        }
        _togetherVc.remaincount = current.remaincount;
        [[PINCache sharedCache] setObject:@(current.yaoType) forKey:PLACE_SELECTED_INDEX];//保存选择的是球场约球还是练习场约球
        [self presentViewController:vc animated:YES completion:^{
            [self stopTimer];
            dispatch_async(dispatch_get_main_queue(), ^{
                [GolfAppDelegate shareAppDelegate].badgeYQView.hidden = YES;
            });
            
            [[API shareInstance] unReadPushMsgWithType:1 success:nil failure:nil];
        }];

        [GolfAppDelegate shareAppDelegate].naviController = vc;
        _nav_3 = vc;
        
        BOOL notifyStatus = YES;
        if (current.notifyStatus == 1) {//约球推送状态打开的
            notifyStatus = YES;
        }else if (current.notifyStatus == 2){//约球推送状态关闭的
            notifyStatus = NO;
        }
        [[PINCache sharedCache] setObject:@(notifyStatus) forKey:IDENTIFIER(@"ISOPEN_YQ_PUSH")];
    } failure:^(Error *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopTimer];
            if (error.code == 100019 || error.code == 100020) {
                self.isClickedMiddleButton = NO;//别拿出来,自动登录要为YES
                YGBaseNavigationController *vc = [[UIStoryboard storyboardWithName:@"TogetherLHQ" bundle:NULL] instantiateViewControllerWithIdentifier:@"NavTogetherViewController"];
                _togetherVc = vc.viewControllers[0];
                _togetherVc.errorCode = error.code;
                [self presentViewController:vc animated:YES completion:nil];
                [GolfAppDelegate shareAppDelegate].naviController = vc;
                _nav_3 = vc;
            } else if (error.code == 100018) {
                self.isClickedMiddleButton = NO;//别拿出来，自动登录要为YES
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你涉嫌发布违规信息，帐号已被限制使用约球功能" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:nil];
                [alert addAction:deleteAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)getYaoCurrent {
    if ([LoginManager sharedManager].loginState) {
        [[API shareInstance] yaoCurrentSuccess:^(id data) {
            self.yaoBallCurrent = data;
            if (_yaoBallCurrent.yaostatus == 1){
                [self middelTabBarButtonStopAnimation:NO];
            } else {
                if (_yaoBallCurrent.yaoid == 0) {
                    [self middelTabBarButtonStopAnimation:YES];
                    if (_yaoBallCurrent.remaincount > 0 && [self isInMainViewController]) {
                        [self willShowHints];
                    }
                } else {
                    [self middelTabBarButtonBeginAnimationWithShowTime:_showTime];
                }
            }
        } failure:^(Error *error) {
            NSLog(@"lyf %@:%@", NSStringFromSelector(_cmd), error);
        }];
    } else {
        [self middelTabBarButtonStopAnimation:YES];
    }
}

- (void)setYaoBallCurrent:(YaoBallCurrent *)yaoBallCurrent {
    _yaoBallCurrent = yaoBallCurrent;
    self.showTime = [_yaoBallCurrent.showtime intValue];
}

- (void)middelTabBarButtonBeginAnimationWithShowTime:(NSInteger)time {
    [self.theTabBar.theTabBarButton beginAnimationWithShowTime:time];
}

- (void)middelTabBarButtonStopAnimation:(BOOL)isClearLocation {
    [self.theTabBar.theTabBarButton stopAnimation:isClearLocation];
}

- (BOOL)isInMainViewController {
    if (_nav_1.viewControllers.count > 1 || _nav_2.viewControllers.count > 1 || _nav_3 != nil || _nav_4.viewControllers.count > 1 || _nav_5.viewControllers.count > 1) {
        return NO;
    }
    return YES;
}

- (BOOL)isFistOpenTheAPPToday {//同一个帐号一天一次
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newString = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *oldString = [def stringForKey:@"OneDayOneHints"];
    if (![newString isEqualToString:oldString]) {
        [def setObject:newString forKey:@"OneDayOneHints"];
        [def synchronize];
        return YES;
    }
    return NO;
}

- (void)initializeLocation {
    NSString *longitudeString = @"0";
    NSString *latitudeString = @"0";
    if([LoginManager sharedManager].positionIsValid) {
        longitudeString = [NSString stringWithFormat:@"%f", [LoginManager sharedManager].currLongitude];
        latitudeString = [NSString stringWithFormat:@"%f", [LoginManager sharedManager].currLatitude];
    }
    _location = [Location new];
    _location.longitude = longitudeString;
    _location.latitude = latitudeString;
}

- (void)willShowHints {
    if ([self isFistOpenTheAPPToday]) {
        [self initializeLocation];
        PageBean *pb = [[PageBean alloc] init];
        pb.rowNumber = 1;
        pb.lastFlagInt = 0;
        [[API shareInstance] yaoBallListByPage:pb location:_location success:^(YaoBallList *data) {
            if (data.wantballcount > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showHintsView:data.wantballcount];
                });
            }
        } failure:^(Error *error) {
            NSLog(@"lyf %@:%@", NSStringFromSelector(_cmd), error);
        }];
    }
}

- (void)showHintsView:(int)count {
    _hintsView = [[NSBundle mainBundle] loadNibNamed:@"MiddleBarButtonHintsView" owner:self options:nil].firstObject;
    _hintsView.alpha = 0;
    _hintsView.centerX = self.tabBar.centerX;
    _hintsView.yg_y = -47;
    _hintsView.hintsLabel.text = [NSString stringWithFormat:@"你附近有%d人想要约球", count];
    
    CGSize size =[_hintsView.hintsLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _hintsView.width = size.width + 30;
    _hintsView.hintsLabel.centerX = _hintsView.centerY;
    _hintsView.centerX = self.tabBar.centerX;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBar addSubview:_hintsView];
        [UIView animateWithDuration:1 animations:^{
            _hintsView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    });

    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(hiddenTheHintsView) userInfo:nil repeats:NO];
}

- (void)hiddenTheHintsView {
    [UIView animateWithDuration:1 animations:^{
        _hintsView.alpha = 0;
    } completion:^(BOOL finished) {
        [_hintsView removeFromSuperview];
    }];
}

- (void)refreshReadyToSend {
    if (_nav_3) {
        if ([_togetherVc.topViewController isMemberOfClass:[ReadyToSendViewController class]] && _togetherVc.topViewController) {
            [[PINCache sharedCache] objectForKey:IDENTIFIER(@"ISOPEN_PUSH_VOICE") block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                [[GetYQSound shareGetYQSound] playSystemSoundIsOpen:![object boolValue]];
            }];
            ReadyToSendViewController *vc = (ReadyToSendViewController *)_togetherVc.topViewController;
            if (vc.successTag == 1) {//changeReadyToSend调用了改函数，所以需要过滤
                OngoingAppointmentViewController *ov = [[UIStoryboard storyboardWithName:@"TogetherLQ" bundle:NULL]instantiateViewControllerWithIdentifier:@"OngoingAppointmentViewController"];
                ov.yaoID = ((ReadyToSendViewController *)_togetherVc.topViewController).currentYaoBall.yaoid;
                _togetherVc.title = @"正在约球";
                CGRect rect = [UIScreen mainScreen].bounds;
//                if (_togetherVc.navigationController.viewControllers.count == 1) {
//                    rect.size.height = [UIScreen mainScreen].bounds.size.height - 64;
//                }
                ov.view.frame = rect;
                NSLog(@"lyf ov.frame = %@", NSStringFromCGRect(ov.view.frame));
                
                self.navigationController.navigationBarHidden = NO;
                [_togetherVc addChildViewController:ov];
                [_togetherVc.view addSubview:ov.view];
                
                [_togetherVc.topViewController.view removeFromSuperview];
                [_togetherVc.topViewController removeFromParentViewController];
                _togetherVc.topViewController = ov;
            }
        }
    }
}

- (void)changeReadyToSend {
    if ([LoginManager sharedManager].loginState) {
        if (_nav_3) {
            [[API shareInstance] yaoCurrentSuccess:^(id data) {
                self.yaoBallCurrent = data;
                //从后台回来刷新OngoingAppointmentViewController
                if ([_togetherVc.topViewController isMemberOfClass:[OngoingAppointmentViewController class]] && _togetherVc.topViewController) {
                    [(OngoingAppointmentViewController *)_togetherVc.topViewController getFirstData];
                    return;
                }
                if ((_yaoBallCurrent.yaostatus == 2 && _yaoBallCurrent.joincount > 0) || _yaoBallCurrent.unReadCloseYaoid > 0){//ReadyToSendViewController页面状态改变（有人加入或者加入满关闭）
                    [self refreshReadyToSend];//从后台回来刷新ReadyToSendViewController
                }
            } failure:^(Error *error) {
                NSLog(@"lyf %@:%@", NSStringFromSelector(_cmd), error);
            }];
        }
    }
}

- (void)showYaoBallHints {
    if ([self isInMainViewController]) {
        [self willShowHints];
    }
}

- (void)hereLogout {
    [self middelTabBarButtonStopAnimation:YES];
    [GolfAppDelegate shareAppDelegate].badgeYQView.hidden = YES;
}

- (void)hereLoginSuccess {
    [self getYaoCurrent];
    [[ServiceManager serviceManagerWithDelegate:self] systemParamInfo:[[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone] sessionID:[LoginManager sharedManager].session.sessionId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:IMSessionValueChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:IMMessageReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:IMMessageSendedNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LOGIN_SUCCESSED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LOGOUTED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshOngoingYQList" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMMessageReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMMessageSendedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMSessionValueChangedNotification object:nil];
}

- (BOOL)canInternet {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

@end
