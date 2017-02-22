//
//  CourseSchoolTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseSchoolTableViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) int cityId;

@property (copy,nonatomic) BlockReturn blockCancel;
@property (nonatomic,assign) BOOL hasSearchButton;
@property (nonatomic,assign) BOOL isSearchViewController;

@end
