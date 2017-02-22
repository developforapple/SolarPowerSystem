//
//  ClubListCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubListCell.h"

@interface ClubListCell()

@property (nonatomic,assign) BOOL isOfficial;
@property (nonatomic,assign) BOOL isVip;
@property (nonatomic,assign) int clubSpecialOffType;

@end

@implementation ClubListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_clubImageView radius:26 bordLineWidth:1 borderColor:[UIColor colorWithHexString:@"e6e6e6"]];
    [Utilities drawView:_fanYunbiLabel radius:2 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
    
    _officialFlag.hidden = YES;
    _vipFlag.hidden = YES;
    _specialPriceFlag.hidden = YES;
    _moneyMarkLabel1.hidden = YES;
    _moneyMarkLabel2.hidden = NO;
    _minPriceLabel1.hidden = YES;
    _minPriceLabel2.hidden = NO;
    _fanYunbiLabel.hidden = YES;
    _phoneBookFlag.hidden = YES;
    _alockFlag.hidden = YES;
    _specialPriceLabel.hidden = YES;
}

- (void)setClub:(ClubModel *)club{
    _club = club;
    
    if (club) {
        [_clubImageView sd_setImageWithURL:[NSURL URLWithString:club.clubImage] placeholderImage:[UIImage imageNamed:@"cgit_s.png"]];
        
        [_clubNameLabel setText:club.clubName.length>0?club.clubName:@""];
        [_clubTypeLabel setText:[NSString stringWithFormat:@"%@%d洞",club.courseKind,club.clubHoleNum]];
        [_shortAddressLabel setText:[NSString stringWithFormat:@"%@km %@",club.remote,club.shortAddress.length>0?club.shortAddress:@""]];
        [_minPriceLabel1 setText:[NSString stringWithFormat:@"%d",club.minPrice]];
        [_minPriceLabel2 setText:[NSString stringWithFormat:@"%d",club.minPrice]];
        
        [self specialPrice];
        [_specialPriceLabel setText:[NSString stringWithFormat:@"¥%d",club.timeMinPrice]];
        
        _isOfficial = club.isOfficial;
        _officialFlag.hidden = !_isOfficial;
        _isVip = club.payType == PayTypeVip;
        _vipFlag.hidden = !_isVip;
        
        NSInteger count = 0;
        for (NSLayoutConstraint *lc in _vipFlag.superview.constraints) {
            if (lc.firstAttribute == NSLayoutAttributeLeading && lc.firstItem == _vipFlag) {
                lc.constant = _isOfficial ? 5 : -14;
                count ++;
            }
            if (lc.firstAttribute == NSLayoutAttributeLeading && lc.firstItem == _specialPriceFlag) {
                if (_isVip) {
                    lc.constant = 5;
                }else{
                    lc.constant = -14;
                }
                count++;
            }
            if (count>=2) {
                [_specialPriceFlag.superview layoutIfNeeded];
                break;
            }
        }
        
        if (_clubSpecialOffType == 2) {
            _specialPriceFlag.hidden = NO;
            _alockFlag.hidden = YES;
            _specialPriceLabel.hidden = YES;
        }else if (_clubSpecialOffType == 1){
            _specialPriceFlag.hidden = YES;
            _alockFlag.hidden = NO;
            _specialPriceLabel.hidden = NO;
        }else{
            _specialPriceFlag.hidden = YES;
            _alockFlag.hidden = YES;
            _specialPriceLabel.hidden = YES;
        }
        
        if (club.giveYunbi>0 || club.closure == 1) { // 返云币/电话预订
            if (club.closure > 0) {
                _fanYunbiLabel.hidden = YES;
                _phoneBookFlag.hidden = NO;
                _specialPriceFlag.hidden = YES;
                _alockFlag.hidden = YES;
                _specialPriceLabel.hidden = YES;
            }else{
                _fanYunbiLabel.hidden = club.giveYunbi>0? NO : YES;
                _phoneBookFlag.hidden = YES;
            }

            [_fanYunbiLabel setText:[NSString stringWithFormat:@" 返%d ",club.giveYunbi]];
            _minPriceLabel1.hidden = NO;
            _minPriceLabel2.hidden = YES;
        }else{
            _fanYunbiLabel.hidden = YES;
            _phoneBookFlag.hidden = YES;
            [_fanYunbiLabel setText:@""];
            
            _minPriceLabel1.hidden = YES;
            _minPriceLabel2.hidden = NO;
        }
        
        _moneyMarkLabel1.hidden = _minPriceLabel1.hidden;
        _moneyMarkLabel2.hidden = _minPriceLabel2.hidden;
        
        if (club.closure > 1) { //已封场
            _moneyMarkLabel1.hidden = YES;
            _moneyMarkLabel2.hidden = YES;
            _minPriceLabel1.hidden = YES;
            _minPriceLabel2.hidden = NO;
            _minPriceLabel2.text = @"已封场";
            _phoneBookFlag.hidden = YES;
            _fanYunbiLabel.hidden = YES;
            _specialPriceFlag.hidden = YES;
            _alockFlag.hidden = YES;
            _specialPriceLabel.hidden = YES;
        }
    }
}

- (void)specialPrice{
    _clubSpecialOffType = 0;
    if (_club.timeMinPrice>= 0 && _club.startTime.length > 0 && _club.endTime.length > 0) {
        BOOL isSpecialPrice = [Utilities compareTimeWithCurrentTime:_cm.time beginTime:_club.startTime endTime:_club.endTime];
        _clubSpecialOffType = isSpecialPrice ? 2 : 1;
    }
}

@end
