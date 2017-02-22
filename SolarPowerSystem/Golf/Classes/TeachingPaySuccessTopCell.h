//
//  TeachingPaySuccessTopCell.h
//  Golf
//
//  Created by 黄希望 on 15/7/31.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachingPaySuccessTopCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *coachTimeLabel;
@property (nonatomic,copy) BlockReturn reserveAction;

@end
