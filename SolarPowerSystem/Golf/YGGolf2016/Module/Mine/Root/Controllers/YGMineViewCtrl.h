//
//  YGMineViewCtrl.h
//  Golf
//
//  Created by zhengxi on 15/12/7.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGMineViewCtrl : BaseNavController
@property (nonatomic) int badgeNum;
@property (strong, nonatomic) UIImageView *badgeImage;

- (void)refreshBadgeValue;
- (void)toChatListViewController;

@end
