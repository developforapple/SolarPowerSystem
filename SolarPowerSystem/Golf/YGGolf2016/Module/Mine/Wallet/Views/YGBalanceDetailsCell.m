//
//  YGBalanceDetailsCell.m
//  Golf
//
//  Created by zhengxi on 15/12/11.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGBalanceDetailsCell.h"
#import "Utilities.h"

@interface YGBalanceDetailsCell ()
@property (nonatomic,strong) IBOutlet UILabel *yunbiNumLabel;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;

@end

@implementation YGBalanceDetailsCell

- (void)setModel:(ConsumeModel *)model {
    _model = model;
    self.nameLabel.text = [NSString stringWithFormat:@"%@  %@",_model.tranName,_model.description];
    self.dateLabel.text = [Utilities getDateStringFromString:_model.tranTime WithAllFormatter:@"yyyy-MM-dd HH:mm"];
    if (_model.relativeType>0 && _model.relativeId > 0) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    if (_model.tranAmount >= 0) {
        self.yunbiNumLabel.text = [NSString stringWithFormat:@"+%d", _model.tranAmount];
        self.yunbiNumLabel.textColor = [UIColor colorWithHexString:@"3dd9c1"];
    } else {
        self.yunbiNumLabel.text = [NSString stringWithFormat:@"%d", _model.tranAmount];
        self.yunbiNumLabel.textColor = [UIColor colorWithHexString:@"#ee6867"];
    }
    
    if (_model.relativeId == 0) {
        self.userInteractionEnabled = NO;
    } else {
        self.userInteractionEnabled = YES;
    }
}
@end
