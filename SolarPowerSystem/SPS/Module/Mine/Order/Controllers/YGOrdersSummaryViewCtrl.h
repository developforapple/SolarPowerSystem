//
//  YGOrdersSummaryViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class YGOrderManager;

/**
 全部订单概要
 */
@interface YGOrdersSummaryViewCtrl : BaseNavController

@property (assign, nonatomic) NSInteger edgeInsetsTop;

- (void)reload:(YGOrderManager *)manager;

@end
