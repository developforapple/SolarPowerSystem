//
//  ClubRushPurchaseCell_Will.m
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubRushPurchaseCell_Will.h"

@interface ClubRushPurchaseCell_Will ()

@property (nonatomic,assign) int dayIndex; // 0:今天  1:明天 2:后天 ...

@end

@implementation ClubRushPurchaseCell_Will

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_returnYunbiLabel radius:2 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
    [Utilities drawView:_opeBtn radius:3 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
    [self changeButtonFrame];
}

- (void)changeButtonFrame{
    for (NSLayoutConstraint *lc in _opeBtn.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeWidth) {
            if (IS_4_7_INCH_SCREEN) {
                lc.constant = 69;
            }else if (IS_5_5_INCH_SCREEN){
                lc.constant = 74;
            }else{
                lc.constant = 54;
            }
            [_opeBtn layoutIfNeeded];
        }
    }
}

- (void)setCsm:(ClubSpreeModel *)csm{
    _csm = csm;
    
    NSDate *spreeDate = [Utilities getDateFromString:_csm.spreeTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
    _dayIndex = [spreeDate timeIntervalSinceDate:[CalendarClass dateForToday]] / (3600*24);
    
    _opeBtn.hidden = NO;
    [_clubImageView sd_setImageWithURL:[NSURL URLWithString:csm.clubPhoto] placeholderImage:[UIImage imageNamed:@"pic_zhanwei"]];
    [_clubNameLabel setText:csm.spreeName.length>0 ? csm.spreeName : @""];
    NSString *datestr = [Utilities getDateStringFromString:csm.teeDate WithFormatter:@"MM月dd日"];
    NSString *teetime = [NSString stringWithFormat:@"开球：%@ %@-%@",datestr,csm.startTime,csm.endTime];
    [_clubTeetimeLabel setText:teetime];
    
    [self setRushLabel];
    if (_timeInteval > 0 && _timeInteval / (24*3600) < 1) {
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(spreeListCountDown:) userInfo:nil repeats:YES];
    }

    [_currentPriceLabel setText:[NSString stringWithFormat:@"%d",csm.currentPrice]];
    [_originalPriceLabel setText:[NSString stringWithFormat:@" ¥%d ",csm.originalPrice]];
    [_returnYunbiLabel setText:csm.giveYunbi > 0?[NSString stringWithFormat:@" 返%d ",csm.giveYunbi]:@""];
    [_distanceLabel setText:[NSString stringWithFormat:@"%.0fkm",csm.remote]];
    
    for (NSLayoutConstraint *lc in _originalPriceLabel.superview.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeLeading && lc.firstItem == _originalPriceLabel) {
            lc.constant = _csm.giveYunbi>0 ? 10 : 5;
            [_originalPriceLabel.superview layoutIfNeeded];
            break;
        }
    }
}

- (void)spreeListCountDown:(NSTimer*)timer{
    if (--_timeInteval < 0) {
        [timer invalidate];
        _opeBtn.hidden = NO;
        
        _opeBtn.backgroundColor = [UIColor colorWithHexString:@"ff6d00"];
        [_opeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_opeBtn setTitle:@"抢购" forState:UIControlStateNormal];
        return;
    }
    [self setRushLabel];
}

- (void)setRushLabel{
    _timeInteval = [ClubRushPurchaseCell timeIntervalWithCompareResult:_csm.spreeTime timeInterGab:[LoginManager sharedManager].timeInterGab];
    if (_timeInteval <= 0) {
        [_rushPurchaseTimeLabel setText:[NSString stringWithFormat:@"剩余%d位",_csm.stockQuantity-_csm.soldQuantity]];
    }else {
        if (_dayIndex < 0) {
            [_rushPurchaseTimeLabel setText:[NSString stringWithFormat:@"剩余%d位",_csm.stockQuantity-_csm.soldQuantity]];
        }else if (_dayIndex == 0){ // 当天
            if (_timeInteval < 600){//小于10分钟
                _opeBtn.hidden = YES;
                NSDate *date = [[CalendarClass dateForToday] dateByAddingTimeInterval:_timeInteval];
                NSString *dateString = [Utilities getDateStringUTCFromDate:date WithAllFormatter:@"HH:mm:ss后开抢"];
                [_rushPurchaseTimeLabel setText:dateString];
            }else{
                [self setCall];
                if (_timeInteval / (24*3600) < 1){
                    NSDate *date = [[CalendarClass dateForToday] dateByAddingTimeInterval:_timeInteval];
                    NSString *dateString = [Utilities getDateStringUTCFromDate:date WithAllFormatter:@"HH:mm:ss后开抢"];
                    [_rushPurchaseTimeLabel setText:dateString];
                }else if (_timeInteval / (24*3600) < 2){
                    [_rushPurchaseTimeLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"明日HH:mm开抢"]];
                }else{
                    [_rushPurchaseTimeLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"MM月dd日HH:mm开抢"]];
                }
            }
            [Utilities drawView:_opeBtn radius:3 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
        }else if (_dayIndex == 1){ // 明天
            [self setCall];
            [_rushPurchaseTimeLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"明日HH:mm开抢"]];
        }else{
            [self setCall];
            [_rushPurchaseTimeLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"MM月dd日HH:mm开抢"]];
        }
    }
}

- (void)setCall{
    if (_csm.hasSetted) {
        [_opeBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [_opeBtn setTitle:@"已设置" forState:UIControlStateNormal];
        [Utilities drawView:_opeBtn radius:3 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"999999"]];
    }else{
        [_opeBtn setTitleColor:[UIColor colorWithHexString:@"ff6d00"] forState:UIControlStateNormal];
        [_opeBtn setTitle:@"提醒我" forState:UIControlStateNormal];
        [Utilities drawView:_opeBtn radius:3 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
    }
}

@end
