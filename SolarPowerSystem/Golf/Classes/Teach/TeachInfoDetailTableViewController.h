//
//  TeachInfoDetailTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface TeachInfoDetailTableViewController : ChatViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) int reservationId;
@property (nonatomic) int coachId;
@property (copy, nonatomic) BlockReturn blockCanceled;
@property (copy, nonatomic) BlockReturn blockReturn;
@property (copy, nonatomic) BlockReturn blockRefresh;
@property (nonatomic,assign) BOOL plsBack;//yes表示直接回到上一级controller

@end
