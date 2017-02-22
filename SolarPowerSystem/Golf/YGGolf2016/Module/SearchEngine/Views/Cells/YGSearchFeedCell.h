//
//  YGSearchFeedCell.h
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchBaseCell.h"

@class YYLabel;

@interface YGSearchFeedCell : YGSearchBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;//用户头像

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet YYLabel *locationLabel;    //位置信息

@property (weak, nonatomic) IBOutlet YYLabel *contentLabel;     //主内容
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;//主内容高

//多图区域
@property (weak, nonatomic) IBOutlet UIView *multiImagePanel;
// 以tag进行排序，而不是以连线顺序排序 tag 从 100 开始递增
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;  //图片数量Label

//分享区域
@property (weak, nonatomic) IBOutlet UIView *sharePanel;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView; //分享的小图标
@property (weak, nonatomic) IBOutlet YYLabel *shareContentLabel;  //分享内容


@property (weak, nonatomic) IBOutlet UIView *imagePandel;       //单图区域
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;//单图宽
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;//单图高
@property (weak, nonatomic) IBOutlet UIImageView *singleImageView;  //单图
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;    //视频播放icon

@end
