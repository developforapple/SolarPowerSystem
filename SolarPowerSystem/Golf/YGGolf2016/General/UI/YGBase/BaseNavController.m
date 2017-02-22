//
//  BaseNavController.m
//  Golf
//
//  Created by user on 12-11-22.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "BaseNavController.h"
#import "Utilities.h"
#import "BaiduMobStat.h"
#import "YGProfileViewCtrl.h"
#import "YGFillInProfileViewCtrl.h"
#import "UIView+AutoLayout.h"
#import "CCAlertView.h"

@interface BaseNavController ()<YGLoginViewCtrlDelegate>{
    NSString *_loginFlagString;
}

@property (nonatomic,strong) UIViewController *baseNavController;

@end

@implementation BaseNavController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.defaultImage = [UIImage imageNamed:@"cgit_s.png"];
    
    self.baiduMobStatName = self.title;
    self.debugLevel = NO;
    
    [self leftNavButtonImg:@"ic_nav_back"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [GolfAppDelegate shareAppDelegate].currentController = self;
}

- (void)dealloc
{
    NSLog(@"%@ 释放",NSStringFromClass([self class]));
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_baiduMobStatName) {
        [[BaiduMobStat defaultStat] pageviewStartWithName:_baiduMobStatName];
        [MobClick beginLogPageView:_baiduMobStatName];
    }
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_baiduMobStatName) {
        [[BaiduMobStat defaultStat] pageviewEndWithName:_baiduMobStatName];
        [MobClick endLogPageView:_baiduMobStatName];
    }
    [super viewWillDisappear:animated];
}

- (void)noLeftButton{
    self.navigationItem.leftBarButtonItem = nil;
}

- (UIStoryboard *)storyboard:(NSString*)aName{
    if (!aName || aName.length == 0) {
        return nil;
    }
    return [UIStoryboard storyboardWithName:aName bundle:nil];
}

- (void)push:(BaseNavController *)controller title:(NSString *)aTitle{
    if (controller) {
        if (aTitle) {
            controller.title = aTitle;
        }
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)push:(BaseNavController *)controller title:(NSString *)aTitle hideBackButton:(BOOL)hide animated:(BOOL)animated{
    if (controller) {
        if (aTitle) {
            controller.title = aTitle;
        }
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:animated];
    }
}


- (void)push:(BaseNavController *)controller title:(NSString *)aTitle hideBackButton:(BOOL)hide{
    if (controller) {
        if (aTitle) {
            controller.title = aTitle;
        }
//        [controller.navigationItem setHidesBackButton:hide];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier{
    UIStoryboard *story = [self storyboard:aName];
    if (aIdentifier) {
        BaseNavController *controller = [story instantiateViewControllerWithIdentifier:aIdentifier];
        [self push:controller title:aTitle];
    }
}

- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier hideBackButton:(BOOL)hide{
    UIStoryboard *story = [self storyboard:aName];
    if (aIdentifier) {
        BaseNavController *controller = [story instantiateViewControllerWithIdentifier:aIdentifier];
        [self push:controller title:aTitle hideBackButton:hide];
    }
}

- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier hideBackButton:(BOOL)hide completion:(void(^)(BaseNavController *controller))completion{
    UIStoryboard *story = [self storyboard:aName];
    if (aIdentifier) {
        BaseNavController *controller = [story instantiateViewControllerWithIdentifier:aIdentifier];
        if (completion) {
            completion(controller);
        }
        [self push:controller title:aTitle hideBackButton:hide];
    }
}

- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier hideBackButton:(BOOL)hide animated:(BOOL)animated completion:(void(^)(BaseNavController *controller))completion{
    UIStoryboard *story = [self storyboard:aName];
    if (aIdentifier) {
        BaseNavController *controller = [story instantiateViewControllerWithIdentifier:aIdentifier];
        if (completion) {
            completion(controller);
        }
        [self push:controller title:aTitle hideBackButton:hide animated:animated];
    }
}

- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier completion:(void(^)(BaseNavController *controller))completion{
    UIStoryboard *story = [self storyboard:aName];
    if (aIdentifier) {
        BaseNavController *controller = [story instantiateViewControllerWithIdentifier:aIdentifier];
        if (completion) {
            completion(controller);
        }
        [self push:controller title:aTitle];
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backHome{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionReveal];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    [self.navigationController popViewControllerAnimated:YES];
    [CATransaction commit];
}

- (void)doLeftNavAction{
    [self back];
}

- (void)doRightNavAction{
    // DO nothing ....
}

- (void)leftButtonActionWithImg:(NSString *)img{
    UIButton *navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navLeftButton.frame = CGRectMake(0, 0, 50, 30);
    [navLeftButton setBackgroundImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    [navLeftButton setBackgroundImage:[UIImage imageNamed:img] forState:UIControlStateHighlighted];
    [navLeftButton addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
}

- (void)leftNavButtonImg:(NSString*)img{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:img] style:UIBarButtonItemStylePlain target:self action:@selector(doLeftNavAction)];
}

- (void)leftNavButtonImg:(NSString*)img tintColor:(UIColor *)color{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:img] style:UIBarButtonItemStylePlain target:self action:@selector(doLeftNavAction)];
    item.tintColor = color;
    self.navigationItem.leftBarButtonItem = item;
}

- (void)rightNavButtonImg:(NSString*)img{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:img] style:UIBarButtonItemStylePlain target:self action:@selector(doRightNavAction)];
}

- (void)rightNavButtonImg:(NSString*)img tintColor:(UIColor *)color{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:img] style:UIBarButtonItemStylePlain target:self action:@selector(doRightNavAction)];
    item.tintColor = color;
    self.navigationItem.rightBarButtonItem = item;
}

- (void)rightButtonActionWithImg:(NSString *)img{
    UIButton *navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightButton.frame = CGRectMake(0, 0, 50, 30);
    [navRightButton setBackgroundImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    [navRightButton setBackgroundImage:[UIImage imageNamed:img] forState:UIControlStateHighlighted];
    [navRightButton addTarget:self action:@selector(doRightNavAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
}

- (void)rightButtonActionWithImg:(NSString *)img autoSize:(BOOL)autoSize{
    if (autoSize) {
        UIImage *image = [UIImage imageNamed:img];
        UIButton *navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        navRightButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [navRightButton setBackgroundImage:image forState:UIControlStateNormal];
        [navRightButton setBackgroundImage:image forState:UIControlStateHighlighted];
        [navRightButton addTarget:self action:@selector(doRightNavAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    }else{
        [self rightButtonActionWithImg:img];
    }
}

- (void)leftButtonAction{
    [self leftButtonActionWithImg:@"back_icon"];
}

- (void)leftButtonAction:(NSString *)title{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(doLeftNavAction)];
}

- (void)rightButtonAction:(NSString *)title enable:(BOOL)enable{
    if (!self.navigationItem.rightBarButtonItem) {
        [self rightButtonAction:title];
    }
    self.navigationItem.rightBarButtonItem.enabled = enable;
}

- (void)rightButtonAction:(NSString *)title {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(doRightNavAction)];
}

- (void)leftButtonsView:(UIView*)view{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (void)rightButtonsView:(UIView*)view{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (UIView *)navButtonImage:(UIImage *)image IconNum:(int)iconNum isRight:(BOOL)isRight{
    if (!image) return nil;
    
    CGSize sz = image.size;
    
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.frame = CGRectMake(0, 0, sz.width, sz.height);
    [bgBtn setBackgroundImage:image forState:UIControlStateNormal];
    if (isRight) {
        [bgBtn addTarget:self action:@selector(doRightNavAction) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [bgBtn addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (iconNum>0) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (isRight) {
            button.frame = CGRectMake(sz.width-10, 0, 20, 20);
        }else{
            button.frame = CGRectMake(sz.width-10, 0, 20, 20);
        }
        
        button.backgroundColor = [UIColor redColor];
        
        [button setTitle:[NSString stringWithFormat:@"%d",iconNum] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        button.enabled = NO;
        [bgBtn addSubview:button];
        
        [Utilities drawView:button radius:10 bordLineWidth:0 borderColor:nil];
    }
    return bgBtn;
}

- (NSArray *)twoButtonItems:(NSArray*)buttonImgNames{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<buttonImgNames.count; i++) {
        NSString *btnImgName = [buttonImgNames objectAtIndex:i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (btnImgName.length>0) {
            btn.frame = CGRectMake(0, 0, 30, 20);
        }
        [btn setBackgroundImage:[UIImage imageNamed:btnImgName] forState:UIControlStateNormal];
        btn.tag = i+1;
        [btn addTarget:self action:@selector(rightItemsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [array addObject:barButton];
    }
    return array;
}

- (NSArray*)barButtonItems:(NSArray*)items{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<items.count; i++) {
        id obj = items[i];
        UIImage *image = nil;
        NSInteger iconNum = 0;
        if ([obj isKindOfClass:[NSString class]]) {
            image = [UIImage imageNamed:obj];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            NSDictionary *dic = (NSDictionary*)obj;
            image = [UIImage imageNamed:dic[@"image_name"]];
            iconNum = [dic[@"icon_num"] integerValue];
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (image) {
            btn.frame = CGRectMake(0, 0, MAX(30, image.size.width) , MAX(image.size.height, 30));
        }
        [btn setImage:image forState:UIControlStateNormal];
        btn.tag = i+1;
        [btn addTarget:self action:@selector(rightItemsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (iconNum>0) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(image.size.width-10, 0, 20, 20);
            button.backgroundColor = [UIColor redColor];
            [button setTitle:[NSString stringWithFormat:@"%tu",iconNum] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            button.enabled = NO;
            [btn addSubview:button];
            
            [Utilities drawView:button radius:10 bordLineWidth:0 borderColor:nil];
        }
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [array addObject:barButton];
    }
    return array;
}

- (NSArray*)navBtnTitleAndImageItems:(NSArray*)items{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        
        UIImage *image = [UIImage imageNamed:item[@"btnImageName"]];
        NSString *btnTitle = item[@"btnTitle"];
        
        CGSize sz = [Utilities getSize:btnTitle withFont:[UIFont boldSystemFontOfSize:12] withWidth:50];
        CGFloat width = MAX(sz.width, image.size.width);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 0, width+4, 44);
        btn.tag = i+1;
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(15, -image.size.width, 0, 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, image.size.width/2.-2, 15, -image.size.width/2.+2)];
        [btn addTarget:self action:@selector(rightItemsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        barButton.tintColor = [UIColor clearColor];
        [arr addObject:barButton];
    }
    return arr;
}


- (void)doOptionNavAction{
    // DO nothing ....
}

- (void)rightItemsButtonAction:(UIButton*)button{
    //**************************
}

- (void)pushViewController:(UIViewController *)viewController navigationBarHidden:(BOOL)navigationBarHidden hidesBottomBarWhenPushed:(BOOL)isHide
{
    if (!viewController) return;
    
    if ([viewController isKindOfClass:[YGProfileViewCtrl class]]) {
        self.baseNavController = viewController;
        YGProfileViewCtrl *personal = (YGProfileViewCtrl*)viewController;
        if ([LoginManager sharedManager].loginState == NO) {
            _loginFlagString = @"UserBaseInfoImproveController";
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
            return;
        }
        
        if (personal.memberId != [LoginManager sharedManager].session.memberId) {
            if ([self needPerfectMemberData]) {
                return;
            }
        }
    }
    
//    [viewController.navigationItem setHidesBackButton:YES];
    viewController.hidesBottomBarWhenPushed = isHide;
    self.navigationController.navigationBarHidden = navigationBarHidden;
    [self.navigationController pushViewController:viewController animated:YES];
    self.baseNavController = nil;
}

- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title hide:(BOOL)isHide animated:(BOOL)animated
{
    if (!viewController) return;
    
    viewController.title = title;
    viewController.hidesBottomBarWhenPushed = isHide;
//    [viewController.navigationItem setHidesBackButton:YES];
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title hide:(BOOL)isHide
{
    if (!viewController) return;
    
    viewController.title = title;
    if ([viewController isKindOfClass:[YGProfileViewCtrl class]]) {
        self.baseNavController = viewController;
        YGProfileViewCtrl *personal = (YGProfileViewCtrl*)viewController;
        if ([LoginManager sharedManager].loginState == NO) {
            _loginFlagString = @"UserBaseInfoImproveController";
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
            return;
        }
        
        if (personal.memberId != [LoginManager sharedManager].session.memberId) {
            if ([self needPerfectMemberData]) {
                return;
            }
        }
    }
    
//    [viewController.navigationItem setHidesBackButton:YES];
    viewController.hidesBottomBarWhenPushed = isHide;
    [self.navigationController pushViewController:viewController animated:YES];
    self.baseNavController = nil;
}

- (void)pushViewController:(UIViewController *)viewController hide:(BOOL)isHide
{
    if (!viewController) return;
    
    if ([viewController isKindOfClass:[YGProfileViewCtrl class]]) {
        self.baseNavController = viewController;
        YGProfileViewCtrl *personal = (YGProfileViewCtrl*)viewController;
        if ([LoginManager sharedManager].loginState == NO) {
            _loginFlagString = @"UserBaseInfoImproveController";
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
            return;
        }
        
        if (personal.memberId != [LoginManager sharedManager].session.memberId) {
            if ([self needPerfectMemberData]) {
                return;
            }
        }
    }
    
//    [viewController.navigationItem setHidesBackButton:YES];
    viewController.hidesBottomBarWhenPushed = isHide;
    [self.navigationController pushViewController:viewController animated:YES];
    self.baseNavController = nil;
}

- (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString*)displayName target:(BaseNavController*)target{
    if (memberId != [LoginManager sharedManager].session.memberId) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    YGProfileViewCtrl *vc = [YGProfileViewCtrl instanceFromStoryboard];
    vc.memberId = memberId;
    vc.title = displayName;
    vc.hidesBottomBarWhenPushed = YES;
    [target.navigationController pushViewController:vc animated:YES];
}

- (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString *)displayName target:(BaseNavController *)target blockFollow:(BlockReturn)blockFollow{
    if (memberId != [LoginManager sharedManager].session.memberId) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    
    YGProfileViewCtrl *vc = [YGProfileViewCtrl instanceFromStoryboard];
    vc.memberId = memberId;
    vc.title = displayName;
    vc.hidesBottomBarWhenPushed = YES;
    vc.blockFollow = blockFollow;
    [target.navigationController pushViewController:vc animated:YES];
}

-(BOOL)needPerfectMemberDataWithCompletion:(void (^)(id data))completion{
    if ([LoginManager sharedManager].loginState == NO) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [self needPerfectMemberDataWithCompletion:completion];
        }];
        return YES;
    }
    
    BOOL needImprove = [YGFillInProfileNaviCtrl presentIfNeed:self finished:^(YGFillInProfileNaviCtrl *navi) {
        [navi setCompletion:^(BOOL canceled) {
            if (!canceled && completion) {
                completion(nil);
            }
        }];
    }];
    return needImprove;
}

//lyf 判断是否完善资料
- (BOOL)needPerfectMemberData {
    if ([LoginManager sharedManager].loginState == NO) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [self needPerfectMemberData];
        }];
        return YES;
    }
    BOOL needImprove = [YGFillInProfileNaviCtrl presentIfNeed:self finished:^(YGFillInProfileNaviCtrl *navi) {
        [navi setCompletion:^(BOOL canceled) {}];
    }];
    return needImprove;
}

- (void)loginFinishHandle{
    [self pushViewController:_baseNavController title:_baseNavController.title hide:YES];
}

- (__kindof BaseNavController *)controllerOfView:(UIView *)aView {
    for (UIView* next = [aView superview]; next; next =
         next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]]) {
            return (BaseNavController*)nextResponder;
        }
    }
    return nil;
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    // doNothing......
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
