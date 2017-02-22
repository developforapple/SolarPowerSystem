//
//  BaseNavController.h
//  Golf
//
//  Created by user on 12-11-22.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceManager.h"
#import "NoResultView.h"
#import "BaseService.h"
#import "ServerService.h"
#import "YGRefreshComponent.h"
#import "YGLoginViewCtrlDelegate.h"

@interface BaseNavController : UIViewController<ServiceManagerDelegate,YGLoginViewCtrlDelegate>{
    UIButton *_navLeft;
    UIButton *_navRight;
}
@property (nonatomic, strong) NSString *baiduMobStatName;
@property (nonatomic) float fontSize;
@property (nonatomic, assign) BOOL debugLevel;
@property (nonatomic, copy) NSString *teetime;
@property (nonatomic, strong) UIImage *defaultImage;

// 获取一个故事板对象
- (UIStoryboard *)storyboard:(NSString*)aName;

#warning 下面这些push方法存在一些问题，比如说赋值会出现失败，对象必须继承这个类等等。计划废弃。用原生的。
// push控制器方法
- (void)push:(BaseNavController*)controller title:(NSString*)aTitle;
- (void)push:(BaseNavController *)controller title:(NSString *)aTitle hideBackButton:(BOOL)hide animated:(BOOL)animated;
- (void)push:(BaseNavController*)controller title:(NSString*)aTitle hideBackButton:(BOOL)hide;
- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier;
- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier hideBackButton:(BOOL)hide;
- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier completion:(void(^)(BaseNavController *controller))completion NS_DEPRECATED_IOS(6_0,9_0);
- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier hideBackButton:(BOOL)hide completion:(void(^)(BaseNavController *controller))completion;
- (void)pushWithStoryboard:(NSString*)aName title:(NSString*)aTitle identifier:(NSString*)aIdentifier hideBackButton:(BOOL)hide animated:(BOOL)animated completion:(void(^)(BaseNavController *controller))completion;

- (void)back;
- (void)backHome;
- (void)leftButtonAction;
- (void)leftButtonAction:(NSString *)title;
- (void)rightButtonAction:(NSString *)title;
- (void)rightButtonAction:(NSString *)title enable:(BOOL)enable;

- (void)leftButtonsView:(UIView*)view;
- (void)rightButtonsView:(UIView*)view;

- (void)leftButtonActionWithImg:(NSString *)img;
- (void)leftNavButtonImg:(NSString*)img;
- (void)rightButtonActionWithImg:(NSString *)img;
- (void)rightNavButtonImg:(NSString*)img;
- (void)rightButtonActionWithImg:(NSString *)img autoSize:(BOOL)autoSize;
- (void)noLeftButton;

- (NSArray *)twoButtonItems:(NSArray*)buttonImgNames;
- (NSArray *)navBtnTitleAndImageItems:(NSArray*)items;
- (NSArray *)barButtonItems:(NSArray*)items;
- (void)rightItemsButtonAction:(UIButton*)button;

//- (UIView *)navButtonImage:(UIImage *)image IconNum:(int)iconNum;
- (UIView *)navButtonImage:(UIImage *)image IconNum:(int)iconNum isRight:(BOOL)isRight;

//- (void)setNavTitle:(NSString*)title;

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)doLeftNavAction;
- (void)doRightNavAction;
- (void)doOptionNavAction;

- (void)pushViewController:(UIViewController *)viewController hide:(BOOL)isHide;
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title hide:(BOOL)isHide;
- (void)pushViewController:(UIViewController *)viewController navigationBarHidden:(BOOL)navigationBarHidden hidesBottomBarWhenPushed:(BOOL)isHide;
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title hide:(BOOL)isHide animated:(BOOL)animated;

- (void)setExtraCellLineHidden:(UITableView *)tableView;
- (BOOL)needPerfectMemberData;//判断是否需要完善资料
- (BOOL)needPerfectMemberDataWithCompletion:(void(^)(id data))completion;

- (__kindof BaseNavController *)controllerOfView:(UIView *)aView;
- (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString*)displayName target:(BaseNavController*)target;
- (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString *)displayName target:(BaseNavController *)target blockFollow:(BlockReturn)blockFollow;

@end
