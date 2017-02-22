//
//  CourseCommentCell.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseCommentCell.h"
#import "TopicHelp.h"

@implementation CourseCommentCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [Utilities drawView:self.headImageV radius:20 bordLineWidth:0 borderColor:[Utilities R:240 G:240 B:240]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self.headImageV addGestureRecognizer:tap];
}

- (void)setCommentModel:(CoachDetailCommentModel *)commentModel{
    if (!commentModel) {
        return;
    }
    _commentModel = commentModel;
    [_headImageV sd_setImageWithURL:[NSURL URLWithString:_commentModel.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
    if (_commentModel.displayName.length>0) {
        [_memberNameLabel setText:_commentModel.displayName];
    }
    if (_commentModel.commentContent.length>0) {
        [_commentContentLabel setText:_commentModel.commentContent];
    }
    if (_commentModel.commentTime.length>0) {
        [_commentTimeLabel setText:_commentModel.commentTime];
    }
    [_memberLevelBtn setBackgroundImage:[Utilities imageOfUserType:_commentModel.memberRank] forState:UIControlStateNormal];
    
    for (NSLayoutConstraint *c  in [_yellowStarV constraints]) {
        if (c.firstAttribute == NSLayoutAttributeWidth) {
            c.constant = [self starLevel:_commentModel.starLevel];
            [self layoutIfNeeded];
            break;
        }
    }
}

- (void)tapClick:(UITapGestureRecognizer*)tap{    
    [[GolfAppDelegate shareAppDelegate].currentController toPersonalHomeControllerByMemberId:_commentModel.memberId displayName:_commentModel.displayName target:[GolfAppDelegate shareAppDelegate].currentController];
    
}

//设置星星级别  //浦发红酒300176
- (CGFloat)starLevel:(float)starLevel{
    return 80.0/5 * starLevel;
}

@end
