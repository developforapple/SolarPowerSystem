//
//  TeachingOrderListViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachingOrderListViewController : BaseNavController<UITableViewDelegate,UITableViewDataSource>

@property (copy, nonatomic) BlockReturn blockRefresh;
@property (nonatomic) int coachId;
@property (nonatomic,assign) BOOL hasSearchButton;
@property (nonatomic,assign) BOOL isSearchViewController;
@property (nonatomic,assign) BOOL canSlide;
@property (copy,nonatomic) BlockReturn blockCancel;

@end
