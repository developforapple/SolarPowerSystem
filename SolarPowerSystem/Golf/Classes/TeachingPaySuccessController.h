//
//  TeachingPaySuccessController.h
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface TeachingPaySuccessController : BaseNavController

@property (nonatomic,assign) int orderId;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
