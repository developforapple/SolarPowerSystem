//
//  ChooseCoachListController.h
//  Golf
//
//  Created by 黄希望 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface ChooseCoachListController : BaseNavController

@property (nonatomic,assign) int productId ; // 产品id
@property (nonatomic,assign) int publicClassId;
@property (nonatomic,assign) int cityId; // 城市id
@property (nonatomic,assign) int classNo;

@end
