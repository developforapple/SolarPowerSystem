//
//  JXRecordSearchController.h
//  Golf
//
//  Created by 黄希望 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXRecordSearchController : UITableViewController

@property (nonatomic,strong) NSMutableArray *recordList;
@property (nonatomic,copy) void (^completion)(id obj);
@property (nonatomic,copy) void (^clearCompletion)(void);
@property (nonatomic,strong) NSString *cacheName;

@property (nonatomic,copy) void (^hide)(JXRecordSearchController *jx);
@property (nonatomic,copy) void (^disappearKeyboard)(void);

@end
