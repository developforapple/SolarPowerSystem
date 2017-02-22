//
//  YGTabBarController.m
//  Golf
//
//  Created by lyf on 16/5/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGTabBarController.h"
#import "CCAlertView.h"
#import "YGBaseNavigationController.h"

#define TOGETHER_TIPS_ALERTED @"TOGETHER_TIPS_ALERTED"
#define LOCATION_OBJECT_SELECTED @"LOCATION_OBJECT_SELECTED"


@interface YGTabBarController ()<UITabBarControllerDelegate>
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
    
//    self.theTabBar = [[GolfTabBar alloc] initWithFrame:self.tabBar.bounds];
//    ygweakify(self);
//    [self.theTabBar setMiddleBtnTappedAction:^{
//        ygstrongify(self);
//        [self tabBarDidTappedMiddleButton];
//    }];
//    [self setValue:_theTabBar forKey:@"tabBar"];

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
    
    [self loadingTheActivityView];
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
    
}

#pragma mark -UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self selectedIndexDidChanged];
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
  
}

@end
