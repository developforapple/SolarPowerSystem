//
//  YGWalletTopUpPlatformViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 14-5-6.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

/**
 充值选择平台
 */
@interface YGWalletTopUpPlatformViewCtrl : BaseNavController

@property (nonatomic) int chargeAmount;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
