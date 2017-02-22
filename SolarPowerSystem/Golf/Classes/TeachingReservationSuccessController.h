//
//  TeachingReservationSuccessController.h
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "TeachProductDetail.h"
#import "TeachingCoachModel.h"

@interface TeachingReservationSuccessController : BaseNavController

@property (nonatomic,strong) TeachingCoachModel *teachingCoachModel;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,assign) int productId;

@property (nonatomic,assign) int orderId;
@property (nonatomic,strong) BlockReturn blockReturn;

@end
