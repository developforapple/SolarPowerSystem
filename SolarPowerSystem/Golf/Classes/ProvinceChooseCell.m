//
//  ProvinceChooseCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/19.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ProvinceChooseCell.h"

@interface ProvinceChooseCell()

@property (nonatomic,weak) IBOutlet UIButton *markBtn;
@property (nonatomic,weak) IBOutlet UILabel *showLabel;

@end

@implementation ProvinceChooseCell

- (void)setProvince:(Province *)province{
    _province = province;
    _markBtn.selected = _province.open;
    NSString *imageName = _province.open ? @"ic_arrow_up_blue" : @"ic_arrow_down_gray";
    [_markBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_showLabel setText:[NSString stringWithFormat:@"%@",_province.pName]];
}

@end
