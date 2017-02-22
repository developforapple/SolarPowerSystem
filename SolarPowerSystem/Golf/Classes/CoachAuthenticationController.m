//
//  CoachAuthenticationController.m
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachAuthenticationController.h"
#import "YGCapabilityHelper.h"

@interface CoachAuthenticationController ()

@end

@implementation CoachAuthenticationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)zx:(id)sender{
    [[BaiduMobStat defaultStat] logEvent:@"btnApplyTeachingPhone" eventLabel:@"开通教练电话咨询按钮点击"];
    [MobClick event:@"btnApplyTeachingPhone" label:@"开通教练电话咨询按钮点击"];

    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
}

@end
