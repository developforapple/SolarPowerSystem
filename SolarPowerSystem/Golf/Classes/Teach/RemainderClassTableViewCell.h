//
//  RemainderClassTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RemainderClassTableViewCell : UITableViewCell

@property (copy, nonatomic) BlockReturn blockReturn;

// 点击头像回调
@property (strong, nonatomic) void(^headBtnHeadTapBlock)(id m);


- (void)loadData:(id)data;

@end
