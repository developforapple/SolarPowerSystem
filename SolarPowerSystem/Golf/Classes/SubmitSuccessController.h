//
//  SubmitSuccessController.h
//  Golf
//
//  Created by 黄希望 on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface SubmitSuccessController : BaseNavController

@property (nonatomic,assign) int orderId;
@property (nonatomic,assign) BOOL isFromPay;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
