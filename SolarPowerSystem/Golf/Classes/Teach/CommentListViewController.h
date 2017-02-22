//
//  CommentListViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface CommentListViewController : ChatViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) int coachId;
@property (nonatomic) int productId;
@property (nonatomic) int commentCount;
@property (nonatomic) float starLevel;

@property (nonatomic) BOOL canReply; //是否可以回复，教练进入就可以

@end
