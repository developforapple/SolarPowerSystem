//
//  CoachTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeachingCoachModel.h"

@interface CoachTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (nonatomic) BOOL isHeaderView;//是否用做顶部视图，个人详情页

@property (nonatomic, copy) BlockReturn blockAuthenticationPressed;
@property (nonatomic, copy) BlockReturn blockReturn;
@property (strong, nonatomic) TeachingCoachModel *tcm;

- (void)loadData:(TeachingCoachModel *)tcm;

@end
