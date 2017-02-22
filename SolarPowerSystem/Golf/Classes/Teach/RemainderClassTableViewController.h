//
//  RemainderClassTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemainderClassTableViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) int coachId;
@property (strong, nonatomic) NSString *sessionId;

@property (nonatomic,copy) BlockReturn blockReturn;

@end
