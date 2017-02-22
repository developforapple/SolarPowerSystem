//
//  CoachBaseInfoController.h
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "CoachBaseinfo.h"

@interface CoachBaseInfoController : BaseNavController

@property (nonatomic,strong) CoachBaseinfo *baseInfo; // 教练的基本信息
@property (nonatomic,copy) BlockReturn blockReturn;

@end
