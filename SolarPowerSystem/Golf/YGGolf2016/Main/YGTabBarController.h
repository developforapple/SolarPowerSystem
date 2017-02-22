//
//  YGTabBarController.h
//  Golf
//
//  Created by lyf on 16/5/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YGTabType) {
    YGTabTypeIndex,
    YGTabTypeFeed,
    YGTabTypeYue,
    YGTabTypeFootprint,
    YGTabTypeMine
};

#define DefaultTabBarCtrl [YGTabBarController defaultController]

@interface YGTabBarController : UITabBarController

+ (instancetype)defaultController;






@property(nonatomic,strong) UINavigationController *nav_1;
@property(nonatomic,strong) UINavigationController *nav_2;
@property(nonatomic,weak) UINavigationController *nav_3;
@property(nonatomic,strong) UINavigationController *nav_4;
@property(nonatomic,strong) UINavigationController *nav_5;
@property (nonatomic) NSInteger showTime;
@property (nonatomic) BOOL isClickedMiddleButton;//自动登录后，判断点了中间的按钮

- (void)tabBarDidTappedMiddleButton;
- (void)getYaoCurrent;
- (void)middelTabBarButtonBeginAnimationWithShowTime:(NSInteger)time;
- (void)middelTabBarButtonStopAnimation:(BOOL)isClearLocation;
- (void)changeReadyToSend;
- (void)showYaoBallHints;


@end
