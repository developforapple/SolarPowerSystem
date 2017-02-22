//
//  TeachInfoDetailTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReservationModel.h"

@interface TeachInfoDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;

@property (copy,nonatomic) BlockReturn blockReturn;
@property (copy,nonatomic) BlockReturn blockImagePressed;

- (void)loadData:(ReservationModel *)rm;

@end
