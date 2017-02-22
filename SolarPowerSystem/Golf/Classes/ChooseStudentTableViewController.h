//
//  ChooseStudentTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseStudentTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ServiceManagerDelegate>

@property (nonatomic) int coachId;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *nextTime;
@property (strong, nonatomic) NSString *date;
@property (assign, nonatomic) int periodId; // 课时Id

@property (nonatomic,copy) BlockReturn blockReturn;

@end
