//
//  MyScheduleTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyScheduleTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *timeSet;
@property (nonatomic) int coachId;
@property (nonatomic,copy) BlockReturn blockReturn;
@end
