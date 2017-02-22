//
//  JXChooseTimeController.h
//  Golf
//
//  Created by 黄希望 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "TeachingCoachModel.h"

@interface JXChooseTimeController : BaseNavController

@property (nonatomic,strong) TeachingCoachModel *teachingCoach;
@property (nonatomic,assign) int productId;
@property (nonatomic,strong) NSString *productName;
@property (nonatomic,assign) int sellingPrice;
@property (nonatomic,assign) int publicClassId;
@property (nonatomic,assign) int classHour;
@property (nonatomic,assign) int classNo; // 仅团课要传，上面的必传
@property (nonatomic,assign) int remainHour;// 剩余课时
@property (nonatomic,assign) int classId; // 多课时付款成功立即预约需传
@property (nonatomic,assign) int periodId; // 课时Id
@property (nonatomic,assign) int classType; // 课程类型
@property (nonatomic,assign) int academyId;

@property (nonatomic,assign) int returnCash;

@property (nonatomic, copy) BlockReturn blockReturn;

@end
