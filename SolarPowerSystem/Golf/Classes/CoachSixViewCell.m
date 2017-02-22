//
//  CoachSixViewCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachSixViewCell.h"
#import "CoachDataListController.h"
#import "TeachingOrderListViewController.h"
#import "CommentListViewController.h"
#import "YGCoachReservatPagerViewCtrl.h"

@implementation CoachSixViewCell

- (IBAction)action1:(id)sender {
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

- (IBAction)action2:(id)sender {
    
//    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Coach" title:@"预约管理" identifier:@"CoachReservatListController"];
    
    YGCoachReservatPagerViewCtrl *vc = [YGCoachReservatPagerViewCtrl instanceFromStoryboard];
    [[GolfAppDelegate shareAppDelegate].currentController pushViewController:vc hide:YES];
}

- (IBAction)action3:(id)sender {
    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Teach" title:@"订单管理" identifier:@"TeachingOrderListViewController" hideBackButton:NO completion:^(BaseNavController *controller) {
        TeachingOrderListViewController *vc = (TeachingOrderListViewController *)controller;
        vc.coachId = [LoginManager sharedManager].session.memberId;
        vc.canSlide = YES;
        vc.hasSearchButton = YES;
    }];
}

- (IBAction)action4:(id)sender {
    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Coach" title:@"我的学员" identifier:@"MyStudentListController"];
}

- (IBAction)action5:(id)sender {
    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Teach" title:@"评价管理" identifier:@"CommentListViewController" hideBackButton:NO completion:^(BaseNavController *controller) {
        CommentListViewController *vc = (CommentListViewController *)controller;
        vc.coachId = [LoginManager sharedManager].session.memberId;
        vc.starLevel = [LoginManager sharedManager].myDepositInfo.starLevel;
        vc.commentCount = (int)[LoginManager sharedManager].myDepositInfo.commentCount;
        vc.canReply = YES;
    }];
}

- (IBAction)action6:(id)sender {
    [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"Coach" title:@"" identifier:@"CoachDataListController"];
}


@end
