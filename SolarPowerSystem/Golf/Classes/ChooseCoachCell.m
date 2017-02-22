//
//  ChooseCoachCell.m
//  Golf
//
//  Created by 黄希望 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ChooseCoachCell.h"
#import "TeachingCourseType.h"

@interface ChooseCoachCell ()<YGLoginViewCtrlDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar;
@property (weak, nonatomic) IBOutlet UILabel *labelTeachCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgAuthentication;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;

@end

@implementation ChooseCoachCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:self.imgHeader radius:57/2. bordLineWidth:0 borderColor:[Utilities R:240 G:240 B:240]];
}

- (void)setTeachingCoachModel:(TeachingCoachModel *)teachingCoachModel{
    _teachingCoachModel = teachingCoachModel;
    [self setTeachingData];
    [self adjustTeachingLocation];
}

- (void)setTeachingData{
    [_imgHeader sd_setImageWithURL:[NSURL URLWithString:_teachingCoachModel.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];

    _imgAuthentication.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_%da",_teachingCoachModel.coachLevel]];
    [_labelName setText:_teachingCoachModel.nickName];
    [_labelTeachCount setText:[NSString stringWithFormat:@"%d次教学",_teachingCoachModel.teachingCount]];
    if (self.classType == TeachingCourseTypeMulti) { // 套课
        [_buyBtn setTitle:@"购买" forState:UIControlStateNormal];
    }else if (self.classType == TeachingCourseTypePublic){
        [_buyBtn setTitle:@"报名" forState:UIControlStateNormal];
    }else{ // 标准课，团体课，公开课
        [_buyBtn setTitle:@"预约" forState:UIControlStateNormal];
    }
}

//设置星星级别  //浦发红酒300176
- (CGFloat)starLevel:(float)starLevel{
    return 80.0/5 * starLevel;
}

//设置教练认证级别
- (NSString *)coachLevel:(int)level{
    NSString *a = @"";
    for (int i = 0 ; i < level; i++) {
        a = [a stringByAppendingString:@"A"];
    }
    return a;
}

- (void)adjustTeachingLocation{
    CGSize size = [Utilities getSize:_labelName.text withFont:_labelName.font withWidth:Device_Width];
    
    if (size.width > Device_Width-220) {
        size.width = Device_Width-220;
    }
    for (NSLayoutConstraint *c in _labelName.constraints) {
        if (c.firstAttribute == NSLayoutAttributeWidth) {
            c.constant = size.width+2;
            [_labelName layoutIfNeeded];
            break;
        }
    }
    
    for (NSLayoutConstraint *c in _imgStar.constraints) {
        if (c.firstAttribute == NSLayoutAttributeWidth) {
            c.constant = [self starLevel: _teachingCoachModel.teachingCount > 0 ? _teachingCoachModel.starLevel : 0];
            [_imgStar layoutIfNeeded];
            break;
        }
    }
}

- (IBAction)clickButtonAction:(id)sender{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES];
        return;
    }
    
    if (_blockReturn) {
        _blockReturn(@(self.classType));
    }
}

- (void)loginButtonPressed:(id)sender{
    if (_blockReturn) {
        _blockReturn(@(self.classType));
    }
}

@end
