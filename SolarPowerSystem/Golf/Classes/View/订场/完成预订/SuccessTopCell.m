//
//  SuccessTopCell.m
//  Golf
//
//  Created by 黄希望 on 15/7/30.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "SuccessTopCell.h"

@implementation SuccessTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _bgImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_ppline_blue"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
