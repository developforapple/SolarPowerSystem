//
//  ClubOrderViewController.h
//  Golf
//
//  Created by 黄希望 on 14-8-14.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "OrderDetailModel.h"

@interface ClubOrderViewController : BaseNavController
@property (nonatomic,strong) OrderDetailModel *orderDetail;
@property (nonatomic) int orderId;
@property (nonatomic) BOOL isBackUp;

@property (nonatomic,copy) BlockReturn blockReturn;
@property (nonatomic) BOOL isInMineVC;//lyf 加，在"我的"进入付款，要跳会订场详情，而不是root
@end
