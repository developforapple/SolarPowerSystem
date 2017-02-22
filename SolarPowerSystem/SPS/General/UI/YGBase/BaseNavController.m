//
//  BaseNavController.m
//  Golf
//
//  Created by user on 12-11-22.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "BaseNavController.h"
#import "UIView+AutoLayout.h"
#import "CCAlertView.h"

@interface BaseNavController (){
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


- (void)doOptionNavAction{
    // DO nothing ....
}

- (void)rightItemsButtonAction:(UIButton*)button{
    //**************************
}

@end
