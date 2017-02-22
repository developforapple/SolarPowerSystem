//
//  CoachReservatListController.h
//  Golf
//
//  Created by 黄希望 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface CoachReservatListController : BaseNavController

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,strong) NSString *term;
@property (nonatomic,assign) BOOL isSearch;

- (void)loadDataPageNo:(int)page;

@end
