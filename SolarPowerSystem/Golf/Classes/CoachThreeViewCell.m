//
//  CoachThreeViewCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachThreeViewCell.h"
#import "TeachingOrderListViewController.h"
#import "CoachReservatListController.h"

@implementation CoachThreeViewCell

- (IBAction)action1:(id)sender {
    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Teach" title:@"订单管理" identifier:@"TeachingOrderListViewController" hideBackButton:NO completion:^(BaseNavController *controller) {
        TeachingOrderListViewController *vc = (TeachingOrderListViewController *)controller;
        vc.coachId = [LoginManager sharedManager].session.memberId;
        vc.hasSearchButton = YES;
        vc.canSlide = YES;
    }];
}

- (IBAction)action2:(id)sender {
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

- (IBAction)action3:(id)sender {
    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Coach" title:@"预约管理" identifier:@"CoachReservatListController" completion:^(BaseNavController *controller){
        CoachReservatListController *coachReservate = (CoachReservatListController*)controller;
        coachReservate.selectedIndex = 2;
    }];
}

- (void)loadData{
    [_todayOrderLabel setText:[NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.todayOrderCount]];
    [_todayWaitTeachLabel setText:[NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.waitTeachCount]];
    [_waitConfirmLabel setText:[NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.waitconfirmCount]];
}

@end
