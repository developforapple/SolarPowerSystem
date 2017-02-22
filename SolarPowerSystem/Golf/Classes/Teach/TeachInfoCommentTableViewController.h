//
//  TeachInfoCommentTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachInfoCommentTableViewController : UITableViewController

// 预约Id
@property (assign,nonatomic) int reservationId;
// 回调
@property (copy, nonatomic) BlockReturn blockReturn;
// 评价内容数据
@property (nonatomic,strong) NSMutableDictionary *data;
// 课程Id
@property (assign, nonatomic) int classId;

@end
