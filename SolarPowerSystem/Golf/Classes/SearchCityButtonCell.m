//
//  SearchCityButtonCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/19.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "SearchCityButtonCell.h"
#import "SimpleCityModel.h"

@interface SearchCityButtonCell ()

@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *btns;
@property (nonatomic,weak) IBOutlet UIButton *dbtn1,*dbtn2,*dbtn3;

@end

@implementation SearchCityButtonCell

- (void)setCitys:(NSArray *)citys{
    _citys = citys;
    
    _dbtn1.hidden = YES;
    _dbtn2.hidden = YES;
    _dbtn3.hidden = YES;
    
    for (UIButton *btn in _btns) {
        [btn setTitle:@"" forState:UIControlStateNormal];
        btn.hidden = YES;
        [Utilities drawView:btn radius:2 bordLineWidth:1 borderColor:[UIColor colorWithHexString:@"e6e6e6"]];
        
        if (citys == nil || (citys.count>0 && btn.tag > citys.count)) {
            continue;
        }
                
        if (_isHotCity) {
            SearchCityModel *scm = citys[btn.tag-1];
            [btn setTitle:scm.cityName forState:UIControlStateNormal];
        }else{
            SimpleCityModel *scm = citys[btn.tag-1];
            [btn setTitle:scm.name forState:UIControlStateNormal];
        }
        btn.hidden = NO;
        if (btn.tag == 1) {
            _dbtn1.hidden = btn.hidden;
        }else if (btn.tag == 2){
            _dbtn2.hidden = btn.hidden;
        }else{
            _dbtn3.hidden = btn.hidden;
        }
    }
}

// 删除
- (IBAction)deleteButtonAction:(UIButton*)sender{
    if (_deleteBlock) {
        SimpleCityModel *scm = _citys[sender.tag-1];
        _deleteBlock (scm);
    }
}

// 点击城市
- (IBAction)buttonClickAction:(UIButton*)sender{
    if (_clickBlock) {
        SimpleCityModel *scm = _citys[sender.tag-1];
        _clickBlock (scm);
    }
}

@end
