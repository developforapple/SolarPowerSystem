//
//  TeachingOrderDetailViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachingOrderDetailViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) int classId;
@property (nonatomic) int orderId;

@property (copy, nonatomic) BlockReturn blockRefresh;
@property (copy, nonatomic) BlockReturn blockReturn;

@property (nonatomic,assign) BOOL isCoach; // 是否为教练
@end
