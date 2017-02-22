//
//  TeetimeListCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/26.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TeetimeListCell.h"

@interface TeetimeListCell()

@property (nonatomic,weak) IBOutlet UILabel *clubNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *courseLabel;
@property (nonatomic,weak) IBOutlet UILabel *priceContentLabel;
@property (nonatomic,weak) IBOutlet UILabel *remainPeopleLabel;
@property (nonatomic,weak) IBOutlet UIImageView *officalImgFlag;
@property (nonatomic,weak) IBOutlet UIImageView *specialImgFlag;
@property (nonatomic,weak) IBOutlet UILabel *price1Label;
@property (nonatomic,weak) IBOutlet UILabel *price2Label;
@property (nonatomic,weak) IBOutlet UILabel *moneyMark1;
@property (nonatomic,weak) IBOutlet UILabel *moneyMark2;
@property (nonatomic,weak) IBOutlet UILabel *yunbiLabel;
@property (nonatomic,weak) IBOutlet UIButton *bookBtn;
@property (nonatomic,weak) IBOutlet UILabel *shishiLabel;//实时
@property (nonatomic,weak) IBOutlet UIImageView *recommentFlag;


@end

@implementation TeetimeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_yunbiLabel radius:2 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
    [Utilities drawView:_shishiLabel radius:2 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
    [_clubNameLabel setText:@""];
    [_courseLabel setText:@""];
    [_priceContentLabel setText:@""];
    [_remainPeopleLabel setText:@""];
    _officalImgFlag.hidden = YES;
    _specialImgFlag.hidden = YES;
    [_price1Label setText:@""];
    [_price2Label setText:@""];
    _moneyMark1.hidden = YES;
    _moneyMark2.hidden = YES;
    [_yunbiLabel setText:@""];
    _bookBtn.hidden = YES;
}

- (IBAction)bookAction:(id)sender{
    if (_bookBlock) {
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:nil controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:^(id data) {
                _bookBlock (_ttm);
            }];
            return;
        }
        _bookBlock (_ttm);
    }
}

- (void)setTtm:(TTModel *)ttm{
    _ttm = ttm;
    [_clubNameLabel setText:_ttm.agentId>0?_ttm.agentName:@"球场直销"];
    if (_ttm.agentId == 0) {
        if (_shishiLabel) _shishiLabel.hidden = NO;
        _officalImgFlag.hidden = NO;
        [_courseLabel setText:[NSString stringWithFormat:@"%@ %@",_ttm.teetime,_ttm.courseName]];
        [_remainPeopleLabel setText:[NSString stringWithFormat:@"剩%d位",_ttm.mans]];
    }else{
        if (_shishiLabel) _shishiLabel.hidden = YES;
        _officalImgFlag.hidden = YES;
        if (_courseLabel) _courseLabel.text = @"";
        if (_remainPeopleLabel) _remainPeopleLabel.text = @"";
    }
    [_priceContentLabel setText:_ttm.priceContent];
    
    _specialImgFlag.hidden = _clubSpecialOffType == 2 && _timeMinPrice==_ttm.price ? NO : YES;
    
    for (NSLayoutConstraint *lc in _specialImgFlag.superview.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeLeading && lc.firstItem == _specialImgFlag) {
            lc.constant = _ttm.agentId == 0 ? 5 : -14;
            [_specialImgFlag.superview layoutIfNeeded];
        }
        if (lc.firstAttribute == NSLayoutAttributeLeading && lc.firstItem == _shishiLabel) {
            lc.constant = _specialImgFlag.hidden ? -26 : 5;
            [_specialImgFlag.superview layoutIfNeeded];
        }
    }
    
    
    if (_ttm.yunbi>0) {
        _moneyMark1.hidden = NO;
        _moneyMark2.hidden = YES;
        _price1Label.hidden = NO;
        _price2Label.hidden = YES;
        [_price1Label setText:[NSString stringWithFormat:@"%d", _specialImgFlag.hidden == NO?_timeMinPrice:_ttm.price]];
        [_yunbiLabel setText:[NSString stringWithFormat:@" 返%d ",_ttm.yunbi]];
    }else{
        _moneyMark1.hidden = YES;
        _moneyMark2.hidden = NO;
        _price1Label.hidden = YES;
        _price2Label.hidden = NO;
        [_price2Label setText:[NSString stringWithFormat:@"%d",_specialImgFlag.hidden == NO?_timeMinPrice:_ttm.price]];
        _yunbiLabel.hidden = YES;
    }
    _bookBtn.hidden = NO;
    [_bookBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_bookteetime_%d",_ttm.payType]] forState:UIControlStateNormal];
    
    _recommentFlag.hidden = !_ttm.recommendFlag;
    
    if (_ttm.agentId<0) {
        [_clubNameLabel setText:_ttm.agentName];
        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"btn_bookteetime_0"] forState:UIControlStateNormal];
        for (NSLayoutConstraint *lc in _bookBtn.constraints) {
            if (lc.firstAttribute == NSLayoutAttributeHeight) {
                lc.constant = 27;
            }
        }
    }else{
        for (NSLayoutConstraint *lc in _bookBtn.constraints) {
            if (lc.firstAttribute == NSLayoutAttributeHeight) {
                lc.constant = 44;
            }
        }
    }
}


@end
