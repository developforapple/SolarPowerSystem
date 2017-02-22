//
//  TimetableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeachingService.h"

@interface TimetableViewController : BaseNavController

// 教练Id
@property (nonatomic) int coachId;
// 回调
@property (nonatomic,copy) BlockReturn blockReturn;

// 从课程详情过来，帮用户预约课时
@property (strong, nonatomic)TeachingMemberClassInfoBean *classInfoBean;
// 从课时详情过来，帮用户预约课时
@property (strong, nonatomic)TeachingMemberClassPeriodBean *periodBean;


@end
