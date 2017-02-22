//
//  BaseNavController.h
//  Golf
//
//  Created by user on 12-11-22.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGRefreshComponent.h"

@interface BaseNavController : UIViewController{
    UIButton *_navLeft;    UIButton *_navRight;
}
@property (nonatomic, strong) NSString *baiduMobStatName;
@property (nonatomic) float fontSize;
@property (nonatomic, assign) BOOL debugLevel;
@property (nonatomic, copy) NSString *teetime;
@property (nonatomic, strong) UIImage *defaultImage;

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

- (void)doLeftNavAction;
- (void)doRightNavAction;
- (void)doOptionNavAction;

@end
