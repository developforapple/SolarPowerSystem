//
//  YGOrdersRecentListViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class YGOrderManager;

/**
 最近订单列表
 */
@interface YGOrdersRecentListViewCtrl : BaseNavController

@property (assign, nonatomic) NSInteger edgeInsetsTop;

- (void)reload:(YGOrderManager *)manager isMore:(BOOL)isMore;

@end
