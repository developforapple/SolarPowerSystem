//
//  OrderSuccessViewController.h
//  Golf
//
//  Created by 黄希望 on 12-8-1.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "OrderDetailModel.h"
#import "ConditionModel.h"
#import "TeeTimeModel.h"
#import "TeeTimeAgentModel.h"
#import "OrderSubmitModel.h"
#import "BaseNavController.h"

@interface OrderSuccessViewController : BaseNavController{
    ConditionModel *_myCondition;
    OrderDetailModel *_myOrder;
}

@property (nonatomic,strong) ConditionModel *myCondition;
@property (nonatomic,strong) OrderDetailModel *myOrder;
@property (nonatomic) int orderId;

@end
