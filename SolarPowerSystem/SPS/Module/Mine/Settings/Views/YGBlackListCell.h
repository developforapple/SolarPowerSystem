//
//  YGBlackListCell.h
//  Golf
//
//  Created by zhengxi on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserFollowModel;

@interface YGBlackListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) void (^removeBackBlock) (void);
@property (strong, nonatomic) UserFollowModel *model;
@property (nonatomic) int willOperation;
@end
