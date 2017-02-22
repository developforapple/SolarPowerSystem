//
//  YGMineCell.h
//  Golf
//
//  Created by zhengxi on 15/12/7.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13BadgeView.h"
#import "IMSession.h"

@interface YGMineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *yunbiBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponBadgeLabel;
@property (weak, nonatomic) IBOutlet UIButton *levelButton;
@property (weak, nonatomic) IBOutlet UIButton *coachLevelButton;

@property (nonatomic) BOOL isFirstCell;
@property (nonatomic) int msgCount;
@property (nonatomic) BOOL redPointAboutFriends;


@property (strong, nonatomic) void (^toUserGuideBlock) (void);
@property (strong, nonatomic) void (^toCoachGuideBlock) (void);
@property (strong, nonatomic) void (^toAccountBlock) (NSInteger);

@property (nonatomic,copy)BlockReturn blockFriend;

@end
