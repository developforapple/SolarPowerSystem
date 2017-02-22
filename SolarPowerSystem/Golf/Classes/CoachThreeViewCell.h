//
//  CoachThreeViewCell.h
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CoachThreeViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *todayOrderLabel;
@property (nonatomic,weak) IBOutlet UILabel *todayWaitTeachLabel;
@property (nonatomic,weak) IBOutlet UILabel *waitConfirmLabel;

@property (nonatomic,copy) BlockReturn blockReturn;

- (void)loadData;

@end
