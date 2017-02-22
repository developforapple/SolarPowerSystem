//
//  CourseDelayController.h
//  Golf
//
//  Created by 黄希望 on 15/6/3.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface CourseDelayController : BaseNavController

@property (nonatomic,strong) NSString *expiredDate;
@property (nonatomic,assign) int classId;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
