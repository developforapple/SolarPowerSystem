//
//  DiguBaseViewController.m
//  LekuIndiana
//
//  Created by FLYGo on 14/12/4.
//  Copyright (c) 2014年 Digu. All rights reserved.
//

#import "YGBaseViewController.h"
#import "BaiduMobStat.h"
#import <UMMobClick/MobClick.h>

@interface YGBaseViewController ()
@end

@implementation YGBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.statisticsToken) {
        [[BaiduMobStat defaultStat] pageviewStartWithName:self.statisticsToken];
        [MobClick beginLogPageView:self.statisticsToken];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (self.statisticsToken) {
        [[BaiduMobStat defaultStat] pageviewEndWithName:self.statisticsToken];
        [MobClick endLogPageView:self.statisticsToken];
    }
}

@end
