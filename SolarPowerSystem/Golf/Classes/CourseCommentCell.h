//
//  CourseCommentCell.h
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachDetailCommentModel.h"

// *********** 公开课详情评论cell ************* //
@interface CourseCommentCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *memberNameLabel;
@property (nonatomic,weak) IBOutlet UIButton *memberLevelBtn;
@property (nonatomic,weak) IBOutlet UILabel *commentTimeLabel;
@property (nonatomic,weak) IBOutlet UILabel *commentContentLabel;
@property (nonatomic,weak) IBOutlet UIImageView *yellowStarV;

@property (nonatomic,strong) CoachDetailCommentModel *commentModel;

- (CGFloat)starLevel:(float)starLevel;

@end
