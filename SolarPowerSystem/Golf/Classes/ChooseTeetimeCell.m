//
//  ChooseTeetimeCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/29.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ChooseTeetimeCell.h"

@interface ChooseTeetimeCell ()

@property (nonatomic,weak) IBOutlet UILabel *teetimeLabel;
@property (nonatomic,weak) IBOutlet UILabel *remainMansLabel;
@property (nonatomic,weak) IBOutlet UILabel *priceLabel;
@property (nonatomic,weak) IBOutlet UILabel *yunbiLabel;
@property (nonatomic,weak) IBOutlet UIButton *bookBtn;

@end

@implementation ChooseTeetimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_yunbiLabel radius:2 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
}

- (IBAction)bookTeetimeAction:(id)sender{
    if (_bookBlock) {
        _bookBlock (_ttm);
    }
}

- (void)setTtm:(TTModel *)ttm{
    _ttm = ttm;
    if (_ttm) {
        if (_isSpree) {
            [_teetimeLabel setText:[NSString stringWithFormat:@"%@",_ttm.teetime]];
            [_remainMansLabel setText:@""];
            [_priceLabel setText:@""];
            [_yunbiLabel setText:@""];
        }else{
            [_teetimeLabel setText:[NSString stringWithFormat:@"%@ %@",_ttm.teetime,_ttm.courseName]];
            [_remainMansLabel setText:[NSString stringWithFormat:@"剩%d位",_ttm.mans]];
            [_priceLabel setText:[NSString stringWithFormat:@"%d",_ttm.price]];
            if (_ttm.yunbi>0) {
                [_yunbiLabel setText:[NSString stringWithFormat:@" 返%d ",_ttm.yunbi]];
            }else{
                [_yunbiLabel setText:@""];
            }
            
            for (NSLayoutConstraint *lc in _priceLabel.superview.constraints) {
                if (lc.firstAttribute == NSLayoutAttributeTop && lc.firstItem == _priceLabel) {
                    lc.constant = _ttm.yunbi > 0 ? 5 : 12;
                    [_priceLabel.superview layoutIfNeeded];
                    break;
                }
            }
        }
    }
}

@end
