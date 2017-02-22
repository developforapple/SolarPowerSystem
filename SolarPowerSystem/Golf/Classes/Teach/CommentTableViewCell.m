//
//  CommentTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIView+AutoLayout.h"
#import "CoachDetailCommentModel.h"


@interface CommentTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelFrom;
@end;

@implementation CommentTableViewCell{
    CoachDetailCommentModel *ccm;
}
- (IBAction)toHomePage:(id)sender {
    if (_blockReturn) {
        _blockReturn(ccm);
    }
}
- (IBAction)btnFromPressed:(id)sender {
    if (_blockFromPressed) {
        _blockFromPressed(ccm);
    }
}

- (IBAction)btnReplyPressed:(id)sender {
    if (_blockReplyPressed) {
        _blockReplyPressed(@{@"el":sender,@"data":ccm});
    }
}

-(void)loadData:(CoachDetailCommentModel *)cdc{
    ccm = cdc;
    if (cdc) {
        [_imgHeader sd_setImageWithURL:[NSURL URLWithString:cdc.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
        [_labelName setText:cdc.displayName];
        [_labelDate setText:cdc.commentTime];
        [_labelComment setText:cdc.commentContent];
        if (cdc.replyContent.length > 0) {
            [_labelReply setText:[NSString stringWithFormat:@"[回复] %@",cdc.replyContent]];
        }
        
        _labelFrom.hidden = YES;
        if ((cdc.reservationDate && [cdc.reservationDate length] > 0) || (cdc.reservationTime && [cdc.reservationTime length] > 0)) {
            
            _labelFrom.hidden = NO;
            UIColor *c666666 = [UIColor colorWithHexString:@"#666666"];
            UIFont *size12 = [UIFont systemFontOfSize:12.0];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"分享" attributes:@{NSFontAttributeName:size12,NSForegroundColorAttributeName:c666666}];
            NSString *date = cdc.reservationDate ? cdc.reservationDate : @"";
            NSString *time = cdc.reservationTime ? cdc.reservationTime : @"";
            if (Device_Width == 320.0 && cdc.reservationDate.length > 6) {
                date = [date substringFromIndex:5];
            }
            [str appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ %@ ",date,time]  attributes:@{NSFontAttributeName:size12,NSForegroundColorAttributeName:MainHighlightColor}]];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"的教学" attributes:@{NSFontAttributeName:size12,NSForegroundColorAttributeName:c666666}]];
            [_labelFrom setAttributedText:str];
        }

        [self starLevel:cdc.starLevel];
    }
}

//设置星星级别  //浦发红酒300176
- (void)starLevel:(int)starLevel{
    CGFloat width = 80.0/5 * starLevel;
    BOOL flag = YES;
    for (NSLayoutConstraint *c  in [_imgStar constraints]) {
        if (c.firstAttribute == NSLayoutAttributeWidth) {
            c.constant = width;
            [_imgStar layoutIfNeeded];
            flag = NO;
            break;
        }
    }
    if (flag) { //标记是否有设置width约束，如果没有则设置
        [_imgStar constrainToWidth:width];
        [_imgStar layoutIfNeeded];
    }
}


@end
