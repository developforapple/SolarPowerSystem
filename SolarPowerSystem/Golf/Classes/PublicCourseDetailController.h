//
//  PublicCourseDetailController.h
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface PublicCourseDetailController : BaseNavController

@property (nonatomic,assign) int publicClassId;
@property (nonatomic,assign) int productId;
@property (nonatomic,copy) BlockReturn blockRefresh;

@end
