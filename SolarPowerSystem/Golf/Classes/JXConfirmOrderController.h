//
//  JXConfirmOrderController.h
//  Golf
//
//  Created by 黄希望 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "TeachingCoachModel.h"

@interface JXConfirmOrderController : BaseNavController

@property (nonatomic,assign) int productId;
@property (nonatomic,assign) int publicClassId;
@property (nonatomic,strong) TeachingCoachModel *teachingCoach;
@property (nonatomic,strong) NSString *productName;
@property (nonatomic,assign) int sellingPrice;

@property (nonatomic,assign) int classHour; // 1为单课时 2.为多课时,支付必传；
@property (nonatomic,assign) int classType; // 课程类型
@property (nonatomic,assign) int academyId;
@property (nonatomic,copy) BlockReturn blockReturn;

@property (nonatomic,assign) int returnCash;

@end
