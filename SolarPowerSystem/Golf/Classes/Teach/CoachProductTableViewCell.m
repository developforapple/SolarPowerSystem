//
//  CoachProductTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachProductTableViewCell.h"

@implementation CoachProductTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _labelFanxian.layer.borderColor = [UIColor colorWithHexString:@"#ff6d00"].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (IBAction)buy:(id)sender {
    if (_blockReturn) {
        _blockReturn(_tpd);
    }
}

@end
