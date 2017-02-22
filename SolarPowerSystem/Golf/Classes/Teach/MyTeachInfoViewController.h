//
//  MyTeachInfoViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTeachInfoViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,copy) BlockReturn blockReturn;

@end
