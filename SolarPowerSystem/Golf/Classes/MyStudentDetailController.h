//
//  MyStudentDetailController.h
//  Golf
//
//  Created by 黄希望 on 15/6/5.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface MyStudentDetailController : BaseNavController

@property (nonatomic,assign) int memberId;
@property (nonatomic,strong) StudentModel *student;

@end
