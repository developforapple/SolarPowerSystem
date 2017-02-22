//
//  ClubCommentCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubCommentCell.h"
#import "CmtStars.h"
#import "CommentModel.h"

@interface ClubCommentCell()

@property (nonatomic,weak) IBOutlet UIImageView *headImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *levelImage;
@property (nonatomic,weak) IBOutlet UILabel *cmtTimeLabel;
@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *stars;
@property (nonatomic,weak) IBOutlet UILabel *detailLabel;
@property (nonatomic,weak) IBOutlet UILabel *cmtContentLabel;

@end

@implementation ClubCommentCell

- (void)setCm:(CommentModel *)cm{
    _cm = cm;
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:_cm.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
    [_nameLabel setText:_cm.displayName.length>0?_cm.displayName:@" "];
    _levelImage.image = [Utilities imageOfUserType:_cm.memberLevel];
    [_cmtTimeLabel setText:[Utilities getDateStringFromString:_cm.commentDate WithAllFormatter:@"yyyy-MM-dd"]];
    [_detailLabel setText:[NSString stringWithFormat:@"设计%d  草坪%d  设施%d  服务%d",_cm.difficultyLevel,_cm.grassLevel,_cm.sceneryLevel,_cm.serviceLevel]];
    
    if (_cm.commentContent.length>0) {
        [_cmtContentLabel setText:_cm.commentContent];
//        NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
//        mps.lineSpacing = 5;
//        NSAttributedString *att = [[NSAttributedString alloc] initWithString:_cm.commentContent attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:mps}];
//        [_cmtContentLabel setAttributedText:att];
    }else{
        //[_cmtContentLabel setAttributedText:nil];
        [_cmtContentLabel setText:@""];
    }
    
    [CmtStars setStars:_stars cmtLevel:_cm.totalLevel large:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (CGRectContainsPoint(_headImageView.frame, pt) || CGRectContainsPoint(_nameLabel.frame, pt)) {
        if (_blockReturn) {
            _blockReturn (_cm);
        }
    }
}

@end
