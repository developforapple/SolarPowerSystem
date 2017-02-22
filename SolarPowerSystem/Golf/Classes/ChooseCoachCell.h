//
//  ChooseCoachCell.h
//  Golf
//
//  Created by 黄希望 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeachingCoachModel.h"

@interface ChooseCoachCell : UITableViewCell

// 教练信息
@property (nonatomic,strong) TeachingCoachModel *teachingCoachModel;

// 回调
@property (nonatomic,copy) BlockReturn blockReturn;

// 课程类型，判断跳转流程
@property (nonatomic,assign) int classType;

@end
