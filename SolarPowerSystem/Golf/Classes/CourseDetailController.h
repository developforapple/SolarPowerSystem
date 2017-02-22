//
//  CourseDetailController.h
//  Golf
//
//  Created by 黄希望 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "ActivityModel.h"

@interface CourseDetailController : BaseNavController

@property (nonatomic,strong) NSString *courseName;
@property (nonatomic,strong) NSString *courseUrl;
@property (nonatomic,strong) NSString *courseIntro;
@property (nonatomic,strong) NSString *courseImage;

@property (nonatomic,assign) int productId;

@end
