//
//  TeachingRecordCell.h
//  Golf
//
//  Created by 黄希望 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachingRecordCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic,weak) IBOutlet UILabel *teachingStatusLabel;
@property (nonatomic,weak) IBOutlet UIButton *teachingBtn;

@property (nonatomic,copy) BlockReturn blockReturn;

@property (nonatomic,strong) ReservationModel *rm;

@end
