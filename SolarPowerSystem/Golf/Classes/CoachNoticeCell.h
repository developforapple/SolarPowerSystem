//
//  CoachNoticeCell.h
//  Golf
//
//  Created by 黄希望 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachNoticeCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *noticeTitleLabel;
@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *noticeTimeLabel;
@property (nonatomic,weak) IBOutlet UILabel *noticeLabel1;
@property (nonatomic,weak) IBOutlet UILabel *noticeLabel2;
@property (nonatomic,weak) IBOutlet UILabel *noticeLabel3;

@property (nonatomic,strong) CoachNoticeModel *cnm;

@property (nonatomic,copy) BlockReturn blockReturn;

@end
