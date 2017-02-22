//
//  TeachingOrderTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeachingOrderModel.h"

@interface TeachingOrderTableViewCell : UITableViewCell

@property (copy,nonatomic) BlockReturn blockReturn;

- (void)loadData:(TeachingOrderModel *)data isCoach:(BOOL)isCoach;
@end
