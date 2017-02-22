//
//  CoachNoticeCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachNoticeCell.h"

@implementation CoachNoticeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_headImageV radius:19.5 bordLineWidth:0 borderColor:[UIColor whiteColor]];
}

- (void)setCnm:(CoachNoticeModel *)cnm{
    _cnm = cnm;
    if (_cnm) {
        if (_cnm.msgType == 4) {
            _noticeLabel2.numberOfLines = 0;
        }else{
            _noticeLabel2.numberOfLines = 1;
        }
        _noticeTitleLabel.text = [self titleWithIndex:_cnm.msgType];
        _noticeTimeLabel.text = _cnm.msgTime;
        [_headImageV sd_setImageWithURL:[NSURL URLWithString:_cnm.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];

        _noticeLabel1.text = _cnm.displayName.length>0 ? _cnm.displayName : @"";
        _noticeLabel2.text = _cnm.valueOne.length>0 ? _cnm.valueOne : @"";
        _noticeLabel3.text = _cnm.valueTwo.length>0 ? _cnm.valueTwo : @"";
    }
}

- (NSString*)titleWithIndex:(int)index{
    if (index == 1) {
        return @"订单已付款";
    }else if (index == 2){
        return @"新的预约";
    }else if (index == 3){
        return @"取消预约";
    }else if (index == 4){
        return @"新的评价";
    }
    return @"";
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (CGRectContainsPoint(_headImageV.frame, pt)){
        if (_blockReturn) {
            _blockReturn (@(0));
        }
    }else{
        if (_blockReturn) {
            _blockReturn (@(_cnm.msgType));
        }
    }
}

@end
