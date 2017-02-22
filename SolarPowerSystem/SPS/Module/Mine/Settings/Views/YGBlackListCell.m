//
//  YGBlackListCell.m
//  Golf
//
//  Created by zhengxi on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGBlackListCell.h"

@implementation YGBlackListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.removeButton.layer.borderColor = [UIColor colorWithRed:85/255.f green:192/255.f blue:234/255.f alpha:1].CGColor;
}

- (void)setModel:(UserFollowModel *)model {
    _model = model;
    [self freshenUI];
}

- (void)freshenUI {
    self.nameLabel.text = _model.displayName;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:_model.headImage] placeholderImage:[UIImage imageNamed:@"head_image.png"]];
    if (_willOperation == 6) {
        self.followLabel.text = @"屏蔽时间：";
    } else if (_willOperation == 7) {
        self.followLabel.text = @"拉黑时间：";
    }
    self.timeLabel.text = _model.followTime;
}

- (IBAction)clickedrRemoveButton:(id)sender {
    if (self.removeBackBlock) {
        self.removeBackBlock();
    }
}
@end
