//
//  CoachTransitionalPageController.m
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachTransitionalPageController.h"
#import "CoachBaseInfoController.h"

@interface CoachTransitionalPageController ()

@end

@implementation CoachTransitionalPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self leftNavButtonImg:@"ic_nav_back_light"];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}

- (IBAction)next:(id)sender
{
    [self pushWithStoryboard:@"Coach" title:@"填写资料" identifier:@"CoachBaseInfoController" completion:^(BaseNavController *controller) {
        CoachBaseInfoController *vc = (CoachBaseInfoController*)controller;
        vc.blockReturn = self.blockReturn;
    }];
}

- (IBAction)clickBack:(id)sender
{
    [super doLeftNavAction];
}

@end
