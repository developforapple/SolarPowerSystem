//
//  PublicCourseHomeController.h
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "MJRefresh.h"
#import "PublicCourseCell.h"

@interface PublicCourseHomeController : BaseNavController

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) int cityId;
@property (nonatomic,assign) BOOL isMore;
@property (nonatomic,assign) BOOL isSearch;

- (void)initization;
- (void)loadDataPageNo:(int)page;

@end
